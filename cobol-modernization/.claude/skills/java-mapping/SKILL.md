---
name: java-mapping
description: Mappings from COBOL constructs to Java equivalents. Covers data type mappings, control flow mappings, file I/O patterns, and Spring Boot architecture recommendations. Use when migration-advisor is producing Java blueprints for COBOL programs.
---

# COBOL → Java Mapping Reference

## Data Type Mappings

| COBOL PIC | Java Type | Notes |
|---|---|---|
| PIC 9(1-4) | int | Small integers |
| PIC 9(5-9) | long | Larger integers |
| PIC 9(10+) | BigInteger | Very large integers |
| PIC 9(n)V9(m) | BigDecimal | Always use BigDecimal for money |
| PIC S9(n)V9(m) | BigDecimal | Signed decimal |
| PIC X(n) | String | Use .trim() when reading COBOL data |
| PIC A(n) | String | Alphabetic — still String in Java |
| 01-level group | POJO / Java Record | Field-per-child mapping |
| 88-level condition | boolean / enum constant | `if (ws.customerActive)` |
| OCCURS n TIMES | T[] or List<T> | Prefer List for mutability |
| OCCURS DEPENDING ON | List<T> (dynamic) | Size from the depending-on field |

## Control Flow Mappings

| COBOL Construct | Java Equivalent |
|---|---|
| PERFORM para-name | privateMethod() call |
| PERFORM para VARYING x FROM 1 BY 1 UNTIL x > n | for (int x = 1; x <= n; x++) |
| PERFORM para UNTIL condition | while (!condition) { method(); } |
| EVALUATE TRUE WHEN cond1 | if/else if chain or switch expression |
| EVALUATE var WHEN val1 | switch(var) { case val1: } |
| GOTO (simple) | Extract to loop or if/else |
| GOTO (complex) | State machine pattern |
| ALTER | Manual refactor required — no mapping |
| STOP RUN | return; (from main method) |

## File I/O Mappings

| COBOL Pattern | Java/Spring Pattern |
|---|---|
| OPEN INPUT file | repository.findAll() or FileReader |
| READ file AT END | Iterator hasNext() check |
| WRITE record | repository.save(entity) |
| CLOSE file | (handled by Spring / try-with-resources) |
| Sequential file processing | Spring Batch ItemReader/ItemWriter |
| VSAM KSDS (keyed) | Spring Data JPA with @Id |

## Program Type → Spring Boot Architecture

| COBOL Program Type | Spring Component | Pattern |
|---|---|---|
| Batch program (file in/out) | @Configuration + ItemProcessor | Spring Batch Job |
| Subroutine (LINKAGE SECTION) | @Service | Injected service bean |
| CICS transaction | @RestController | REST endpoint |
| Report generator | @Service + @Component | Service + template |
| DB2 embedded SQL | @Repository + JPA | Spring Data JPA |

## Copybook → Shared Domain Object
Each copybook becomes a shared Java class in a `common` or `domain` module:
```java
// COBOL: CUSTOMER-RECORD copybook
// Java:
public record CustomerRecord(
    long customerId,      // PIC 9(8)
    String customerName,  // PIC X(40) — trim() on construction
    BigDecimal balance,   // PIC S9(9)V99
    boolean isActive      // 88 CUSTOMER-ACTIVE VALUE 'Y'
) {}
```

## For full type mapping tables: read TYPE-MAPPING.md
## For structural pattern mappings: read PATTERN-MAPPING.md
