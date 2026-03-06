# COBOL to Java Type Mapping — Complete Reference

## Numeric Types

### Integer PIC clauses

| COBOL PIC | Max Value | Java Type | Notes |
|-----------|-----------|-----------|-------|
| PIC 9(1) | 9 | byte or int | Prefer int for simplicity |
| PIC 9(2) | 99 | int | |
| PIC 9(3) | 999 | int | |
| PIC 9(4) | 9999 | int | |
| PIC 9(5) | 99999 | int | |
| PIC 9(6) | 999999 | int | |
| PIC 9(7) | 9999999 | int | |
| PIC 9(8) | 99999999 | long | Safe as long; use int only if certain < 2B |
| PIC 9(9) | 999999999 | long | |
| PIC 9(10-18) | Up to 10^18 | long | |
| PIC 9(19+) | > Long.MAX | BigInteger | Rare |

### Signed Integer PIC clauses

| COBOL PIC | Java Type | Notes |
|-----------|-----------|-------|
| PIC S9(1-4) | int | Signed, fits in int |
| PIC S9(5-9) | int or long | Prefer long for safety |
| PIC S9(10+) | long | |

### Decimal PIC clauses (ALWAYS use BigDecimal)

| COBOL PIC | Java Type | Initialization |
|-----------|-----------|---------------|
| PIC 9(n)V9(m) | BigDecimal | BigDecimal.valueOf(cobolValue).movePointLeft(m) |
| PIC S9(n)V9(m) | BigDecimal | Signed decimal — same mapping |
| PIC 9(n)V9(2) | BigDecimal | Currency — scale 2 |
| PIC S9(7)V99 | BigDecimal | Common financial amount |

**Critical rule:** Never use float or double for financial calculations.
Always use `BigDecimal` with explicit rounding mode:
```java
BigDecimal result = amount.multiply(rate)
    .setScale(2, RoundingMode.HALF_UP);
```

### COMP-3 / Packed Decimal

```cobol
05 WS-AMOUNT   PIC S9(9)V99 COMP-3.
```

Same Java mapping as DISPLAY decimal — `BigDecimal`. The COMP-3 only affects
how COBOL stores it internally on the mainframe. When reading from a file or
DB2, the value is already decoded before reaching Java.

If reading raw EBCDIC/packed bytes from a file:
```java
// Unpack COMP-3: n digits in ceil((n+1)/2) bytes
// Custom unpacker needed for raw mainframe files
```

## String Types

| COBOL PIC | Java Type | Conversion Notes |
|-----------|-----------|-----------------|
| PIC X(n) | String | Always `.trim()` — COBOL right-pads with spaces |
| PIC A(n) | String | Alphabetic only — still `String` in Java |
| PIC G(n) | String | DBCS — check charset (Shift-JIS, EBCDIC DBCS) |
| PIC N(n) | String | National character — UTF-16 |

### Trimming rule
COBOL stores `"HELLO     "` (space-padded to PIC X(10)).
Java reads it as `"HELLO     "` unless trimmed:
```java
String name = cobolRecord.getCustName().trim();
```

For right-padded numeric strings:
```java
String amount = cobolRecord.getAmountDisplay().strip();
```

## Group Items (Records)

| COBOL Level | Java Pattern |
|-------------|-------------|
| 01-level group | Java Record or POJO class |
| Nested 05/10 group | Nested record/class, or flat with prefix |
| 66 RENAMES | Computed property or view method |
| 77 standalone | Single field in parent class |

### Example Mapping
```cobol
01 CUSTOMER-RECORD.
   05 CUST-ID        PIC 9(8).
   05 CUST-NAME      PIC X(40).
   05 CUST-ADDRESS.
      10 CUST-STREET PIC X(50).
      10 CUST-CITY   PIC X(30).
      10 CUST-ZIP    PIC 9(5).
   05 CUST-BALANCE   PIC S9(9)V99.
```

```java
public record CustomerRecord(
    long custId,
    String custName,
    CustomerAddress custAddress,
    BigDecimal custBalance
) {
    public record CustomerAddress(
        String street,
        String city,
        String zip
    ) {}
}
```

## Condition Names (88-level)

| COBOL | Java Pattern |
|-------|-------------|
| Single VALUE | boolean constant |
| Multiple VALUES | enum or Set<> |
| VALUE THRU | Range check method |

```cobol
05 WS-STATUS       PIC X.
   88 STATUS-OK    VALUE 'O'.
   88 STATUS-ERROR VALUE 'E' 'F' 'G'.
```

```java
public enum CustomerStatus {
    OK('O'), ERROR('E');  // simplified

    private final char code;

    public static CustomerStatus fromCode(char c) {
        return switch(c) {
            case 'O' -> OK;
            case 'E', 'F', 'G' -> ERROR;
            default -> throw new IllegalArgumentException("Unknown status: " + c);
        };
    }
}
```

## OCCURS / Arrays

| COBOL Pattern | Java Type | Notes |
|---------------|-----------|-------|
| OCCURS n TIMES | T[n] or List<T> | Prefer List |
| OCCURS 1 TO n DEPENDING ON | List<T> | ArrayList, size from DEPENDING ON field |
| OCCURS with INDEXED BY | List<T> | Index management manual |
| OCCURS ASCENDING/DESCENDING KEY | TreeMap or sorted List | For SEARCH ALL |

## Special COBOL Registers and Figurative Constants

| COBOL | Java |
|-------|------|
| SPACES / SPACE | " " or "" |
| ZEROES / ZERO | 0 or BigDecimal.ZERO |
| HIGH-VALUES | "\uFFFF" (max char) |
| LOW-VALUES | "\u0000" (null char) |
| RETURN-CODE | int returnCode = 0 (method return) |
| LENGTH OF item | item.length() or array.length |
| ADDRESS OF item | Not applicable (Java has no pointers) |
