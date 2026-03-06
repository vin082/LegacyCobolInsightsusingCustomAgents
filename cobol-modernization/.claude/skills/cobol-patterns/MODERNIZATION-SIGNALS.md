# Modernization Signals — Migration Readiness Indicators

## Green Signals (Migrate with Confidence)

### Signal G1: Clean Single-Entry Structure
```cobol
0000-MAIN.
    PERFORM 1000-INITIALISE
    PERFORM 2000-PROCESS
    PERFORM 9000-FINALISE
    STOP RUN.
```
One main paragraph that PERFORMs sub-paragraphs with clear names.
No GOTO, no ALTER, no complex branching in the main flow.

**Java mapping:** Straightforward method decomposition.

---

### Signal G2: Computational Utility Program
- No FILE SECTION (no file I/O)
- Has LINKAGE SECTION (receives parameters, returns result)
- Pure calculation (COMPUTE, ADD, MULTIPLY, etc.)
- No CICS, no DB2, no external CALLs

**Typical programs:** interest calculators, date utilities, sort key builders,
validation routines, format converters.

**Java mapping:** Static utility class or simple @Service method.

---

### Signal G3: Well-Structured EVALUATE
```cobol
EVALUATE WS-TRANSACTION-TYPE
    WHEN 'D' PERFORM DEBIT-HANDLER
    WHEN 'C' PERFORM CREDIT-HANDLER
    WHEN 'R' PERFORM REVERSAL-HANDLER
    WHEN OTHER PERFORM UNKNOWN-TYPE-ERROR
END-EVALUATE
```

Structured EVALUATE with a WHEN OTHER fallback is ideal.
Java mapping: switch expression or strategy pattern.

---

### Signal G4: Low Copybook Fan-Out
Program uses 1-2 copybooks, neither of which is shared across > 5 other programs.
Minimizes risk that data structure changes affect other programs.

---

### Signal G5: No REDEFINES
No REDEFINES clauses → straightforward record-to-POJO mapping.

---

## Yellow Signals (Migrate with Care)

### Signal Y1: Batch with Standard READ Loop
```cobol
PERFORM UNTIL WS-EOF = 'Y'
    READ INPUT-FILE
        AT END MOVE 'Y' TO WS-EOF
        NOT AT END PERFORM PROCESS-RECORD
    END-READ
END-PERFORM
```

This pattern is very common and maps cleanly to Spring Batch:
- `ItemReader.read()` → READ loop
- `ItemProcessor.process()` → PROCESS-RECORD paragraph
- `ItemWriter.write()` → WRITE statements

Caution: Multi-file programs (multiple OPEN/READ loops) need more analysis.

---

### Signal Y2: CALL with Clean Interface
```cobol
CALL 'UTILITY-PROG' USING BY REFERENCE WS-INPUT WS-OUTPUT WS-RETURN-CODE
```

Clean CALL with explicit parameters is easy to replace with a Java service call:
```java
ReturnCode result = utilityService.process(input, output);
```

Caution: Programs using dynamic CALL (variable program name) or passing complex
nested records require more analysis.

---

### Signal Y3: REDEFINES with Clear Switch
When REDEFINES is used only for type-switching with a controlling flag:
```cobol
05 TRANS-TYPE   PIC X.
05 TRANS-BODY   PIC X(50).
01 DEBIT-VIEW REDEFINES TRANS-RECORD ...
01 CREDIT-VIEW REDEFINES TRANS-RECORD ...
```

Maps cleanly to sealed classes / discriminated union.

---

## Red Signals (Requires Expert Attention)

### Signal R1: ALTER Present
Any ALTER verb → critical risk → requires dedicated architectural analysis.
No automated migration path. Do not include in early waves.

---

### Signal R2: Circular PERFORM Dependencies
```
PARA-A PERFORMs PARA-B
PARA-B PERFORMs PARA-A
```

Not common but indicates deeply entangled logic. Must be refactored to
break the cycle before migration.

---

### Signal R3: Mixed Batch and Online (CICS)
Programs that have both file-based batch logic AND CICS commands are
complex to migrate because they serve two architectural masters.
Split into separate programs first, then migrate independently.

---

### Signal R4: DB2 Embedded SQL
```cobol
EXEC SQL
    SELECT CUST_NAME INTO :WS-CUST-NAME
    FROM CUSTOMER
    WHERE CUST_ID = :WS-CUST-ID
END-EXEC
```

Requires Spring Data JPA / JDBC migration. Each EXEC SQL block maps to a
repository method. Complex dynamic SQL (string-built queries) requires extra care.

---

### Signal R5: SORT with INPUT/OUTPUT PROCEDURE
When SORT uses user-defined procedures, the migration is more complex than
a simple Spring Batch sort step.

---

## Migration Readiness Scoring

Score programs 0-10 based on signals:

| Condition | Points |
|-----------|--------|
| No GOTO | +2 |
| No ALTER | +2 |
| No REDEFINES | +1 |
| Has clean EVALUATE | +1 |
| Has LINKAGE SECTION (service interface) | +1 |
| Line count < 500 | +1 |
| Fan-in < 3 | +1 |
| No CICS | +1 |

| Score | Readiness |
|-------|-----------|
| 8-10 | Migrate in Wave 1 |
| 5-7 | Migrate in Wave 2-3 |
| 3-4 | Migrate in Wave 3-4 |
| 0-2 | Evaluate for rewrite |
