# CardDemo — Business Rules Catalogue

**Source:** Neo4j LegacyCobolInsights Knowledge Graph
**Total Rules:** 85 across 24 programs
**Query date:** 2026-03-06
**Confidence:** HIGH = extracted directly from COBOL AST | MEDIUM = inferred from pattern/naming | LOW = structural heuristic only

---

## Summary Statistics

| Rule Type | Count |
|---|---|
| DATA-ACCESS | 28 |
| CONDITIONAL | 18 |
| ROUTING | 17 |
| VALIDATION | 13 |
| CALCULATION | 9 |
| THRESHOLD | 2 |
| **Total** | **85** |

| Confidence | Count |
|---|---|
| HIGH | 67 |
| MEDIUM | 18 |
| LOW | 0 |

---

## Batch Programs (CB prefix)

---

### CBACT01C — Account File Processor

**Function:** Reads account file sequentially, applies defaults, formats dates, populates output arrays.

| # | Rule ID | Name | Type | Confidence | Paragraph | COBOL Source |
|---|---|---|---|---|---|---|
| 1 | `CBACT01C.ACCTFILE-READ` | Read Account File Sequentially | DATA-ACCESS | HIGH | `1000-ACCTFILE-GET-NEXT` | `READ ACCTFILE-FILE NEXT RECORD AT END SET APPL-EOF TO TRUE` |
| 2 | `CBACT01C.OUTFILE-WRITE` | Write Processed Account Record to Output File | DATA-ACCESS | HIGH | `1350-WRITE-ACCT-RECORD` | *(direct WRITE)* |
| 3 | `CBACT01C.EOF-DETECTION` | End of File Detection for Account File | CONDITIONAL | HIGH | `1000-ACCTFILE-GET-NEXT` | `WRITE OUT-ACCT-REC` |
| 4 | `CBACT01C.FILE-STATUS-CHECK` | Validate File I/O Status Codes | VALIDATION | HIGH | `9910-DISPLAY-IO-STATUS` | `IF OUTFILE-STATUS NOT = 00 AND OUTFILE-STATUS NOT = 10 PERFORM 9999-ABEND-PROGRAM` |
| 5 | `CBACT01C.DATE-FORMATTING` | Format Account Dates Using COBDATFT | CALCULATION | HIGH | `1300-POPUL-ACCT-RECORD` | `CALL COBDATFT USING CODATECN-REC` |
| 6 | `CBACT01C.ARRAY-POPULATION` | Populate Account Balance Array | CALCULATION | HIGH | `1400-POPUL-ARRAY-RECORD` | `ARR-ACCT-BAL OCCURS 5 TIMES` |
| 7 | `CBACT01C.DEFAULT-DEBIT-VALUE` | Apply Default Debit Value When Zero | THRESHOLD | MEDIUM | `1300-POPUL-ACCT-RECORD` | `IF ACCT-CURR-CYC-DEBIT EQUAL TO ZERO MOVE 2525.00 TO OUT-ACCT-CURR-CYC-DEBIT` |

**Traceability notes:**
- Rule 7 (`DEFAULT-DEBIT-VALUE`) embeds a **hard-coded business default of $2,525.00** for zero debit cycles — this requires business owner sign-off before migration.

---

### CBACT02C — Card File Processor

**Function:** Reads card file sequentially for batch processing.

| # | Rule ID | Name | Type | Confidence | Paragraph |
|---|---|---|---|---|---|
| 1 | `CBACT02C.CARDFILE-READ` | Read Card File Sequentially | DATA-ACCESS | HIGH | `1000-CARDFILE-GET-NEXT` |
| 2 | `CBACT02C.EOF-DETECTION` | End of File Detection | CONDITIONAL | HIGH | `1000-CARDFILE-GET-NEXT` |
| 3 | `CBACT02C.FILE-STATUS-CHECK` | File Status Validation | VALIDATION | HIGH | `9910-DISPLAY-IO-STATUS` |

---

### CBACT03C — Cross Reference File Processor

**Function:** Reads card cross-reference file sequentially.

| # | Rule ID | Name | Type | Confidence | Paragraph |
|---|---|---|---|---|---|
| 1 | `CBACT03C.XREFFILE-READ` | Read Cross Reference File Sequentially | DATA-ACCESS | HIGH | `1000-XREFFILE-GET-NEXT` |
| 2 | `CBACT03C.EOF-DETECTION` | End of File Detection | CONDITIONAL | HIGH | `1000-XREFFILE-GET-NEXT` |
| 3 | `CBACT03C.FILE-STATUS-CHECK` | File Status Validation | VALIDATION | HIGH | `9910-DISPLAY-IO-STATUS` |

---

### CBACT04C — Interest Calculation Engine ★ MOST CRITICAL ★

**Function:** Calculates monthly interest for all accounts, posts transactions, resets cycle balances.
**Risk:** HIGH — contains core financial calculation formula. COMP-3 fields require BigDecimal in Java.

#### Business Rules

| # | Rule ID | Name | Type | Confidence | Paragraph | COBOL Source |
|---|---|---|---|---|---|---|
| 1 | `CBACT04C.SUCCESS-STATUS-CHECK` | Application Success Status Check | CONDITIONAL | HIGH | Multiple | `88 APPL-AOK VALUE 0.` `88 APPL-EOF VALUE 16.` |
| 2 | `CBACT04C.EOF-STATUS-CHECK` | End of File Status Detection | CONDITIONAL | HIGH | `1000-TCATBALF-GET-NEXT` | `IF TCATBALF-STATUS = '00' MOVE 0 TO APPL-RESULT ELSE IF TCATBALF-STATUS = '10' MOVE 16 TO APPL-RESULT` |
| 3 | `CBACT04C.FIRST-TIME-SKIP` | First Account Update Skip Rule | CONDITIONAL | HIGH | PROCEDURE DIVISION | `IF WS-FIRST-TIME NOT = 'Y' PERFORM 1050-UPDATE-ACCOUNT ELSE MOVE 'N' TO WS-FIRST-TIME END-IF` |
| 4 | `CBACT04C.ZERO-INTEREST-FILTER` | Zero Interest Rate Filter | CONDITIONAL | HIGH | PROCEDURE DIVISION | `IF DIS-INT-RATE NOT = 0 PERFORM 1300-COMPUTE-INTEREST PERFORM 1400-COMPUTE-FEES END-IF` |
| 5 | `CBACT04C.INTEREST-TRANSACTION-CLASSIFICATION` | Interest Transaction Type Assignment | CONDITIONAL | HIGH | `1300-B-WRITE-TX` | `MOVE '01' TO TRAN-TYPE-CD, MOVE '05' TO TRAN-CAT-CD, MOVE 'System' TO TRAN-SOURCE` |
| 6 | `CBACT04C.MONTHLY-INTEREST-CALCULATION` | Monthly Interest Computation Formula | CALCULATION | HIGH | `1300-COMPUTE-INTEREST` | `COMPUTE WS-MONTHLY-INT = ( TRAN-CAT-BAL * DIS-INT-RATE) / 1200` |
| 7 | `CBACT04C.TRANSACTION-ID-GENERATION` | Transaction Identifier Generation | CALCULATION | HIGH | `1300-B-WRITE-TX` | `ADD 1 TO WS-TRANID-SUFFIX STRING PARM-DATE, WS-TRANID-SUFFIX DELIMITED BY SIZE INTO TRAN-ID` |
| 8 | `CBACT04C.ACCOUNT-CHANGE-DETECTION` | Account Change Break Detection | ROUTING | HIGH | PROCEDURE DIVISION | `IF TRANCAT-ACCT-ID NOT= WS-LAST-ACCT-NUM IF WS-FIRST-TIME NOT = 'Y' PERFORM 1050-UPDATE-ACCOUNT END-IF MOVE 0 TO WS-TOTAL-INT` |
| 9 | `CBACT04C.SEQUENTIAL-PROCESSING-UNTIL-EOF` | Process All Records Until End of File | ROUTING | HIGH | PROCEDURE DIVISION | `PERFORM UNTIL END-OF-FILE = 'Y'` |
| 10 | `CBACT04C.DEFAULT-RATE-FALLBACK` | Default Interest Rate Fallback | ROUTING | HIGH | `1200-GET-INTEREST-RATE` | `IF DISCGRP-STATUS = '23' MOVE 'DEFAULT' TO FD-DIS-ACCT-GROUP-ID PERFORM 1200-A-GET-DEFAULT-INT-RATE` |
| 11 | `CBACT04C.ACCOUNT-BALANCE-UPDATE` | Account Balance Interest Posting | CALCULATION | HIGH | `1050-UPDATE-ACCOUNT` | `ADD WS-TOTAL-INT TO ACCT-CURR-BAL REWRITE FD-ACCTFILE-REC FROM ACCOUNT-RECORD` |
| 12 | `CBACT04C.CYCLE-BALANCE-RESET` | Current Cycle Balance Reset | THRESHOLD | HIGH | `1050-UPDATE-ACCOUNT` | `MOVE 0 TO ACCT-CURR-CYC-CREDIT MOVE 0 TO ACCT-CURR-CYC-DEBIT` |

#### Field-Level Traceability (GOVERNS)

| Rule | Field | Role | Meaning |
|---|---|---|---|
| MONTHLY-INTEREST-CALCULATION | `TRAN-CAT-BAL` | input | Category balance used in formula |
| MONTHLY-INTEREST-CALCULATION | `DIS-INT-RATE` | input | Discount interest rate used in formula |
| MONTHLY-INTEREST-CALCULATION | `WS-MONTHLY-INT` | output | Computed monthly interest result |
| ACCOUNT-BALANCE-UPDATE | `WS-TOTAL-INT` | input | Accumulated interest to post |
| ACCOUNT-BALANCE-UPDATE | `ACCT-CURR-BAL` | output | Account balance updated in VSAM |
| TRANSACTION-ID-GENERATION | `PARM-DATE` | input | Date prefix for transaction ID |
| TRANSACTION-ID-GENERATION | `WS-TRANID-SUFFIX` | counter | Auto-incrementing suffix |
| TRANSACTION-ID-GENERATION | `TRAN-ID` | output | Generated transaction identifier |
| INTEREST-TRANSACTION-CLASSIFICATION | `TRAN-TYPE-CD` | output | Set to '01' (interest type) |
| INTEREST-TRANSACTION-CLASSIFICATION | `TRAN-CAT-CD` | output | Set to '05' (interest category) |
| INTEREST-TRANSACTION-CLASSIFICATION | `TRAN-SOURCE` | output | Set to 'System' |
| ACCOUNT-CHANGE-DETECTION | `TRANCAT-ACCT-ID` | input | Current record account ID |
| ACCOUNT-CHANGE-DETECTION | `WS-LAST-ACCT-NUM` | state | Previous account for break comparison |
| ACCOUNT-CHANGE-DETECTION | `WS-TOTAL-INT` | state | Accumulated interest (reset on break) |
| CYCLE-BALANCE-RESET | `ACCT-CURR-CYC-CREDIT` | output | Reset to zero after posting |
| CYCLE-BALANCE-RESET | `ACCT-CURR-CYC-DEBIT` | output | Reset to zero after posting |
| ZERO-INTEREST-FILTER | `DIS-INT-RATE` | conditional | Tested > 0 before calculation |
| EOF-STATUS-CHECK | `TCATBALF-STATUS` | input | File status code tested |
| EOF-STATUS-CHECK | `END-OF-FILE` | output | Loop termination flag set |
| FIRST-TIME-SKIP | `WS-FIRST-TIME` | state | First-record guard flag |
| DEFAULT-RATE-FALLBACK | `DISCGRP-STATUS` | input | Status '23' triggers default lookup |
| DEFAULT-RATE-FALLBACK | `FD-DIS-ACCT-GROUP-ID` | output | Set to 'DEFAULT' group |
| SUCCESS-STATUS-CHECK | `APPL-RESULT` | output | Numeric result code |
| SUCCESS-STATUS-CHECK | `APPL-AOK` | conditional | 88-level: value = 0 means success |

#### Rule Execution Sequence & Dependencies

```
SEQUENTIAL-PROCESSING-UNTIL-EOF
    │ ORCHESTRATES
    ├──▶ EOF-STATUS-CHECK  ──DEPENDS_ON──▶  SUCCESS-STATUS-CHECK
    │       │ PRECEDES
    │       ▼
    │   ACCOUNT-CHANGE-DETECTION  ──GUARDED_BY──▶  FIRST-TIME-SKIP
    │       │ PRECEDES                    │ TRIGGERS
    │       ▼                             ▼
    │   DEFAULT-RATE-FALLBACK  ──PROVIDES_DATA_FOR──▶  MONTHLY-INTEREST-CALCULATION
    │       │ PRECEDES              │ PRECEDES               │
    │       ▼                      ▼                │ TRIGGERS
    │   ZERO-INTEREST-FILTER ──GUARDS──▶  [CALC]   │
    │                                              ▼
    │                               TRANSACTION-ID-GENERATION  ──PRECEDES──▶  ACCOUNT-BALANCE-UPDATE
    │                                    │ (PART_OF: INTEREST-TRANSACTION-CLASSIFICATION)        │
    │                                                                          │ (PART_OF: CYCLE-BALANCE-RESET)
    └──────────────────────────────────────────────────────────────────────────┘
```

**Critical path for Java migration:**
`DEFAULT-RATE-FALLBACK → ZERO-INTEREST-FILTER → MONTHLY-INTEREST-CALCULATION → TRANSACTION-ID-GENERATION → ACCOUNT-BALANCE-UPDATE`

---

### CBCUS01C — Customer File Processor

| # | Rule ID | Name | Type | Confidence | Paragraph |
|---|---|---|---|---|---|
| 1 | `CBCUS01C.CUSTFILE-READ` | Read Customer File Sequentially | DATA-ACCESS | HIGH | `1000-CUSTFILE-GET-NEXT` |
| 2 | `CBCUS01C.EOF-DETECTION` | End of File Detection | CONDITIONAL | HIGH | `1000-CUSTFILE-GET-NEXT` |
| 3 | `CBCUS01C.FILE-STATUS-CHECK` | File Status Validation | VALIDATION | HIGH | `9910-DISPLAY-IO-STATUS` |

---

### CBTRN01C — Daily Transaction Posting

| # | Rule ID | Name | Type | Confidence | Paragraph |
|---|---|---|---|---|---|
| 1 | `CBTRN01C.DAILY-TRANSACTION-POSTING` | Post Daily Transactions | CALCULATION | HIGH | `MAIN-PARA` |
| 2 | `CBTRN01C.TRANSACTION-FILE-WRITE` | Write Transaction Record | DATA-ACCESS | HIGH | `WRITE-TRANSACTION` |
| 3 | `CBTRN01C.MULTI-FILE-LOOKUP` | Multi-File Transaction Validation | VALIDATION | HIGH | `VALIDATE-TRANSACTION` |

---

### CBTRN02C — Transaction Processing

| # | Rule ID | Name | Type | Confidence |
|---|---|---|---|---|
| 1 | `CBTRN02C.TRANSACTION-PROCESSING` | Process Transaction File | CALCULATION | MEDIUM |

---

### CBTRN03C — Transaction Detail Report

> ⚠️ **Note for auditors:** Only 1 rule currently extracted (MEDIUM confidence — inferred). Direct source analysis of [CBTRN03C.cbl](../../aws-carddemo/app/cbl/CBTRN03C.cbl) reveals 6 additional unextracted rules (see below).

| # | Rule ID | Name | Type | Confidence |
|---|---|---|---|---|
| 1 | `CBTRN03C.TRANSACTION-REPORTING` | Generate Transaction Reports | CALCULATION | MEDIUM |

**Additional rules identified from source analysis (not yet in Neo4j — require extraction run):**

| # | Name | Type | Paragraph | COBOL Source |
|---|---|---|---|---|
| A | Date Range Filter | VALIDATION | PROCEDURE DIVISION | `IF TRAN-PROC-TS (1:10) >= WS-START-DATE AND TRAN-PROC-TS (1:10) <= WS-END-DATE` |
| B | Page Size Threshold (20 lines) | THRESHOLD | `1100-WRITE-TRANSACTION-REPORT` | `WS-PAGE-SIZE PIC 9(03) VALUE 20` / `IF FUNCTION MOD(WS-LINE-COUNTER, WS-PAGE-SIZE) = 0` |
| C | Account Break Detection | ROUTING | PROCEDURE DIVISION | `IF WS-CURR-CARD-NUM NOT= TRAN-CARD-NUM` |
| D | Card Cross-Reference Lookup | DATA-ACCESS | `1500-A-LOOKUP-XREF` | `READ XREF-FILE INVALID KEY PERFORM 9999-ABEND-PROGRAM` |
| E | Transaction Type Lookup | DATA-ACCESS | `1500-B-LOOKUP-TRANTYPE` | `READ TRANTYPE-FILE INVALID KEY PERFORM 9999-ABEND-PROGRAM` |
| F | Three-Level Amount Accumulation | CALCULATION | Multiple | `ADD TRAN-AMT TO WS-PAGE-TOTAL WS-ACCOUNT-TOTAL` / `ADD WS-PAGE-TOTAL TO WS-GRAND-TOTAL` |

---

### CBEXPORT / CBIMPORT — Data Export/Import

| # | Rule ID | Name | Program | Type | Confidence |
|---|---|---|---|---|---|
| 1 | `CBEXPORT.MULTI-FILE-EXPORT` | Multi-File Data Export | CBEXPORT | ROUTING | HIGH |
| 2 | `CBEXPORT.EXPORT-FILE-WRITE` | Write Export File with Sequence Numbers | CBEXPORT | DATA-ACCESS | HIGH |
| 3 | `CBEXPORT.MULTI-ENTITY-CONSOLIDATION` | Consolidate Multiple Entities | CBEXPORT | CALCULATION | MEDIUM |
| 4 | `CBIMPORT.MULTI-FILE-IMPORT` | Multi-File Data Import | CBIMPORT | ROUTING | HIGH |
| 5 | `CBIMPORT.EXPORT-FILE-READ` | Read Export File Sequentially | CBIMPORT | DATA-ACCESS | HIGH |
| 6 | `CBIMPORT.RECORD-TYPE-ROUTING` | Route Records by Type | CBIMPORT | ROUTING | MEDIUM |
| 7 | `CBIMPORT.VALIDATION-WITH-ERROR-OUTPUT` | Validation with Error File | CBIMPORT | VALIDATION | MEDIUM |

---

## Online / CICS Programs (CO prefix)

---

### COSGN00C — User Sign-On ★ SECURITY CRITICAL ★

| # | Rule ID | Name | Type | Confidence | Paragraph | COBOL Source |
|---|---|---|---|---|---|---|
| 1 | `COSGN00C.INITIAL-ENTRY` | Detect Initial Transaction Entry | CONDITIONAL | HIGH | `MAIN-PARA` | `IF EIBCALEN = 0 PERFORM SEND-SIGNON-SCREEN` |
| 2 | `COSGN00C.ERROR-FLAG-CHECK` | Error Flag Status Validation | CONDITIONAL | HIGH | `MAIN-PARA` | `88 ERR-FLG-ON VALUE Y` `88 ERR-FLG-OFF VALUE N` |
| 3 | `COSGN00C.USER-AUTHENTICATION` | User Credential Validation Against Security File | VALIDATION | HIGH | `READ-USER-SEC-FILE` | `EXEC CICS READ DATASET(WS-USRSEC-FILE) RIDFLD(WS-USER-ID)` |
| 4 | `COSGN00C.ACCESS-ROUTING` | Route User to Authorized Menu Based on Role | ROUTING | HIGH | `READ-USER-SEC-FILE` | `EXEC CICS XCTL PROGRAM(COADM01C) or PROGRAM(COMEN01C)` |
| 5 | `COSGN00C.SCREEN-DISPLAY` | Display Signon Screen with BMS Map | DATA-ACCESS | HIGH | `SEND-SIGNON-SCREEN` | `EXEC CICS SEND MAP(COSGN0A) MAPSET(COSGN00) ERASE` |

**Traceability notes:**
- Rule 3 (`USER-AUTHENTICATION`) → maps to Spring Security `UserDetailsService.loadUserByUsername()`
- Rule 4 (`ACCESS-ROUTING`) → maps to Spring Security role-based `hasRole('ADMIN')` / `hasRole('USER')` checks

---

### COMEN01C — Main Menu

| # | Rule ID | Name | Type | Confidence | Paragraph |
|---|---|---|---|---|---|
| 1 | `COMEN01C.MENU-NAVIGATION` | Main Menu Navigation | ROUTING | HIGH | `MAIN-PARA` |
| 2 | `COMEN01C.ERROR-FLAG-CHECK` | Error Flag Validation | CONDITIONAL | HIGH | `MAIN-PARA` |
| 3 | `COMEN01C.SCREEN-DISPLAY` | Display Menu Screen | DATA-ACCESS | HIGH | `SEND-MENU-SCREEN` |

---

### COACTUPC / COACTVWC — Account Update / View

| # | Rule ID | Name | Type | Confidence |
|---|---|---|---|---|
| 1 | `COACTUPC.ACCOUNT-UPDATE` | Update Account Information | DATA-ACCESS | HIGH |
| 2 | `COACTUPC.CREDIT-LIMIT-VALIDATION` | Validate Credit Limit Changes | VALIDATION | MEDIUM |
| 3 | `COACTVWC.ACCOUNT-DETAIL-DISPLAY` | Display Account Details | DATA-ACCESS | HIGH |

---

### COTRN00C / COTRN01C / COTRN02C — Transaction Management

| # | Rule ID | Name | Type | Confidence |
|---|---|---|---|---|
| 1 | `COTRN00C.TRANSACTION-LIST-DISPLAY` | Display Transaction List | DATA-ACCESS | HIGH |
| 2 | `COTRN01C.TRANSACTION-DETAIL-VIEW` | View Transaction Detail | DATA-ACCESS | HIGH |
| 3 | `COTRN02C.TRANSACTION-CREATION` | Create New Transaction | DATA-ACCESS | HIGH |
| 4 | `COTRN02C.DATE-VALIDATION` | Validate Transaction Dates | VALIDATION | HIGH |

---

### COCRDLIC / COCRDSLC / COCRDUPC — Card Management

| # | Rule ID | Name | Type | Confidence |
|---|---|---|---|---|
| 1 | `COCRDLIC.CARD-LIST-BROWSE` | Browse Card List | DATA-ACCESS | HIGH |
| 2 | `COCRDSLC.CARD-SELECTION-ROUTING` | Card Selection and Routing | ROUTING | HIGH |
| 3 | `COCRDUPC.CARD-UPDATE` | Update Card Information | DATA-ACCESS | HIGH |

---

### COUSR00C / 01C / 02C / 03C — User Management

| # | Rule ID | Name | Type | Confidence |
|---|---|---|---|---|
| 1 | `COUSR00C.USER-BROWSE` | Browse User List | DATA-ACCESS | HIGH |
| 2 | `COUSR00C.USER-LIST-DISPLAY` | Display Paginated User List | ROUTING | HIGH |
| 3 | `COUSR00C.EOF-DETECTION` | End of User File Detection | CONDITIONAL | HIGH |
| 4 | `COUSR01C.USER-CREATION` | Create New User | DATA-ACCESS | HIGH |
| 5 | `COUSR01C.USER-VALIDATION` | Validate New User Data | VALIDATION | MEDIUM |
| 6 | `COUSR02C.USER-READ-FOR-UPDATE` | Read User for Update | DATA-ACCESS | HIGH |
| 7 | `COUSR02C.USER-UPDATE` | Update Existing User | DATA-ACCESS | HIGH |
| 8 | `COUSR03C.USER-DELETION` | Delete User | DATA-ACCESS | HIGH |
| 9 | `COUSR03C.DELETION-CONFIRMATION` | Confirm User Deletion | VALIDATION | MEDIUM |

---

### COBIL00C — Bill Payment

| # | Rule ID | Name | Type | Confidence |
|---|---|---|---|---|
| 1 | `COBIL00C.BILL-PAYMENT-PROCESSING` | Process Bill Payment | CALCULATION | HIGH |

---

### CORPT00C — Reporting

| # | Rule ID | Name | Type | Confidence |
|---|---|---|---|---|
| 1 | `CORPT00C.TRANSACTION-REPORT-GENERATION` | Generate Transaction Reports | CALCULATION | MEDIUM |

---

### COADM01C — Admin

| # | Rule ID | Name | Type | Confidence |
|---|---|---|---|---|
| 1 | `COADM01C.ADMIN-MENU-NAVIGATION` | Admin Menu Navigation | ROUTING | HIGH |

---

## Utility Programs

---

### CSUTLDTC — Date Validation Utility

| # | Rule ID | Name | Type | Confidence | Paragraph | COBOL Source |
|---|---|---|---|---|---|---|
| 1 | `CSUTLDTC.DATE-MASK-APPLICATION` | Apply Date Format Mask for Validation | CALCULATION | HIGH | `A000-MAIN` | `CALL CEEDAYS USING WS-DATE-TO-TEST WS-DATE-FORMAT OUTPUT-LILLIAN FEEDBACK-CODE` |
| 2 | `CSUTLDTC.LILLIAN-CONVERSION` | Convert Valid Date to Lillian Format | CALCULATION | HIGH | `A000-MAIN` | `OUTPUT-LILLIAN PIC S9(9) BINARY` |
| 3 | `CSUTLDTC.INVALID-DATE-CHECK` | Detect Invalid Date Format | VALIDATION | HIGH | `A000-MAIN` | `88 FC-INVALID-DATE VALUE X-0000000000000000` |

**Traceability notes:**
- CSUTLDTC is called by `COTRN02C.DATE-VALIDATION` — shared utility. Maps to `java.time.LocalDate.parse()` with custom format mask.

---

## DB2 Programs

| # | Rule ID | Name | Program | Type | Confidence |
|---|---|---|---|---|---|
| 1 | `COTRTLIC.DB2-TRANSACTION-TYPE-LIST` | List Transaction Types from DB2 | COTRTLIC | DATA-ACCESS | MEDIUM |
| 2 | `COTRTUPC.DB2-TRANSACTION-TYPE-MAINTENANCE` | Maintain Transaction Types in DB2 | COTRTUPC | DATA-ACCESS | MEDIUM |
| 3 | `COBTUPDT.DB2-TRANSACTION-TYPE-UPDATE` | Update Transaction Types in DB2 | COBTUPDT | DATA-ACCESS | MEDIUM |

---

## MQ / Authorisation Programs

| # | Rule ID | Name | Program | Type | Confidence |
|---|---|---|---|---|---|
| 1 | `CBPAUP0C.AUTHORIZATION-BATCH-PROCESSING` | Batch Authorization Processing | CBPAUP0C | CALCULATION | MEDIUM |
| 2 | `COPAUA0C.MQ-AUTHORIZATION-DISPLAY` | Display MQ Authorization Requests | COPAUA0C | DATA-ACCESS | MEDIUM |
| 3 | `COPAUS0C.MQ-AUTHORIZATION-LIST` | List MQ Authorization Requests | COPAUS0C | DATA-ACCESS | MEDIUM |
| 4 | `COPAUS1C.MQ-AUTHORIZATION-APPROVAL` | Approve MQ Authorization | COPAUS1C | ROUTING | MEDIUM |
| 5 | `COPAUS2C.MQ-AUTHORIZATION-REJECTION` | Reject MQ Authorization | COPAUS2C | ROUTING | MEDIUM |
| 6 | `COACCT01.VSAM-ACCOUNT-MQ-ACCESS` | VSAM Account Access with MQ | COACCT01 | DATA-ACCESS | MEDIUM |
| 7 | `CODATE01.DATE-UTILITY-SERVICE` | Date Utility Service | CODATE01 | VALIDATION | MEDIUM |
| 8 | `COBSWAIT.BATCH-SYNCHRONIZATION` | Batch Job Synchronization | COBSWAIT | ROUTING | MEDIUM |

---

## Auditor Sign-Off Checklist

### Rules Requiring Business Owner Confirmation

| Rule ID | Reason | Action Required |
|---|---|---|
| `CBACT01C.DEFAULT-DEBIT-VALUE` | Hard-coded $2,525.00 default — is this still the correct business value? | Business owner must confirm |
| `CBACT04C.MONTHLY-INTEREST-CALCULATION` | Core financial formula `(BAL × RATE) / 1200` — confirm annualised monthly divisor | Finance team sign-off |
| `CBACT04C.CYCLE-BALANCE-RESET` | Resets credit/debit cycle balances to zero — confirm timing in billing cycle | Finance team sign-off |
| `CBACT04C.INTEREST-TRANSACTION-CLASSIFICATION` | Interest transactions hard-coded as type='01', category='05', source='System' — confirm these codes | Data team sign-off |
| `COACTUPC.CREDIT-LIMIT-VALIDATION` | MEDIUM confidence — exact limit thresholds not yet extracted | COBOL SME to verify |
| `CBTRN03C.*` (rules A–F above) | Rules identified from source but not yet in Neo4j graph | Re-run `@business-rule-extractor` |

### Rules Requiring SME Review (MEDIUM confidence)

The following 18 rules were inferred from structural patterns, not directly extracted. A COBOL SME should verify each description before using in a requirements matrix:

`CBEXPORT.MULTI-ENTITY-CONSOLIDATION`, `CBIMPORT.RECORD-TYPE-ROUTING`, `CBIMPORT.VALIDATION-WITH-ERROR-OUTPUT`, `CBTRN02C.TRANSACTION-PROCESSING`, `CBTRN03C.TRANSACTION-REPORTING`, `COACTUPC.CREDIT-LIMIT-VALIDATION`, `CBPAUP0C.AUTHORIZATION-BATCH-PROCESSING`, all MQ/authorization program rules (6), `COUSR01C.USER-VALIDATION`, `COUSR03C.DELETION-CONFIRMATION`, `CODATE01.DATE-UTILITY-SERVICE`

### Ready for Traceability Matrix (HIGH confidence)
**67 of 85 rules (79%)** — can be used directly as input to user stories and acceptance criteria without further COBOL SME review.

---

*Generated from Neo4j LegacyCobolInsights graph. Re-run `@business-rule-extractor` against `aws-carddemo/` to complete extraction for all programs.*
