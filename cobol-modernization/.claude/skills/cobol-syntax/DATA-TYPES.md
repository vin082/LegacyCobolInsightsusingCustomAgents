# COBOL Data Types — Detailed Reference

## PIC Clause Symbols

### Numeric Picture Characters

| Symbol | Meaning | Example | Java Equivalent |
|--------|---------|---------|-----------------|
| 9 | One decimal digit | PIC 9(8) | int / long |
| S | Sign (+ or -) | PIC S9(7) | Signed int/long |
| V | Implied decimal point | PIC 9(5)V99 | BigDecimal |
| P | Scaling position | PIC 9(3)PPP | BigDecimal scaled |
| . | Decimal point (display) | PIC 999.99 | Display only |

### Alphanumeric Picture Characters

| Symbol | Meaning | Example | Java Equivalent |
|--------|---------|---------|-----------------|
| X | Any character | PIC X(40) | String |
| A | Alphabetic only | PIC A(10) | String |
| G | DBCS character | PIC G(20) | String (Unicode) |
| N | National character | PIC N(20) | String (Unicode) |

### Editing Characters (display only)

| Symbol | Meaning | Example |
|--------|---------|---------|
| Z | Zero-suppress | PIC ZZZ9 → " 42" not "0042" |
| * | Asterisk fill | PIC ***9 → "**42" |
| $ | Currency symbol | PIC $$$9.99 |
| + | Sign display | PIC +999 |
| - | Sign display | PIC -999 |
| CR / DB | Credit/Debit | PIC 999.99CR |
| B | Space insertion | PIC 99B99 |
| 0 | Zero insertion | PIC 99099 |
| / | Slash insertion | PIC 99/99/99 |
| , | Comma insertion | PIC 9,999 |

## Level Numbers

### Standard Levels (01-49)

```cobol
01 CUSTOMER-RECORD.           ← Group item (record)
   05 CUST-IDENTITY.          ← Nested group
      10 CUST-ID     PIC 9(8).  ← Elementary item
      10 CUST-TYPE   PIC X(2).
   05 CUST-BALANCE   PIC S9(9)V99.  ← Elementary item
   05 CUST-STATUS    PIC X.
      88 CUST-ACTIVE VALUE 'A'.     ← Condition name
      88 CUST-CLOSED VALUE 'C'.
```

- **Group items**: have subordinate items, no PIC clause
- **Elementary items**: leaf nodes, have PIC clause
- Level gaps allowed (01, 05, 10 is fine — same as 01, 02, 03)

### Special Level 66 — RENAMES

```cobol
01 PHONE-NUMBER.
   05 AREA-CODE    PIC 9(3).
   05 EXCHANGE     PIC 9(3).
   05 EXTENSION    PIC 9(4).
66 FULL-PHONE      RENAMES AREA-CODE THRU EXTENSION.
```

Creates an alias spanning a range of fields. Rarely used. Maps to a view/slice in Java.

### Special Level 77 — Standalone Items

```cobol
77 WS-RETURN-CODE     PIC S9(4) COMP.
77 WS-PROGRAM-NAME    PIC X(8) VALUE 'MYPROG  '.
```

Standalone elementary items — not part of any group. Equivalent to class-level fields.

### Special Level 88 — Condition Names

```cobol
05 WS-STATUS          PIC X.
   88 STATUS-OK        VALUE 'O'.
   88 STATUS-ERROR     VALUE 'E'.
   88 STATUS-PENDING   VALUE 'P'.
   88 STATUS-VALID     VALUE 'O' 'P'.  ← Multiple values
   88 STATUS-RANGE     VALUE 'A' THRU 'Z'.  ← Range
```

Condition names are referenced in IF and EVALUATE:
```cobol
IF STATUS-OK PERFORM PROCESS-RECORD
EVALUATE TRUE
  WHEN STATUS-ERROR PERFORM HANDLE-ERROR
  WHEN STATUS-PENDING PERFORM QUEUE-RECORD
END-EVALUATE
```

Java equivalent: boolean constants or enum:
```java
enum Status { OK, ERROR, PENDING }
boolean isStatusOk = status == Status.OK;
```

## USAGE Clause — Internal Storage Format

Affects how data is stored internally (not how it looks to the program):

| USAGE | Storage | Use Case | Java Hint |
|-------|---------|----------|-----------|
| DISPLAY (default) | Character string | Input/output, display | String |
| COMP / BINARY | Binary integer | Arithmetic, counters | int/long |
| COMP-1 | Single-precision float | Rarely used | float |
| COMP-2 | Double-precision float | Rarely used | double |
| COMP-3 / PACKED-DECIMAL | Packed decimal | Money, calculations | BigDecimal |
| COMP-4 | Binary (same as COMP) | Counters | int/long |
| COMP-5 | Native binary | Performance-critical | int/long |
| INDEX | Index for table | OCCURS index | int |

### Important: COMP-3 / PACKED-DECIMAL
Most common for financial data. Two digits stored per byte:
- `PIC S9(7)V99 COMP-3` — signed 9-digit number with 2 decimal places
- Java: `BigDecimal` always

## OCCURS Clause — Arrays

### Fixed-length arrays:
```cobol
01 MONTHLY-TOTALS.
   05 MONTH-AMOUNT    PIC S9(9)V99 OCCURS 12 TIMES.
```
Access: `MONTH-AMOUNT(1)` through `MONTH-AMOUNT(12)` (1-based!)

### Variable-length arrays (OCCURS DEPENDING ON):
```cobol
01 TRANSACTION-TABLE.
   05 TRANS-COUNT     PIC 9(4).
   05 TRANS-ENTRY     OCCURS 1 TO 999 DEPENDING ON TRANS-COUNT.
      10 TRANS-ID     PIC 9(8).
      10 TRANS-AMOUNT PIC S9(9)V99.
```
Java: `List<TransEntry>` where size = `TRANS-COUNT`

### Tables with INDEXED BY:
```cobol
01 STATE-TABLE.
   05 STATE-ENTRY     OCCURS 50 TIMES INDEXED BY STATE-IDX.
      10 STATE-CODE   PIC X(2).
      10 STATE-NAME   PIC X(30).
```
Use `SET STATE-IDX TO 1`, `SEARCH STATE-TABLE WHEN ...` for lookups.

## REDEFINES Clause — Memory Overlays

Allows multiple data structures to share the same memory location:

```cobol
01 DATE-NUMERIC     PIC 9(8).
01 DATE-PARTS REDEFINES DATE-NUMERIC.
   05 DATE-YEAR     PIC 9(4).
   05 DATE-MONTH    PIC 9(2).
   05 DATE-DAY      PIC 9(2).
```

Or for union types:
```cobol
01 TRANSACTION-RECORD.
   05 TRANS-TYPE     PIC X.
   05 TRANS-DATA     PIC X(100).
01 DEBIT-RECORD REDEFINES TRANSACTION-RECORD.
   05 FILLER         PIC X.      ← Skip TRANS-TYPE
   05 DEBIT-AMOUNT   PIC S9(9)V99.
   05 DEBIT-ACCOUNT  PIC 9(10).
```

Java mapping: sealed classes / discriminated unions:
```java
sealed interface TransactionRecord permits DebitRecord, CreditRecord {}
record DebitRecord(BigDecimal amount, long account) implements TransactionRecord {}
```
