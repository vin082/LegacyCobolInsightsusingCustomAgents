// LegacyCobolInsights — Seed Test Data
// Creates a representative COBOL portfolio for testing agents and queries
// Matches the sample-cobol/ directory programs

// ============================================================
// COPYBOOKS
// ============================================================

MERGE (cb1:Copybook {name: 'CUSTOMER-RECORD'})
SET cb1.source_path = 'sample-cobol/copybooks/CUSTOMER-RECORD.cpy',
    cb1.data_item_count = 6,
    cb1.parsed_at = '2024-01-15T10:00:00Z';

MERGE (cb2:Copybook {name: 'ACCOUNT-RECORD'})
SET cb2.source_path = 'sample-cobol/copybooks/ACCOUNT-RECORD.cpy',
    cb2.data_item_count = 7,
    cb2.parsed_at = '2024-01-15T10:00:00Z';

MERGE (cb3:Copybook {name: 'PAYMENT-RECORD'})
SET cb3.source_path = 'sample-cobol/copybooks/PAYMENT-RECORD.cpy',
    cb3.data_item_count = 6,
    cb3.parsed_at = '2024-01-15T10:00:00Z';

// ============================================================
// DATA ITEMS — CUSTOMER-RECORD
// ============================================================

MERGE (di1:DataItem {fqn: 'CUSTOMER-RECORD.CUST-ID'})
SET di1.name = 'CUST-ID', di1.level = '05', di1.pic = '9(8)',
    di1.has_redefines = false, di1.has_occurs = false;

MERGE (di2:DataItem {fqn: 'CUSTOMER-RECORD.CUST-NAME'})
SET di2.name = 'CUST-NAME', di2.level = '05', di2.pic = 'X(40)',
    di2.has_redefines = false, di2.has_occurs = false;

MERGE (di3:DataItem {fqn: 'CUSTOMER-RECORD.CUST-STATUS'})
SET di3.name = 'CUST-STATUS', di3.level = '05', di3.pic = 'X',
    di3.has_redefines = false, di3.has_occurs = false;

MERGE (di4:DataItem {fqn: 'CUSTOMER-RECORD.CUST-BALANCE'})
SET di4.name = 'CUST-BALANCE', di4.level = '05', di4.pic = 'S9(9)V99',
    di4.has_redefines = false, di4.has_occurs = false;

MERGE (cb1:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (cb1)-[:DEFINES]->(di1)
MERGE (cb1)-[:DEFINES]->(di2)
MERGE (cb1)-[:DEFINES]->(di3)
MERGE (cb1)-[:DEFINES]->(di4);

// ============================================================
// PROGRAMS
// ============================================================

MERGE (p1:Program {program_id: 'CUSTOMER-PROC'})
SET p1.source_path = 'sample-cobol/CUSTOMER-PROC.cbl',
    p1.author = 'J.SMITH',
    p1.date_written = '1987-03-15',
    p1.line_count = 55,
    p1.has_goto = false,
    p1.has_alter = false,
    p1.has_redefines = false,
    p1.estimated_complexity = 'LOW',
    p1.parsed_at = '2024-01-15T10:00:00Z';

MERGE (p2:Program {program_id: 'ACCOUNT-MGR'})
SET p2.source_path = 'sample-cobol/ACCOUNT-MGR.cbl',
    p2.author = 'M.JONES',
    p2.date_written = '1989-07-22',
    p2.line_count = 120,
    p2.has_goto = false,
    p2.has_alter = false,
    p2.has_redefines = true,
    p2.estimated_complexity = 'MEDIUM',
    p2.parsed_at = '2024-01-15T10:00:00Z';

MERGE (p3:Program {program_id: 'PAYMENT-HANDLER'})
SET p3.source_path = 'sample-cobol/PAYMENT-HANDLER.cbl',
    p3.author = 'S.PATEL',
    p3.date_written = '1992-11-03',
    p3.line_count = 180,
    p3.has_goto = true,
    p3.has_alter = false,
    p3.has_redefines = false,
    p3.estimated_complexity = 'MEDIUM',
    p3.parsed_at = '2024-01-15T10:00:00Z';

MERGE (p4:Program {program_id: 'BATCH-RUNNER'})
SET p4.source_path = 'sample-cobol/BATCH-RUNNER.cbl',
    p4.author = 'D.WILSON',
    p4.date_written = '1995-02-14',
    p4.line_count = 95,
    p4.has_goto = false,
    p4.has_alter = false,
    p4.has_redefines = false,
    p4.estimated_complexity = 'LOW',
    p4.parsed_at = '2024-01-15T10:00:00Z';

// ============================================================
// CALL RELATIONSHIPS
// ============================================================

MERGE (p4:Program {program_id: 'BATCH-RUNNER'})
MERGE (p1:Program {program_id: 'CUSTOMER-PROC'})
MERGE (p4)-[:CALLS {using_params: ['CUSTOMER-REC']}]->(p1);

MERGE (p1:Program {program_id: 'CUSTOMER-PROC'})
MERGE (p2:Program {program_id: 'ACCOUNT-MGR'})
MERGE (p1)-[:CALLS {using_params: ['CUSTOMER-REC']}]->(p2);

MERGE (p2:Program {program_id: 'ACCOUNT-MGR'})
MERGE (p3:Program {program_id: 'PAYMENT-HANDLER'})
MERGE (p2)-[:CALLS {using_params: ['ACCT-REC', 'PAY-REQ']}]->(p3);

// ============================================================
// COPYBOOK INCLUDES
// ============================================================

MERGE (p1:Program {program_id: 'CUSTOMER-PROC'})
MERGE (cb1:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (p1)-[:INCLUDES]->(cb1);

MERGE (p2:Program {program_id: 'ACCOUNT-MGR'})
MERGE (cb1:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (cb2:Copybook {name: 'ACCOUNT-RECORD'})
MERGE (p2)-[:INCLUDES]->(cb1)
MERGE (p2)-[:INCLUDES]->(cb2);

MERGE (p3:Program {program_id: 'PAYMENT-HANDLER'})
MERGE (cb2:Copybook {name: 'ACCOUNT-RECORD'})
MERGE (cb3:Copybook {name: 'PAYMENT-RECORD'})
MERGE (p3)-[:INCLUDES]->(cb2)
MERGE (p3)-[:INCLUDES]->(cb3);

MERGE (p4:Program {program_id: 'BATCH-RUNNER'})
MERGE (cb1:Copybook {name: 'CUSTOMER-RECORD'})
MERGE (p4)-[:INCLUDES]->(cb1);

// ============================================================
// COBOL FILES
// ============================================================

MERGE (f1:CobolFile {logical_name: 'CUSTOMER-FILE'})
SET f1.physical_name = 'CUSTMAST', f1.organisation = 'SEQUENTIAL';

MERGE (f2:CobolFile {logical_name: 'AUDIT-FILE'})
SET f2.physical_name = 'AUDITMAST', f2.organisation = 'SEQUENTIAL';

MERGE (f3:CobolFile {logical_name: 'ACCOUNT-FILE'})
SET f3.physical_name = 'ACCTMAST', f3.organisation = 'INDEXED';

// ============================================================
// PARAGRAPHS — CUSTOMER-PROC
// ============================================================

MERGE (para1:Paragraph {fqn: 'CUSTOMER-PROC.0000-MAIN'})
SET para1.name = '0000-MAIN', para1.line_start = 21, para1.line_end = 27,
    para1.line_count = 6, para1.decision_points = 0;

MERGE (para2:Paragraph {fqn: 'CUSTOMER-PROC.1000-OPEN-FILES'})
SET para2.name = '1000-OPEN-FILES', para2.line_start = 29, para2.line_end = 33,
    para2.line_count = 4, para2.decision_points = 0;

MERGE (para3:Paragraph {fqn: 'CUSTOMER-PROC.1100-READ-CUSTOMER'})
SET para3.name = '1100-READ-CUSTOMER', para3.line_start = 35, para3.line_end = 40,
    para3.line_count = 5, para3.decision_points = 1;

MERGE (para4:Paragraph {fqn: 'CUSTOMER-PROC.2000-PROCESS-CUSTOMERS'})
SET para4.name = '2000-PROCESS-CUSTOMERS', para4.line_start = 42, para4.line_end = 46,
    para4.line_count = 4, para4.decision_points = 0;

MERGE (para5:Paragraph {fqn: 'CUSTOMER-PROC.9000-CLOSE-FILES'})
SET para5.name = '9000-CLOSE-FILES', para5.line_start = 48, para5.line_end = 52,
    para5.line_count = 4, para5.decision_points = 0;

MERGE (p1:Program {program_id: 'CUSTOMER-PROC'})
MERGE (p1)-[:CONTAINS]->(para1)
MERGE (p1)-[:CONTAINS]->(para2)
MERGE (p1)-[:CONTAINS]->(para3)
MERGE (p1)-[:CONTAINS]->(para4)
MERGE (p1)-[:CONTAINS]->(para5);

// PERFORMS within CUSTOMER-PROC
MERGE (para1)-[:PERFORMS]->(para2);
MERGE (para1)-[:PERFORMS]->(para4);
MERGE (para1)-[:PERFORMS]->(para5);
MERGE (para2)-[:PERFORMS]->(para3);
MERGE (para4)-[:PERFORMS]->(para3);

// File access
MERGE (para3)-[:READS]->(f1:CobolFile {logical_name: 'CUSTOMER-FILE'});
MERGE (para2)-[:WRITES]->(f2:CobolFile {logical_name: 'AUDIT-FILE'});

// Verify seed data
MATCH (n) RETURN labels(n)[0] AS label, count(n) AS count ORDER BY count DESC;
