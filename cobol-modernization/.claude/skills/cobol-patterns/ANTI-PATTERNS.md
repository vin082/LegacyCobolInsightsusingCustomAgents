# COBOL Anti-Patterns — Detailed Reference

## CRITICAL Anti-Patterns

### 1. ALTER Verb (Self-Modifying Code)
**Severity: CRITICAL — Blocks automated migration**

The ALTER verb changes the destination of a GOTO at runtime:
```cobol
INITIAL-FLOW.
    GO TO FIRST-PROCESS.         ← This target gets altered at runtime

SETUP-PHASE.
    ALTER INITIAL-FLOW TO PROCEED TO SECOND-PROCESS.
    GO TO INITIAL-FLOW.          ← Now jumps to SECOND-PROCESS
```

**Why it's critical:**
- Control flow cannot be statically determined
- Different runs may follow different paths
- Impossible to unit test individual paragraphs
- No direct Java equivalent

**Migration approach:**
- Map all possible states and transitions manually
- Replace with explicit state machine or strategy pattern
- Requires deep manual analysis — budget 5+ days per program

---

### 2. Complex GOTO Networks (Spaghetti Code)
**Severity: CRITICAL to HIGH**

```cobol
0100-PROCESS.
    IF WS-TYPE = 'A' GO TO 0200-TYPE-A
    IF WS-TYPE = 'B' GO TO 0300-TYPE-B
    GO TO 0500-ERROR.

0200-TYPE-A.
    PERFORM 0210-SUB-A
    GO TO 0400-COMMON.

0300-TYPE-B.
    GO TO 0310-SUB-B.

0310-SUB-B.
    IF WS-FLAG = 'Y' GO TO 0200-TYPE-A.   ← Cross-type jump!
    GO TO 0400-COMMON.
```

**Detection:** Any paragraph that contains > 2 GOTO statements, or GOTOs
that jump across section boundaries.

**Migration approach:**
- Trace all execution paths manually
- Extract each path as a separate method
- Use if/else chains or switch statements

---

### 3. REDEFINES on Complex Groups
**Severity: HIGH**

```cobol
01 PAYMENT-RECORD.
   05 PAYMENT-TYPE      PIC X.
   05 PAYMENT-DATA      PIC X(99).

01 CARD-PAYMENT REDEFINES PAYMENT-RECORD.
   05 FILLER            PIC X.
   05 CARD-NUMBER       PIC 9(16).
   05 CARD-EXPIRY       PIC 9(4).
   05 CARD-CVV          PIC 9(3).
   05 FILLER            PIC X(76).

01 BANK-PAYMENT REDEFINES PAYMENT-RECORD.
   05 FILLER            PIC X.
   05 SORT-CODE         PIC 9(6).
   05 ACCOUNT-NUMBER    PIC 9(8).
   05 FILLER            PIC X(85).
```

**Why it's risky:**
- No type safety — any overlay can be written at any time
- Bugs if wrong overlay is accessed after setting via different overlay
- Size must be exactly the same as the redefined item

**Java mapping:**
```java
sealed interface PaymentRecord permits CardPayment, BankPayment {}
record CardPayment(String cardNumber, String expiry, String cvv) implements PaymentRecord {}
record BankPayment(String sortCode, String accountNumber) implements PaymentRecord {}
```

---

## HIGH Anti-Patterns

### 4. Deep PERFORM THRU
```cobol
PERFORM 1000-START THRU 5000-END
```

When this THRU range spans many paragraphs, the control flow includes every
paragraph in between (including ones not intended). Any GOTO within that range
that exits the range causes undefined behavior.

**Detection:** PERFORM...THRU spans > 5 paragraphs OR spans a section boundary.

---

### 5. Computed GOTO
```cobol
GO TO PARA-1 PARA-2 PARA-3 PARA-4 DEPENDING ON WS-CHOICE
```

Acts like a jump table. `WS-CHOICE = 1` jumps to PARA-1, etc.

**Java mapping:**
```java
switch (choice) {
    case 1 -> para1();
    case 2 -> para2();
    // etc.
}
```

---

### 6. Global Working-Storage Mutation
Programs that use 01-level WORKING-STORAGE items as implicit communication
channels between paragraphs — effectively global mutable state.

**Detection:** Multiple paragraphs MOVE to the same 01-level working storage
item; no encapsulation via CALL/USING parameters.

**Risk in Java:** Java services are often multi-threaded; instance variables
shared between methods create race conditions.

---

## MEDIUM Anti-Patterns

### 7. Implicit Numeric Truncation
```cobol
05 WS-SMALL    PIC 9(3).
05 WS-LARGE    PIC 9(7) VALUE 1234567.
MOVE WS-LARGE TO WS-SMALL     ← Silently truncates to 567
```

COBOL silently truncates on the left. Java throws an exception or wraps
(for int overflow). Must add explicit range checks.

### 8. Implicit Space Padding
```cobol
05 WS-SHORT   PIC X(5) VALUE 'HI'.      ← Stored as 'HI   '
05 WS-LONG    PIC X(20).
MOVE WS-SHORT TO WS-LONG                ← Becomes 'HI              '
```

COBOL pads with spaces to fill the receiving field. Java String does not.
Must use `String.format("%-20s", value)` or `StringUtils.rightPad()`.

### 9. MOVE CORRESPONDING
```cobol
MOVE CORRESPONDING SOURCE-RECORD TO DEST-RECORD
```

Moves fields with matching names between two group items. Invisible data flow —
hard to see which fields are actually affected.

**Java mapping:** Requires explicit field-by-field assignment or a mapper.

### 10. Paragraph Fall-Through
```cobol
1000-PROCESS.
    PERFORM 1100-STEP-ONE.

1100-STEP-ONE.
    ADD 1 TO WS-COUNTER.
    ← No explicit EXIT or GO TO — falls into 1200-STEP-TWO!

1200-STEP-TWO.
    MOVE 'Y' TO WS-DONE.
```

If `1000-PROCESS` PERFORMs `1100-STEP-ONE`, execution falls into `1200-STEP-TWO`
unless there is a `GO TO` or `EXIT`. This is intentional in many legacy programs
but invisible from the PERFORM call site.
