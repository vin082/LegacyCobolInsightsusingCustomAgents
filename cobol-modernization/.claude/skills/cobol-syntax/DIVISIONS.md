# COBOL Divisions — Detailed Reference

## IDENTIFICATION DIVISION

The first division of every COBOL program. Provides metadata about the program.

```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID. MY-PROGRAM.
AUTHOR. J.SMITH.
DATE-WRITTEN. 1995-04-20.
DATE-COMPILED.
REMARKS. This program processes customer accounts.
```

### Required paragraphs:
- **PROGRAM-ID** — unique identifier for the program (used in CALL statements)

### Optional paragraphs (informational only):
- **AUTHOR** — developer name
- **INSTALLATION** — site/department
- **DATE-WRITTEN** — original authoring date
- **DATE-COMPILED** — auto-populated by compiler
- **SECURITY** — classification level
- **REMARKS** — free-text description

## ENVIRONMENT DIVISION

Describes the hardware and file system environment. Has two sections.

```cobol
ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
    SOURCE-COMPUTER. IBM-MAINFRAME.
    OBJECT-COMPUTER. IBM-MAINFRAME.
INPUT-OUTPUT SECTION.
    FILE-CONTROL.
        SELECT CUSTOMER-FILE ASSIGN TO CUSTMAST
            ORGANIZATION IS SEQUENTIAL
            ACCESS MODE IS SEQUENTIAL
            FILE STATUS IS WS-FILE-STATUS.
```

### CONFIGURATION SECTION
- **SOURCE-COMPUTER** — machine that compiles the program
- **OBJECT-COMPUTER** — machine that runs the program
- **SPECIAL-NAMES** — maps system names (SYSIN, SYSOUT) to symbolic names

### INPUT-OUTPUT SECTION
- **FILE-CONTROL** — SELECT/ASSIGN pairs linking logical names to physical files
  - `SELECT logical-name ASSIGN TO physical-name`
  - `ORGANIZATION IS SEQUENTIAL | INDEXED | RELATIVE`
  - `ACCESS MODE IS SEQUENTIAL | RANDOM | DYNAMIC`
  - `RECORD KEY IS key-field` (for INDEXED files)
  - `FILE STATUS IS ws-variable` (captures I/O return codes)

## DATA DIVISION

All data definitions. Has multiple sections processed in fixed order.

### FILE SECTION
File descriptor (FD) entries for each file named in FILE-CONTROL:

```cobol
FILE SECTION.
FD CUSTOMER-FILE
    RECORDING MODE IS F
    BLOCK CONTAINS 0 RECORDS
    RECORD CONTAINS 200 CHARACTERS.
01 CUSTOMER-RECORD.
   COPY CUSTOMER-RECORD.
```

- **FD** — File Descriptor: describes physical characteristics
- **RECORDING MODE** — F (fixed), V (variable), U (undefined)
- **BLOCK CONTAINS** — blocking factor (0 = system default)
- **RECORD CONTAINS** — fixed record length

### WORKING-STORAGE SECTION
In-memory variables and records. Persists for the lifetime of the program run.

```cobol
WORKING-STORAGE SECTION.
01 WS-FLAGS.
   05 WS-EOF-FLAG        PIC X     VALUE 'N'.
      88 WS-EOF          VALUE 'Y'.
   05 WS-ERROR-FLAG      PIC X     VALUE 'N'.
01 WS-COUNTERS.
   05 WS-RECORD-COUNT    PIC 9(7)  VALUE ZEROES.
01 WS-WORK-AREA.
   05 WS-WORK-DATE       PIC 9(8).
   05 WS-FORMATTED-AMT   PIC Z,ZZZ,ZZ9.99.
```

Key rules:
- 01-level items are records (group items or standalone)
- 05, 10, 15... are hierarchical children
- VALUE clause sets initial value
- 88-level items are condition names (boolean flags on parent)

### LINKAGE SECTION
Parameters passed from calling programs. No storage allocated — these map to
the caller's memory.

```cobol
LINKAGE SECTION.
01 LS-CUSTOMER-RECORD.
   05 LS-CUST-ID         PIC 9(8).
   05 LS-CUST-NAME       PIC X(40).
01 LS-RETURN-CODE        PIC S9(4) COMP.
```

Used with `PROCEDURE DIVISION USING LS-CUSTOMER-RECORD LS-RETURN-CODE`.

### LOCAL-STORAGE SECTION (Modern COBOL / CICS)
Thread-local storage — new instance per CALL, unlike WORKING-STORAGE.
Used in reentrant programs and CICS environments.

## PROCEDURE DIVISION

The executable logic section. Organized into sections and paragraphs.

```cobol
PROCEDURE DIVISION USING LS-CUSTOMER-RECORD LS-RETURN-CODE.
0000-MAIN SECTION.
0000-MAIN-PARA.
    PERFORM 1000-VALIDATE-INPUT
    PERFORM 2000-PROCESS-RECORD
    PERFORM 9000-RETURN
    STOP RUN.

1000-VALIDATE-INPUT SECTION.
1000-VALIDATE-PARA.
    IF LS-CUST-ID = ZEROES
        MOVE 8 TO LS-RETURN-CODE
        GO TO 1000-EXIT
    END-IF.
1000-EXIT.
    EXIT.
```

### Sections vs Paragraphs
- **SECTION** — named block containing one or more paragraphs
- **PARAGRAPH** — named block of statements within a section (or standalone)
- Paragraphs are the primary unit of PERFORM calls in most legacy COBOL

### USING clause
Lists LINKAGE SECTION items accepted as parameters from the caller.
`PROCEDURE DIVISION USING param1 param2`

### RETURNING clause (Modern COBOL)
`PROCEDURE DIVISION RETURNING return-item` — for function-style programs
