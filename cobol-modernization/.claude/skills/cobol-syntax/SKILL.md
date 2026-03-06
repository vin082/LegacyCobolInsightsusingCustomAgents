---
name: cobol-syntax
description: COBOL language grammar, division and section structure, PIC clause syntax, level numbers, procedure division verbs, and language construct reference. Use when parsing, analysing, or explaining COBOL source code structure.
---

# COBOL Syntax Reference

COBOL programs are divided into four mandatory divisions in fixed order.
See DIVISIONS.md for detailed coverage. Key summary below.

## The Four Divisions

1. **IDENTIFICATION DIVISION** — Program metadata
   - PROGRAM-ID (required), AUTHOR, DATE-WRITTEN, REMARKS

2. **ENVIRONMENT DIVISION** — System and file linkage
   - CONFIGURATION SECTION: SOURCE-COMPUTER, OBJECT-COMPUTER
   - INPUT-OUTPUT SECTION: FILE-CONTROL with SELECT/ASSIGN pairs

3. **DATA DIVISION** — All data definitions
   - FILE SECTION: FD entries (file descriptors)
   - WORKING-STORAGE SECTION: in-memory variables and records
   - LINKAGE SECTION: parameters from calling programs
   - LOCAL-STORAGE SECTION: thread-local data (CICS/modern COBOL)

4. **PROCEDURE DIVISION** — Executable logic
   - Organized into sections and paragraphs
   - USING clause lists LINKAGE SECTION parameters

## Level Numbers

| Level | Meaning |
|---|---|
| 01 | Top-level group item or record |
| 02-49 | Subordinate group or elementary items |
| 66 | RENAMES clause (aliases) |
| 77 | Standalone elementary item (no group) |
| 88 | Condition name (boolean flag for a parent item's value) |

## PIC Clause Quick Reference

| Symbol | Meaning | Example |
|---|---|---|
| 9 | Numeric digit | PIC 9(8) = 8-digit number |
| X | Alphanumeric character | PIC X(40) = 40-char string |
| A | Alphabetic only | PIC A(10) |
| V | Implied decimal point | PIC 9(5)V99 = 99999.99 |
| S | Signed number | PIC S9(7)V99 |
| Z | Zero-suppress leading zeros | PIC ZZZ9 |
| $ | Currency sign (display) | PIC $$$9.99 |

## Key Procedure Division Verbs

- **PERFORM** — Call a paragraph (structured GOTO equivalent)
  - `PERFORM para-name` — single call
  - `PERFORM para-name THRU end-para` — range
  - `PERFORM para-name UNTIL condition` — loop
  - `PERFORM para-name VARYING x FROM 1 BY 1 UNTIL x > 10` — counted loop

- **CALL** — Invoke external COBOL program
  - `CALL 'PROGRAM-NAME' USING param1, param2`
  - `CALL 'PROGRAM-NAME' USING BY REFERENCE param` (pass by ref)
  - `CALL 'PROGRAM-NAME' USING BY CONTENT param` (pass by value)

- **COPY** — Include a copybook
  - `COPY copybook-name` — verbatim include
  - `COPY copybook-name REPLACING ==OLD== BY ==NEW==` — with substitution

- **MOVE** — Data assignment
  - `MOVE value TO target`
  - `MOVE CORRESPONDING source TO target` — field-name matching

- **EVALUATE** — Switch/case
  - `EVALUATE TRUE WHEN condition1 ... WHEN condition2 ...`
  - `EVALUATE variable WHEN value1 ... WHEN OTHER ...`

- **READ/WRITE/OPEN/CLOSE/REWRITE/DELETE** — File I/O verbs

- **GOTO** — Unconditional branch (legacy, avoid in modern COBOL)
- **ALTER** — Modifies a GOTO target at runtime (self-modifying, critical risk)

## For more detail:
- Division deep dive: read DIVISIONS.md
- Data type details: read DATA-TYPES.md
- All procedure verbs: read VERBS.md
