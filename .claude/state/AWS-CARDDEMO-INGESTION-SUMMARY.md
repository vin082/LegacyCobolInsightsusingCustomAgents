# AWS CardDemo COBOL Ingestion Summary

**Generated:** 2026-03-03  
**Repository:** AWS Mainframe Modernization CardDemo  
**Source:** https://github.com/aws-samples/aws-mainframe-modernization-carddemo  
**Manifest Location:** `.claude/state/ingestion-manifest.json`

---

## Executive Summary

Successfully ingested **148 files** from the AWS CardDemo application, a production-scale mainframe demo application featuring multiple technology stacks (CICS, Batch, DB2, IMS, MQ) and architectural variants.

This represents a **20x scale increase** from the previous 4-program test system to a realistic enterprise COBOL portfolio.

---

## File Inventory

| Category | Count | Description |
|----------|-------|-------------|
| **COBOL Programs** | 39 | Batch programs, CICS online transactions, utilities |
| **Copybooks** | 51 | Data structures, view definitions, BMS-generated copybooks |
| **JCL Scripts** | 39 | Job control language for batch processing |
| **BMS Maps** | 19 | CICS screen definitions |
| **TOTAL** | **148** | Complete application portfolio |

---

## Program Classification

### By Technology Type

| Type | Count | Examples |
|------|-------|----------|
| **CICS Online** | 27 | COSGN00C (signon), COMEN01C (menu), COUSR00C-03C (user mgmt), COACTVWC/COACTUPC (account), COCRDLIC/COCRDUPC (card), COTRN00C-02C (transactions) |
| **Batch** | 10 | CBACT01C-04C (account batch), CBCUS01C (customer batch), CBIMPORT/CBEXPORT (import/export), CBTRN01C-03C (transaction batch) |
| **Utility** | 2 | CSUTLDTC (date utility), CODATE01 (date conversion) |

### By Business Function

| Function | Programs | Description |
|----------|----------|-------------|
| **Account Management** | 7 | CBACT01C-04C (batch), COACTVWC, COACTUPC, COACCT01 |
| **Customer Management** | 1 | CBCUS01C |
| **Card Management** | 3 | COCRDLIC, COCRDUPC, COCRDSLC |
| **Transaction Processing** | 6 | CBTRN01C-03C (batch), COTRN00C-02C (CICS) |
| **User Administration** | 4 | COUSR00C-03C |
| **Billing** | 1 | COBIL00C |
| **Reports** | 1 | CORPT00C |
| **Signon/Menu** | 2 | COSGN00C, COMEN01C |
| **Admin** | 1 | COADM01C |
| **Authorization** | 5 | COPAUS0C-2C, COPAUA0C, CBPAUP0C (IMS/DB2/MQ variant) |
| **Transaction Type** | 3 | COTRTUPC, COTRTLIC, COBTUPDT (DB2 variant) |
| **Utilities** | 5 | CSUTLDTC, CODATE01, COBSWAIT, CBIMPORT, CBEXPORT |

---

## Architectural Variants

The CardDemo application demonstrates **multiple mainframe technology stacks**:

### 1. **Core Application (CICS + VSAM)**
- **Location:** `app/cbl/`, `app/cpy/`, `app/jcl/`, `app/bms/`
- **Programs:** 29 COBOL programs
- **Copybooks:** 29 copybooks
- **Technology:** CICS transaction processing, VSAM file access

### 2. **DB2 Variant (Transaction Types)**
- **Location:** `app/app-transaction-type-db2/`
- **Programs:** 3 (COTRTUPC, COTRTLIC, COBTUPDT)
- **Copybooks:** 4 (CSDB2RWY, CSDB2RPY, plus BMS copybooks)
- **Technology:** CICS + embedded SQL/DB2

### 3. **IMS/DB2/MQ Variant (Authorization)**
- **Location:** `app/app-authorization-ims-db2-mq/`
- **Programs:** 5 (COPAUS0C-2C, COPAUA0C, CBPAUP0C)
- **Copybooks:** 8 (including IMS DLI and MQ message structures)
- **Technology:** CICS + IMS DL/I + DB2 + MQ messaging

### 4. **VSAM/MQ Variant**
- **Location:** `app/app-vsam-mq/`
- **Programs:** 2 (COACCT01, CODATE01)
- **Technology:** VSAM + MQ messaging

---

## Technology Stack Analysis

### File Organizations Detected
- **INDEXED** (VSAM KSDS)
- **SEQUENTIAL** (flat files)
- **ESDS** (Entry-Sequenced Data Set)
- **RRDS** (Relative Record Data Set)
- **GDG** (Generation Data Groups)

### CICS Features Used
- **BMS Maps** (screen formatting)
- **EXEC CICS** commands (transaction control)
- **Commarea** (data passing between programs)
- **File Control** (READ, WRITE, REWRITE, DELETE)
- **Terminal Control** (SEND MAP, RECEIVE MAP)

### Database Access
- **DB2:** Embedded SQL (EXEC SQL)
- **IMS:** DL/I calls (GU, GN, ISRT, DLET, REPL)
- **VSAM:** Direct file I/O

### Messaging
- **MQ Series:** Message queue operations
- **IMS Transaction Manager:** Message-based processing

---

## Sample Programs Analyzed

### CBACT01C - Account Batch Processor
- **Type:** BATCH COBOL
- **Lines:** 431
- **Function:** Read ACCOUNT file (INDEXED) and write to multiple files (SEQUENTIAL)
- **Complexity:** MODERATE
- **File I/O:**
  - ACCTFILE (INDEXED, ACCESS SEQUENTIAL, KEY: FD-ACCT-ID)
  - OUTFILE (SEQUENTIAL)
  - ARRYFILE (SEQUENTIAL)
  - VBRCFILE (SEQUENTIAL)

### COSGN00C - Signon Screen
- **Type:** CICS COBOL
- **Lines:** 261
- **Function:** User authentication screen for CardDemo application
- **Complexity:** LOW
- **CICS Features:**
  - BMS map: COSGN00
  - SEND MAP, RECEIVE MAP
  - Security file access: WS-USRSEC-FILE
  - Transaction ID: CC00
- **Copybooks:** COCOM01Y, COSGN00

### CUSTREC.cpy - Customer Entity
- **Type:** COPYBOOK
- **Record Length:** 500 bytes
- **Fields:** 19 (CUST-ID, names, address, SSN, FICO-CREDIT-SCORE, etc.)
- **Version:** CardDemo_v1.0-15-g27d6c6f-68 (2022-07-19)

---

## Copybook Categorization

### Data Structures (Entities)
- **CUSTREC** - Customer master record
- **CVCUS01Y** - Customer view
- **CVACT01Y-07Y** - Account views (7 variants)
- **CVCRD01Y** - Card view
- **CVTRA01Y-07Y** - Transaction views (7 variants)

### Common/Shared Structures
- **COCOM01Y** - Common communication area
- **COADM02Y** - Admin common area
- **COMEN02Y** - Menu communication area

### Utility Copybooks
- **CSUTLDWY** - Date/time working storage
- **CSUTLDPY** - Date/time parameters
- **CSSTRPFY** - String strip function
- **CSSETATY** - Set attribute function
- **CSMSG01Y, CSMSG02Y** - Message structures
- **CSLKPCDY** - Lockup code
- **CSDAT01Y** - Date structure
- **CODATECN** - Date conversion

### BMS-Generated Copybooks
- **COSGN00, COADM01, COMEN01** - Screen map copybooks
- **COUSR00-03, COACTUP, COACTVW** - Transaction screen copybooks
- **COCRDLI, COCRDUP, COCRDSL** - Card screen copybooks
- **COTRN00-02, CORPT00, COBIL00** - Transaction/report screen copybooks

### DB2/IMS Structures
- **CSDB2RWY, CSDB2RPY** - DB2 response/request structures
- **CIPAUSMY, CIPAUDTY** - IMS authorization message structures
- **CCPAURQY, CCPAURLY, CCPAUERY** - IMS authorization request/reply/error
- **IMSFUNCS** - IMS function codes

---

## JCL Job Categories

### File Definitions
- ACCTFILE, CARDFILE, CUSTFILE, TRANFILE, XREFFILE, REPTFILE, TRANTYPE, TRANCATG, TRANIDX

### Batch Processing Jobs
- **CBIMPORT** - Import data
- **CBEXPORT** - Export data
- **INTCALC** - Interest calculation
- **POSTTRAN** - Post transactions
- **COMBTRAN** - Combine transactions
- **TRANREPT** - Transaction reports
- **TRANBKP** - Transaction backup
- **DALYREJS** - Daily rejects processing

### File Management
- **OPENFIL/CLOSEFIL** - Open/close file utilities
- **DEFCUST** - Define customer file
- **DEFGDGB/DEFGDGD** - GDG (Generation Data Group) definitions
- **ESDSRRDS** - ESDS/RRDS file definitions
- **DISCGRP** - Disconnect group

### Utilities
- **READXREF, READCUST, READCARD, READACCT** - Read file utilities
- **WAITSTEP** - Wait step utility
- **PRTCATBL** - Print category table
- **TCATBALF** - Transaction category balance file

### DB2/IMS Jobs
- **TRANEXTR** - Transaction extraction (DB2)
- **MNTTRDB2** - Maintain transaction DB2
- **CREADB21** - Create DB2 objects
- **DBPAUTP0** - DB2 authorization
- **CBPAUP0J** - IMS authorization batch job

### Sample Compilation/Test Jobs
- CICCMP, CICDBCMP, IMSMQCMP, BATCMP, BMSCMP, RACFCMDS, LISTCAT, REPRTEST, SORTTEST

---

## BMS Screen Maps

### User Interface Screens
| Screen | Function |
|--------|----------|
| **COSGN00** | Signon/authentication |
| **COMEN01** | Main menu |
| **COADM01** | Administration menu |
| **COUSR00-03** | User management (list/add/update/delete) |
| **COACTVW** | Account view |
| **COACTUP** | Account update |
| **COCRDLI** | Card list |
| **COCRDUP** | Card update |
| **COCRDSL** | Card select |
| **COTRN00-02** | Transaction entry/list/detail |
| **CORPT00** | Reports menu |
| **COBIL00** | Billing inquiry |

### Variant Screens
| Screen | Variant | Function |
|--------|---------|----------|
| **COTRTUP** | DB2 | Transaction type update |
| **COTRTLI** | DB2 | Transaction type list |
| **COPAU00** | IMS/MQ | Authorization inquiry |
| **COPAU01** | IMS/MQ | Authorization response |

---

## Migration Complexity Assessment

### Estimated Complexity by Program Type

| Complexity | Program Count | Characteristics |
|------------|---------------|-----------------|
| **LOW** (20-30 points) | ~8 | Utility programs, simple screens: CSUTLDTC, CODATE01, COBSWAIT, COSGN00C, COMEN01C |
| **MODERATE** (30-50) | ~15 | Standard CICS screens, simple batch: COUSR00C-03C, CBACT01C, CBCUS01C, CBIMPORT/CBEXPORT |
| **HIGH** (50-70) | ~10 | Complex batch, multi-file I/O: CBTRN01C-03C, COACTVWC, COACTUPC, COCRDLIC, COCRDUPC, COTRN00C-02C |
| **VERY HIGH** (70+) | ~6 | DB2/IMS variants: COTRTUPC, COTRTLIC, COPAUS0C-2C, COPAUA0C, CBPAUP0C |

### Migration Risk Factors

**HIGH RISK (VERY_HARD):**
- IMS DL/I database calls - no direct Java equivalent
- MQ Series messaging - requires ActiveMQ/RabbitMQ/Kafka conversion
- Embedded SQL/DB2 - requires JPA/Hibernate conversion
- EXEC CICS commands - requires web framework conversion

**MEDIUM RISK (HARD):**
- Complex batch with multiple file I/O
- BMS map rendering - requires UI framework conversion
- VSAM INDEXED file access - requires database conversion
- COMMAREA data passing - requires session management

**LOW RISK (MODERATE/EASY):**
- Utility programs with minimal I/O
- Simple screen programs
- Sequential file processing
- Date/time calculations

---

## Recommended Processing Order

### Phase 1: Foundation (Copybooks & Utilities)
1. Parse all 51 copybooks - define data structures in Neo4j
2. Migrate utility programs: CSUTLDTC, CODATE01 (LOW complexity)

### Phase 2: Core CICS Screens
3. Migrate signon: COSGN00C (EASY - 261 lines)
4. Migrate menu: COMEN01C (EASY)
5. Migrate user management: COUSR00C-03C (MODERATE)

### Phase 3: Batch Processing
6. Migrate simple batch: CBCUS01C (MODERATE)
7. Migrate account batch: CBACT01C-04C (MODERATE-HIGH)
8. Migrate transaction batch: CBTRN01C-03C (HIGH)

### Phase 4: Complex CICS Transactions
9. Migrate account screens: COACTVWC, COACTUPC (HIGH)
10. Migrate card screens: COCRDLIC, COCRDUPC, COCRDSLC (HIGH)
11. Migrate transaction screens: COTRN00C-02C (HIGH)

### Phase 5: Advanced Features
12. Migrate reports: CORPT00C (HIGH)
13. Migrate billing: COBIL00C (HIGH)
14. Migrate admin: COADM01C (MODERATE)

### Phase 6: Technology Variants (DEFER)
15. DB2 variant programs (VERY HIGH - requires SQL conversion)
16. IMS/MQ variant programs (VERY HIGH - requires messaging architecture)

---

## Next Steps for Migration Pipeline

### Immediate Actions (Priority 1)

1. **Load Manifest into Neo4j**
   - Create Program nodes (39 nodes)
   - Create Copybook nodes (51 nodes)
   - Create JCL nodes (39 nodes)
   - Create BMS nodes (19 nodes)
   - **Total: 148 nodes**

2. **Parse COBOL Source**
   - Extract PROGRAM-ID, AUTHOR, DATE-WRITTEN for all programs
   - Identify all COPY statements to build dependency graph
   - Extract paragraph names to build control flow
   - **Expected: 300+ paragraph nodes, 150+ relationships**

3. **Build Dependency Graph**
   - PROGRAM -[:INCLUDES]-> COPYBOOK relationships
   - PROGRAM -[:CALLS]-> PROGRAM relationships (if any)
   - PROGRAM -[:USES_MAP]-> BMS relationships
   - JCL -[:EXECUTES]-> PROGRAM relationships

4. **Calculate Complexity Scores**
   - Run complexity-scorer on all 39 programs
   - Metrics: LOC, cyclomatic complexity, GOTO count, file I/O, CICS/DB2/IMS penalties
   - Classify: EASY (20-30), MODERATE (30-50), HARD (50-70), VERY_HARD (70+)

### Short-Term Actions (Priority 2)

5. **Wave Allocation**
   - Wave 1 (Foundation): Copybooks + 2 utility programs
   - Wave 2 (Core CICS): 5 simple screens (signon, menu, user mgmt)
   - Wave 3 (Batch): 5 batch programs (customer, account, transaction)
   - Wave 4 (Complex CICS): 8 transactional screens (account, card, transaction)
   - Wave 5 (Advanced): 3 programs (reports, billing, admin)
   - Wave 6 (Deferred): 6 variant programs (DB2, IMS/MQ)

6. **Test Migration-Conductor Orchestrator**
   - Select CSUTLDTC (date utility, LOW complexity, ~150 lines)
   - Invoke migration-conductor: "Migrate CSUTLDTC to Spring Boot"
   - Verify orchestrator coordinates: impact-analyzer → migration-advisor → documentation-generator
   - Validate generated Java code compiles and tests pass

### Medium-Term Actions (Priority 3)

7. **Migrate 1 Program Per Wave (Proof of Concept)**
   - Wave 1: CSUTLDTC (utility)
   - Wave 2: COSGN00C (signon screen)
   - Wave 3: CBCUS01C (customer batch)
   - Wave 4: COACTVWC (account view screen)
   - Wave 5: CORPT00C (reports)
   - Wave 6: SKIP (DB2/IMS require architectural decisions)

8. **Quality Validation**
   - Compare auto-generated code vs manual migration (ACCOUNT-MGR baseline)
   - Unit test coverage: 80% minimum
   - Integration test: End-to-end transaction flow
   - Performance test: Throughput comparison (mainframe vs Spring Boot)

---

## Files Generated by Ingestion

1. **`.claude/state/ingestion-manifest.json`**
   - Complete inventory of 148 files
   - File metadata (type, program_id, size, lines, status)
   - Technology classification (BATCH, CICS, UTILITY)
   - Architectural variants (core, DB2, IMS/MQ, VSAM/MQ)

2. **`.claude/state/AWS-CARDDEMO-INGESTION-SUMMARY.md`** (this file)
   - Executive summary
   - File inventory and classification
   - Technology stack analysis
   - Complexity assessment
   - Recommended processing order

---

## Success Metrics

✅ **148 files discovered** (100% coverage)  
✅ **39 COBOL programs cataloged** (all programs identified)  
✅ **51 copybooks cataloged** (all copybooks identified)  
✅ **4 architectural variants mapped** (core, DB2, IMS/MQ, VSAM/MQ)  
✅ **3 sample files analyzed** (CBACT01C, COSGN00C, CUSTREC.cpy)  
✅ **JSON manifest created** (ready for Neo4j loading)  

🔄 **Next: Parse COBOL source and build knowledge graph** (Phase 1 complete, Phase 2 pending)

---

## Comparison: Test System vs CardDemo

| Metric | Test System | CardDemo | Scale Factor |
|--------|-------------|----------|--------------|
| Total Files | 7 | 148 | **21x** |
| COBOL Programs | 4 | 39 | **10x** |
| Copybooks | 3 | 51 | **17x** |
| Lines of Code | ~400 | ~10,000+ | **25x** |
| Technology Stacks | 1 (Batch) | 6 (CICS, VSAM, DB2, IMS, MQ, BMS) | **6x** |
| Architectural Variants | 0 | 4 | **n/a** |

**Conclusion:** AWS CardDemo provides a **production-realistic test** for the migration-conductor orchestrator, validating the pipeline on enterprise-scale complexity (CICS, DB2, IMS, MQ) rather than simple batch programs.

---

**END OF INGESTION SUMMARY**
