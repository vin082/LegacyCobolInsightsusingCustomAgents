// ============================================================================
// COBOL Modernization Knowledge Graph - Neo4j Build Script
// Generated: 2026-02-28
// ============================================================================

// Step 1: Create Copybooks and their Data Items
// ============================================================================

// CUSTOMER-RECORD Copybook
MERGE (cb:Copybook {name: 'CUSTOMER-RECORD'})
SET cb.source_path = 'cobol-modernization/sample-cobol/copybooks/CUSTOMER-RECORD.cpy',
    cb.parsed_at = '2026-02-28T00:00:00Z',
    cb.data_item_count = 5;

MERGE (di:DataItem {fqn: 'CUSTOMER-RECORD.CUST-ID', name: 'CUST-ID'})
SET di.level = '05', di.pic = '9(8)', di.has_redefines = false, di.has_occurs = false
MERGE (cb:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

MERGE (di:DataItem {fqn: 'CUSTOMER-RECORD.CUST-NAME', name: 'CUST-NAME'})
SET di.level = '05', di.pic = 'X(40)', di.has_redefines = false, di.has_occurs = false
MERGE (cb:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

MERGE (di:DataItem {fqn: 'CUSTOMER-RECORD.CUST-STATUS', name: 'CUST-STATUS'})
SET di.level = '05', di.pic = 'X', di.has_redefines = false, di.has_occurs = false, di.has_condition_names = true
MERGE (cb:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

MERGE (di:DataItem {fqn: 'CUSTOMER-RECORD.CUST-BALANCE', name: 'CUST-BALANCE'})
SET di.level = '05', di.pic = 'S9(9)V99', di.has_redefines = false, di.has_occurs = false
MERGE (cb:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

MERGE (di:DataItem {fqn: 'CUSTOMER-RECORD.CUST-OPEN-DATE', name: 'CUST-OPEN-DATE'})
SET di.level = '05', di.pic = '9(8)', di.has_redefines = false, di.has_occurs = false
MERGE (cb:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

// ACCOUNT-RECORD Copybook
MERGE (cb:Copybook {name: 'ACCOUNT-RECORD'})
SET cb.source_path = 'cobol-modernization/sample-cobol/copybooks/ACCOUNT-RECORD.cpy',
    cb.parsed_at = '2026-02-28T00:00:00Z',
    cb.data_item_count = 7;

MERGE (di:DataItem {fqn: 'ACCOUNT-RECORD.ACCT-ID', name: 'ACCT-ID'})
SET di.level = '05', di.pic = '9(10)', di.has_redefines = false, di.has_occurs = false
MERGE (cb:Copybook {name: 'ACCOUNT-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

MERGE (di:DataItem {fqn: 'ACCOUNT-RECORD.ACCT-BALANCE', name: 'ACCT-BALANCE'})
SET di.level = '05', di.pic = 'S9(11)V99', di.usage = 'COMP-3', di.has_redefines = false, di.has_occurs = false
MERGE (cb:Copybook {name: 'ACCOUNT-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

MERGE (di:DataItem {fqn: 'ACCOUNT-RECORD.ACCT-LIMIT', name: 'ACCT-LIMIT'})
SET di.level = '05', di.pic = 'S9(9)V99', di.usage = 'COMP-3', di.has_redefines = false, di.has_occurs = false
MERGE (cb:Copybook {name: 'ACCOUNT-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

// PAYMENT-RECORD Copybook
MERGE (cb:Copybook {name: 'PAYMENT-RECORD'})
SET cb.source_path = 'cobol-modernization/sample-cobol/copybooks/PAYMENT-RECORD.cpy',
    cb.parsed_at = '2026-02-28T00:00:00Z',
    cb.data_item_count = 7;

MERGE (di:DataItem {fqn: 'PAYMENT-RECORD.PAY-AMOUNT', name: 'PAY-AMOUNT'})
SET di.level = '05', di.pic = 'S9(9)V99', di.usage = 'COMP-3', di.has_redefines = false, di.has_occurs = false
MERGE (cb:Copybook {name: 'PAYMENT-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

MERGE (di:DataItem {fqn: 'PAYMENT-RECORD.PAY-TYPE', name: 'PAY-TYPE'})
SET di.level = '05', di.pic = 'X(10)', di.has_redefines = false, di.has_occurs = false, di.has_condition_names = true
MERGE (cb:Copybook {name: 'PAYMENT-RECORD'})
MERGE (cb)-[:DEFINES]->(di);

// Step 2: Create Programs
// ============================================================================

MERGE (p:Program {program_id: 'CUSTOMER-PROC'})
SET p.source_path = 'cobol-modernization/sample-cobol/CUSTOMER-PROC.cbl',
    p.author = 'J.SMITH',
    p.date_written = '1987-03-15',
    p.has_goto = false,
    p.has_alter = false,
    p.has_redefines = false,
    p.estimated_complexity = 'LOW',
    p.line_count = 58,
    p.parsed_at = '2026-02-28T00:00:00Z';

MERGE (p:Program {program_id: 'BATCH-RUNNER'})
SET p.source_path = 'cobol-modernization/sample-cobol/BATCH-RUNNER.cbl',
    p.author = 'D.WILSON',
    p.date_written = '1995-02-14',
    p.has_goto = false,
    p.has_alter = false,
    p.has_redefines = false,
    p.estimated_complexity = 'LOW',
    p.line_count = 124,
    p.parsed_at = '2026-02-28T00:00:00Z';

MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
SET p.source_path = 'cobol-modernization/sample-cobol/ACCOUNT-MGR.cbl',
    p.author = 'M.JONES',
    p.date_written = '1989-07-22',
    p.has_goto = false,
    p.has_alter = false,
    p.has_redefines = false,
    p.estimated_complexity = 'MEDIUM',
    p.line_count = 116,
    p.parsed_at = '2026-02-28T00:00:00Z';

MERGE (p:Program {program_id: 'PAYMENT-HANDLER'})
SET p.source_path = 'cobol-modernization/sample-cobol/PAYMENT-HANDLER.cbl',
    p.author = 'S.PATEL',
    p.date_written = '1992-11-03',
    p.has_goto = true,
    p.has_alter = false,
    p.has_redefines = false,
    p.estimated_complexity = 'MEDIUM',
    p.line_count = 119,
    p.parsed_at = '2026-02-28T00:00:00Z';

// Step 3: Create Paragraphs and CONTAINS relationships
// ============================================================================

// CUSTOMER-PROC paragraphs
MERGE (para:Paragraph {fqn: 'CUSTOMER-PROC.0000-MAIN', name: '0000-MAIN'})
SET para.line_start = 32, para.line_end = 36, para.line_count = 4
MERGE (p:Program {program_id: 'CUSTOMER-PROC'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CUSTOMER-PROC.1000-OPEN-FILES', name: '1000-OPEN-FILES'})
SET para.line_start = 38, para.line_end = 41, para.line_count = 3
MERGE (p:Program {program_id: 'CUSTOMER-PROC'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CUSTOMER-PROC.1100-READ-CUSTOMER', name: '1100-READ-CUSTOMER'})
SET para.line_start = 43, para.line_end = 46, para.line_count = 3
MERGE (p:Program {program_id: 'CUSTOMER-PROC'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CUSTOMER-PROC.2000-PROCESS-CUSTOMERS', name: '2000-PROCESS-CUSTOMERS'})
SET para.line_start = 48, para.line_end = 50, para.line_count = 2
MERGE (p:Program {program_id: 'CUSTOMER-PROC'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CUSTOMER-PROC.9000-CLOSE-FILES', name: '9000-CLOSE-FILES'})
SET para.line_start = 52, para.line_end = 54, para.line_count = 2
MERGE (p:Program {program_id: 'CUSTOMER-PROC'})
MERGE (p)-[:CONTAINS]->(para);

// BATCH-RUNNER paragraphs
MERGE (para:Paragraph {fqn: 'BATCH-RUNNER.0000-MAIN', name: '0000-MAIN'})
SET para.line_start = 81, para.line_end = 86, para.line_count = 5
MERGE (p:Program {program_id: 'BATCH-RUNNER'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'BATCH-RUNNER.1000-INITIALISE', name: '1000-INITIALISE'})
SET para.line_start = 88, para.line_end = 97, para.line_count = 9
MERGE (p:Program {program_id: 'BATCH-RUNNER'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'BATCH-RUNNER.1100-READ-NEXT-RECORD', name: '1100-READ-NEXT-RECORD'})
SET para.line_start = 99, para.line_end = 104, para.line_count = 5
MERGE (p:Program {program_id: 'BATCH-RUNNER'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'BATCH-RUNNER.2000-PROCESS-BATCH', name: '2000-PROCESS-BATCH'})
SET para.line_start = 106, para.line_end = 117, para.line_count = 11
MERGE (p:Program {program_id: 'BATCH-RUNNER'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'BATCH-RUNNER.9000-FINALISE', name: '9000-FINALISE'})
SET para.line_start = 119, para.line_end = 124, para.line_count = 5
MERGE (p:Program {program_id: 'BATCH-RUNNER'})
MERGE (p)-[:CONTAINS]->(para);

// ACCOUNT-MGR paragraphs
MERGE (para:Paragraph {fqn: 'ACCOUNT-MGR.0000-MAIN', name: '0000-MAIN'})
SET para.line_start = 35, para.line_end = 45, para.line_count = 10
MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'ACCOUNT-MGR.1000-OPEN-FILES', name: '1000-OPEN-FILES'})
SET para.line_start = 47, para.line_end = 52, para.line_count = 5
MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'ACCOUNT-MGR.2000-VALIDATE-CUSTOMER', name: '2000-VALIDATE-CUSTOMER'})
SET para.line_start = 54, para.line_end = 61, para.line_count = 7
MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'ACCOUNT-MGR.3000-UPDATE-ACCOUNT', name: '3000-UPDATE-ACCOUNT'})
SET para.line_start = 63, para.line_end = 73, para.line_count = 10
MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'ACCOUNT-MGR.4000-PROCESS-PAYMENT', name: '4000-PROCESS-PAYMENT'})
SET para.line_start = 94, para.line_end = 101, para.line_count = 7
MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'ACCOUNT-MGR.9000-CLOSE-FILES', name: '9000-CLOSE-FILES'})
SET para.line_start = 106, para.line_end = 107, para.line_count = 1
MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
MERGE (p)-[:CONTAINS]->(para);

// PAYMENT-HANDLER paragraphs
MERGE (para:Paragraph {fqn: 'PAYMENT-HANDLER.0000-MAIN', name: '0000-MAIN'})
SET para.line_start = 43, para.line_end = 62, para.line_count = 19
MERGE (p:Program {program_id: 'PAYMENT-HANDLER'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'PAYMENT-HANDLER.1000-OPEN-LOG', name: '1000-OPEN-LOG'})
SET para.line_start = 68, para.line_end = 72, para.line_count = 4
MERGE (p:Program {program_id: 'PAYMENT-HANDLER'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'PAYMENT-HANDLER.2000-VALIDATE-PAYMENT', name: '2000-VALIDATE-PAYMENT'})
SET para.line_start = 74, para.line_end = 82, para.line_count = 8
MERGE (p:Program {program_id: 'PAYMENT-HANDLER'})
MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'PAYMENT-HANDLER.4000-LOG-TRANSACTION', name: '4000-LOG-TRANSACTION'})
SET para.line_start = 104, para.line_end = 111, para.line_count = 7
MERGE (p:Program {program_id: 'PAYMENT-HANDLER'})
MERGE (p)-[:CONTAINS]->(para);

// Step 4: Create PERFORMS relationships
// ============================================================================

// CUSTOMER-PROC
MERGE (from:Paragraph {fqn: 'CUSTOMER-PROC.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'CUSTOMER-PROC.1000-OPEN-FILES'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'CUSTOMER-PROC.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'CUSTOMER-PROC.2000-PROCESS-CUSTOMERS'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'CUSTOMER-PROC.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'CUSTOMER-PROC.9000-CLOSE-FILES'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'CUSTOMER-PROC.1000-OPEN-FILES'})
MERGE (to:Paragraph {fqn: 'CUSTOMER-PROC.1100-READ-CUSTOMER'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'CUSTOMER-PROC.2000-PROCESS-CUSTOMERS'})
MERGE (to:Paragraph {fqn: 'CUSTOMER-PROC.1100-READ-CUSTOMER'})
MERGE (from)-[:PERFORMS]->(to);

// BATCH-RUNNER
MERGE (from:Paragraph {fqn: 'BATCH-RUNNER.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'BATCH-RUNNER.1000-INITIALISE'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'BATCH-RUNNER.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'BATCH-RUNNER.2000-PROCESS-BATCH'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'BATCH-RUNNER.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'BATCH-RUNNER.9000-FINALISE'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'BATCH-RUNNER.1000-INITIALISE'})
MERGE (to:Paragraph {fqn: 'BATCH-RUNNER.1100-READ-NEXT-RECORD'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'BATCH-RUNNER.2000-PROCESS-BATCH'})
MERGE (to:Paragraph {fqn: 'BATCH-RUNNER.1100-READ-NEXT-RECORD'})
MERGE (from)-[:PERFORMS]->(to);

// ACCOUNT-MGR
MERGE (from:Paragraph {fqn: 'ACCOUNT-MGR.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'ACCOUNT-MGR.1000-OPEN-FILES'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'ACCOUNT-MGR.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'ACCOUNT-MGR.2000-VALIDATE-CUSTOMER'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'ACCOUNT-MGR.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'ACCOUNT-MGR.3000-UPDATE-ACCOUNT'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'ACCOUNT-MGR.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'ACCOUNT-MGR.4000-PROCESS-PAYMENT'})
MERGE (from)-[:PERFORMS]->(to);

MERGE (from:Paragraph {fqn: 'ACCOUNT-MGR.0000-MAIN'})
MERGE (to:Paragraph {fqn: 'ACCOUNT-MGR.9000-CLOSE-FILES'})
MERGE (from)-[:PERFORMS]->(to);

// Step 5: Create CALLS relationships
// ============================================================================

MERGE (caller:Program {program_id: 'CUSTOMER-PROC'})
MERGE (callee:Program {program_id: 'ACCOUNT-MGR'})
MERGE (caller)-[:CALLS {using_params: ['CUSTOMER-REC']}]->(callee);

MERGE (caller:Program {program_id: 'BATCH-RUNNER'})
MERGE (callee:Program {program_id: 'CUSTOMER-PROC'})
MERGE (caller)-[:CALLS {using_params: ['BATCH-INPUT-REC']}]->(callee);

MERGE (caller:Program {program_id: 'ACCOUNT-MGR'})
MERGE (callee:Program {program_id: 'PAYMENT-HANDLER'})
MERGE (caller)-[:CALLS {using_params: ['WS-PAYMENT-REQUEST', 'WS-RETURN-CODE']}]->(callee);

// Step 6: Create INCLUDES relationships (copybook usage)
// ============================================================================

MERGE (p:Program {program_id: 'CUSTOMER-PROC'})
MERGE (cb:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (p)-[:INCLUDES]->(cb);

MERGE (p:Program {program_id: 'BATCH-RUNNER'})
MERGE (cb:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (p)-[:INCLUDES]->(cb);

MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
MERGE (cb:Copybook {name: 'ACCOUNT-RECORD'})
MERGE (p)-[:INCLUDES]->(cb);

MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
MERGE (cb:Copybook {name: 'PAYMENT-RECORD'})
MERGE (p)-[:INCLUDES]->(cb);

MERGE (p:Program {program_id: 'ACCOUNT-MGR'})
MERGE (cb:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (p)-[:INCLUDES]->(cb);

MERGE (p:Program {program_id: 'PAYMENT-HANDLER'})
MERGE (cb:Copybook {name: 'PAYMENT-RECORD'})
MERGE (p)-[:INCLUDES]->(cb);

// Step 7: Create File nodes and READ/WRITE relationships
// ============================================================================

MERGE (f:CobolFile {logical_name: 'CUSTOMER-FILE'})
SET f.physical_name = 'CUSTMAST', f.organization = 'SEQUENTIAL', f.access_mode = 'INPUT';

MERGE (f:CobolFile {logical_name: 'AUDIT-FILE'})
SET f.physical_name = 'AUDITMAST', f.organization = 'SEQUENTIAL', f.access_mode = 'OUTPUT';

MERGE (f:CobolFile {logical_name: 'ACCOUNT-FILE'})
SET f.physical_name = 'ACCTMAST', f.organization = 'INDEXED', f.access_mode = 'DYNAMIC';

MERGE (f:CobolFile {logical_name: 'PAYMENT-LOG'})
SET f.physical_name = 'PAYLOG', f.organization = 'SEQUENTIAL', f.access_mode = 'SEQUENTIAL';

MERGE (f:CobolFile {logical_name: 'BATCH-INPUT'})
SET f.physical_name = 'BATCHIN', f.organization = 'SEQUENTIAL', f.access_mode = 'SEQUENTIAL';

MERGE (f:CobolFile {logical_name: 'BATCH-REPORT'})
SET f.physical_name = 'BATCHRPT', f.organization = 'SEQUENTIAL', f.access_mode = 'SEQUENTIAL';

// File I/O relationships
MERGE (para:Paragraph {fqn: 'CUSTOMER-PROC.1100-READ-CUSTOMER'})
MERGE (f:CobolFile {logical_name: 'CUSTOMER-FILE'})
MERGE (para)-[:READS]->(f);

MERGE (para:Paragraph {fqn: 'BATCH-RUNNER.1100-READ-NEXT-RECORD'})
MERGE (f:CobolFile {logical_name: 'BATCH-INPUT'})
MERGE (para)-[:READS]->(f);

MERGE (para:Paragraph {fqn: 'BATCH-RUNNER.1000-INITIALISE'})
MERGE (f:CobolFile {logical_name: 'BATCH-REPORT'})
MERGE (para)-[:WRITES]->(f);

MERGE (para:Paragraph {fqn: 'ACCOUNT-MGR.2000-VALIDATE-CUSTOMER'})
MERGE (f:CobolFile {logical_name: 'ACCOUNT-FILE'})
MERGE (para)-[:READS]->(f);

MERGE (para:Paragraph {fqn: 'PAYMENT-HANDLER.4000-LOG-TRANSACTION'})
MERGE (f:CobolFile {logical_name: 'PAYMENT-LOG'})
MERGE (para)-[:WRITES]->(f);

// Step 8: Verification queries
// ============================================================================

// Count all nodes by label
MATCH (n) RETURN labels(n) AS label, count(n) AS count ORDER BY count DESC;

// Count all relationships by type
MATCH ()-[r]->() RETURN type(r) AS rel_type, count(r) AS count ORDER BY count DESC;

// Show the complete call graph
MATCH (p1:Program)-[:CALLS]->(p2:Program)
RETURN p1.program_id AS caller, p2.program_id AS callee, count(*) AS call_count;

// Show copybook usage
MATCH (p:Program)-[:INCLUDES]->(cb:Copybook)
RETURN p.program_id AS program, cb.name AS copybook;
