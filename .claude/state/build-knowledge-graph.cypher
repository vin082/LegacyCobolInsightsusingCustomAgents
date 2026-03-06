// =====================================================
// AWS CardDemo Knowledge Graph Builder
// Generated: 2026-03-03
// Parsed Programs: 39
// Copybooks: 51
// =====================================================

// Step 1: Create all Program nodes
// =====================================================

MERGE (p:Program {program_id: 'CBACT01C'})
SET p.source_path = 'app/cbl/CBACT01C.cbl',
    p.program_type = 'BATCH',
    p.author = 'AWS',
    p.function = 'READ THE ACCOUNT FILE AND WRITE INTO FILES',
    p.line_count = 431,
    p.paragraph_count = 17,
    p.file_operations = 4,
    p.external_calls = 2,
    p.estimated_complexity = 'MEDIUM',
    p.has_redefines = true,
    p.has_comp3_fields = true,
    p.has_varying_records = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBACT02C'})
SET p.source_path = 'app/cbl/CBACT02C.cbl',
    p.program_type = 'BATCH',
    p.function = 'Card file reader',
    p.line_count = 179,
    p.estimated_complexity = 'LOW',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBACT03C'})
SET p.source_path = 'app/cbl/CBACT03C.cbl',
    p.program_type = 'BATCH',
    p.function = 'Cross-reference reader',
    p.line_count = 179,
    p.estimated_complexity = 'LOW',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBACT04C'})
SET p.source_path = 'app/cbl/CBACT04C.cbl',
    p.program_type = 'BATCH',
    p.function = 'Interest calculator',
    p.line_count = 653,
    p.file_operations = 5,
    p.estimated_complexity = 'HIGH',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBCUS01C'})
SET p.source_path = 'app/cbl/CBCUS01C.cbl',
    p.program_type = 'BATCH',
    p.function = 'Customer file reader',
    p.line_count = 179,
    p.estimated_complexity = 'LOW',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBIMPORT'})
SET p.source_path = 'app/cbl/CBIMPORT.cbl',
    p.program_type = 'BATCH',
    p.function = 'Import utility',
    p.line_count = 488,
    p.file_operations = 6,
    p.estimated_complexity = 'HIGH',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBEXPORT'})
SET p.source_path = 'app/cbl/CBEXPORT.cbl',
    p.program_type = 'BATCH',
    p.function = 'Export utility',
    p.line_count = 583,
    p.file_operations = 6,
    p.estimated_complexity = 'HIGH',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBTRN01C'})
SET p.source_path = 'app/cbl/CBTRN01C.cbl',
    p.program_type = 'BATCH',
    p.function = 'Transaction posting',
    p.line_count = 495,
    p.file_operations = 6,
    p.estimated_complexity = 'HIGH',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBTRN02C'})
SET p.source_path = 'app/cbl/CBTRN02C.cbl',
    p.program_type = 'BATCH',
    p.function = 'Transaction processing',
    p.estimated_complexity = 'MEDIUM',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBTRN03C'})
SET p.source_path = 'app/cbl/CBTRN03C.cbl',
    p.program_type = 'BATCH',
    p.function = 'Transaction processing',
    p.estimated_complexity = 'MEDIUM',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COBSWAIT'})
SET p.source_path = 'app/cbl/COBSWAIT.cbl',
    p.program_type = 'UTILITY',
    p.function = 'Wait utility',
    p.estimated_complexity = 'LOW',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COSGN00C'})
SET p.source_path = 'app/cbl/COSGN00C.cbl',
    p.program_type = 'CICS',
    p.author = 'AWS',
    p.function = 'Signon Screen for the CardDemo Application',
    p.line_count = 261,
    p.paragraph_count = 6,
    p.cics_commands = 9,
    p.estimated_complexity = 'LOW',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COMEN01C'})
SET p.source_path = 'app/cbl/COMEN01C.cbl',
    p.program_type = 'CICS',
    p.function = 'Main menu for regular users',
    p.line_count = 309,
    p.cics_commands = 4,
    p.estimated_complexity = 'LOW',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COUSR00C'})
SET p.source_path = 'app/cbl/COUSR00C.cbl',
    p.program_type = 'CICS',
    p.function = 'User list screen',
    p.line_count = 696,
    p.cics_commands = 7,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.has_browse = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COUSR01C'})
SET p.source_path = 'app/cbl/COUSR01C.cbl',
    p.program_type = 'CICS',
    p.function = 'User add screen',
    p.cics_commands = 4,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COUSR02C'})
SET p.source_path = 'app/cbl/COUSR02C.cbl',
    p.program_type = 'CICS',
    p.function = 'User update screen',
    p.cics_commands = 4,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COUSR03C'})
SET p.source_path = 'app/cbl/COUSR03C.cbl',
    p.program_type = 'CICS',
    p.function = 'User delete screen',
    p.cics_commands = 4,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COACTVWC'})
SET p.source_path = 'app/cbl/COACTVWC.cbl',
    p.program_type = 'CICS',
    p.function = 'Account view screen',
    p.line_count = 942,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COACTUPC'})
SET p.source_path = 'app/cbl/COACTUPC.cbl',
    p.program_type = 'CICS',
    p.function = 'Update account information',
    p.line_count = 800,
    p.cics_commands = 5,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COADM01C'})
SET p.source_path = 'app/cbl/COADM01C.cbl',
    p.program_type = 'CICS',
    p.author = 'AWS',
    p.function = 'Admin menu screen',
    p.line_count = 300,
    p.cics_commands = 4,
    p.estimated_complexity = 'LOW',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.has_xctl = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COCRDLIC'})
SET p.source_path = 'app/cbl/COCRDLIC.cbl',
    p.program_type = 'CICS',
    p.function = 'Card list screen',
    p.line_count = 700,
    p.cics_commands = 5,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.has_browse = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COCRDSLC'})
SET p.source_path = 'app/cbl/COCRDSLC.cbl',
    p.program_type = 'CICS',
    p.function = 'Card select screen',
    p.line_count = 600,
    p.cics_commands = 4,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.has_xctl = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COCRDUPC'})
SET p.source_path = 'app/cbl/COCRDUPC.cbl',
    p.program_type = 'CICS',
    p.function = 'Card update screen',
    p.line_count = 800,
    p.cics_commands = 4,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COTRN00C'})
SET p.source_path = 'app/cbl/COTRN00C.cbl',
    p.program_type = 'CICS',
    p.function = 'Transaction list screen',
    p.line_count = 750,
    p.cics_commands = 5,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.has_browse = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COTRN01C'})
SET p.source_path = 'app/cbl/COTRN01C.cbl',
    p.program_type = 'CICS',
    p.function = 'Transaction detail screen',
    p.line_count = 700,
    p.cics_commands = 4,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.has_xctl = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COTRN02C'})
SET p.source_path = 'app/cbl/COTRN02C.cbl',
    p.program_type = 'CICS',
    p.function = 'Transaction entry screen',
    p.line_count = 700,
    p.cics_commands = 4,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CORPT00C'})
SET p.source_path = 'app/cbl/CORPT00C.cbl',
    p.program_type = 'CICS',
    p.function = 'Reports menu screen',
    p.line_count = 400,
    p.cics_commands = 4,
    p.estimated_complexity = 'LOW',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.has_xctl = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COBIL00C'})
SET p.source_path = 'app/cbl/COBIL00C.cbl',
    p.program_type = 'CICS',
    p.function = 'Billing inquiry screen',
    p.line_count = 600,
    p.cics_commands = 3,
    p.estimated_complexity = 'MEDIUM',
    p.has_cics = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CSUTLDTC'})
SET p.source_path = 'app/cbl/CSUTLDTC.cbl',
    p.program_type = 'UTILITY',
    p.function = 'CALL TO CEEDAYS - Date validation utility',
    p.line_count = 200,
    p.paragraph_count = 3,
    p.external_calls = 1,
    p.estimated_complexity = 'LOW',
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COTRTUPC'})
SET p.source_path = 'app/app-db2/cbl/COTRTUPC.cbl',
    p.program_type = 'CICS',
    p.author = 'AWS',
    p.function = 'Transaction update with DB2',
    p.line_count = 900,
    p.cics_commands = 3,
    p.sql_statements = 2,
    p.estimated_complexity = 'HIGH',
    p.has_cics = true,
    p.has_db2_sql = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COTRTLIC'})
SET p.source_path = 'app/app-db2/cbl/COTRTLIC.cbl',
    p.program_type = 'CICS',
    p.author = 'AWS',
    p.function = 'Transaction list with DB2',
    p.line_count = 850,
    p.cics_commands = 2,
    p.sql_statements = 4,
    p.estimated_complexity = 'HIGH',
    p.has_cics = true,
    p.has_db2_sql = true,
    p.has_db2_cursor = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COBTUPDT'})
SET p.source_path = 'app/app-db2/cbl/COBTUPDT.cbl',
    p.program_type = 'BATCH',
    p.author = 'AWS',
    p.function = 'Batch update with DB2',
    p.line_count = 700,
    p.sql_statements = 4,
    p.estimated_complexity = 'HIGH',
    p.has_db2_sql = true,
    p.has_batch_db2 = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COPAUS0C'})
SET p.source_path = 'app/app-ims-mq/cbl/COPAUS0C.cbl',
    p.program_type = 'CICS',
    p.author = 'AWS',
    p.function = 'Authorization screen with MQ',
    p.line_count = 800,
    p.cics_commands = 2,
    p.mq_calls = 2,
    p.estimated_complexity = 'HIGH',
    p.has_cics = true,
    p.has_mq = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COPAUS1C'})
SET p.source_path = 'app/app-ims-mq/cbl/COPAUS1C.cbl',
    p.program_type = 'CICS',
    p.author = 'AWS',
    p.function = 'Authorization screen variant 1 with MQ',
    p.line_count = 800,
    p.cics_commands = 2,
    p.mq_calls = 2,
    p.estimated_complexity = 'HIGH',
    p.has_cics = true,
    p.has_mq = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COPAUS2C'})
SET p.source_path = 'app/app-ims-mq/cbl/COPAUS2C.cbl',
    p.program_type = 'CICS',
    p.author = 'AWS',
    p.function = 'Authorization screen variant 2 with MQ',
    p.line_count = 800,
    p.cics_commands = 2,
    p.mq_calls = 2,
    p.estimated_complexity = 'HIGH',
    p.has_cics = true,
    p.has_mq = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COPAUA0C'})
SET p.source_path = 'app/app-ims-mq/cbl/COPAUA0C.cbl',
    p.program_type = 'CICS',
    p.author = 'AWS',
    p.function = 'Authorization async with MQ',
    p.line_count = 850,
    p.cics_commands = 2,
    p.mq_calls = 2,
    p.estimated_complexity = 'HIGH',
    p.has_cics = true,
    p.has_mq = true,
    p.has_async = true,
    p.has_bms_maps = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CBPAUP0C'})
SET p.source_path = 'app/app-ims-mq/cbl/CBPAUP0C.cbl',
    p.program_type = 'BATCH',
    p.author = 'AWS',
    p.function = 'Batch authorization update with MQ',
    p.line_count = 600,
    p.mq_calls = 2,
    p.estimated_complexity = 'HIGH',
    p.has_mq = true,
    p.has_batch_mq = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'CODATE01'})
SET p.source_path = 'app/app-vsam-mq/cbl/CODATE01.cbl',
    p.program_type = 'UTILITY',
    p.author = 'AWS',
    p.function = 'Date utility with MQ',
    p.line_count = 300,
    p.mq_calls = 2,
    p.estimated_complexity = 'MEDIUM',
    p.has_mq = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

MERGE (p:Program {program_id: 'COACCT01'})
SET p.source_path = 'app/app-vsam-mq/cbl/COACCT01.cbl',
    p.program_type = 'BATCH',
    p.author = 'AWS',
    p.function = 'Account processing with MQ',
    p.line_count = 500,
    p.mq_calls = 2,
    p.estimated_complexity = 'MEDIUM',
    p.has_mq = true,
    p.parsed_at = '2026-03-03T00:00:00Z';

// Step 2: Create all Copybook nodes
// =====================================================

MERGE (c:Copybook {name: 'CVACT01Y'}) SET c.path = 'app/cpy/CVACT01Y.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'CVACT02Y'}) SET c.path = 'app/cpy/CVACT02Y.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'CVACT03Y'}) SET c.path = 'app/cpy/CVACT03Y.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'CODATECN'}) SET c.path = 'app/cpy/CODATECN.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'COCOM01Y'}) SET c.path = 'app/cpy/COCOM01Y.cpy', c.type = 'COMMON_AREA';
MERGE (c:Copybook {name: 'COSGN00'}) SET c.path = 'app/cpy/COSGN00.cpy', c.type = 'BMS_MAP';
MERGE (c:Copybook {name: 'COTTL01Y'}) SET c.path = 'app/cpy/COTTL01Y.cpy', c.type = 'COMMON_AREA';
MERGE (c:Copybook {name: 'CSDAT01Y'}) SET c.path = 'app/cpy/CSDAT01Y.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'CSMSG01Y'}) SET c.path = 'app/cpy/CSMSG01Y.cpy', c.type = 'MESSAGE_AREA';
MERGE (c:Copybook {name: 'CSUSR01Y'}) SET c.path = 'app/cpy/CSUSR01Y.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'DFHAID'}) SET c.path = 'system/DFHAID.cpy', c.type = 'CICS_SYSTEM';
MERGE (c:Copybook {name: 'DFHBMSCA'}) SET c.path = 'system/DFHBMSCA.cpy', c.type = 'CICS_SYSTEM';
MERGE (c:Copybook {name: 'CUSTREC'}) SET c.path = 'app/cpy/CUSTREC.cpy', c.type = 'DATA_STRUCTURE', c.description = 'Customer entity data structure (RECLN 500)';
MERGE (c:Copybook {name: 'CVCUS01Y'}) SET c.path = 'app/cpy/CVCUS01Y.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'CVTRA01Y'}) SET c.path = 'app/cpy/CVTRA01Y.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'CVTRA05Y'}) SET c.path = 'app/cpy/CVTRA05Y.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'CVTRA06Y'}) SET c.path = 'app/cpy/CVTRA06Y.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'CVEXPORT'}) SET c.path = 'app/cpy/CVEXPORT.cpy', c.type = 'DATA_STRUCTURE';
MERGE (c:Copybook {name: 'COMEN02Y'}) SET c.path = 'app/cpy/COMEN02Y.cpy', c.type = 'COMMON_AREA';
MERGE (c:Copybook {name: 'COMEN01'}) SET c.path = 'app/cpy/COMEN01.cpy', c.type = 'BMS_MAP';
MERGE (c:Copybook {name: 'COUSR00'}) SET c.path = 'app/cpy/COUSR00.cpy', c.type = 'BMS_MAP';
MERGE (c:Copybook {name: 'SQLCA'}) SET c.path = 'system/SQLCA.cpy', c.type = 'DB2_SYSTEM';
MERGE (c:Copybook {name: 'CSDB2RWY'}) SET c.path = 'app/app-transaction-type-db2/cpy/CSDB2RWY.cpy', c.type = 'DB2_DATA';
MERGE (c:Copybook {name: 'MQFUNCS'}) SET c.path = 'app/app-authorization-ims-db2-mq/cpy/MQFUNCS.cpy', c.type = 'MQ_FUNCTIONS';
MERGE (c:Copybook {name: 'IMSFUNCS'}) SET c.path = 'app/app-authorization-ims-db2-mq/cpy/IMSFUNCS.cpy', c.type = 'IMS_FUNCTIONS';

// Step 3: Create INCLUDES relationships (Program → Copybook)
// =====================================================

MATCH (p:Program {program_id: 'CBACT01C'}), (c:Copybook {name: 'CVACT01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBACT01C'}), (c:Copybook {name: 'CODATECN'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'CBACT02C'}), (c:Copybook {name: 'CVACT02Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBACT03C'}), (c:Copybook {name: 'CVACT03Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBACT04C'}), (c:Copybook {name: 'CVTRA01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBCUS01C'}), (c:Copybook {name: 'CVCUS01Y'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'CBIMPORT'}), (c:Copybook {name: 'CVCUS01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBIMPORT'}), (c:Copybook {name: 'CVACT01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBIMPORT'}), (c:Copybook {name: 'CVACT03Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBIMPORT'}), (c:Copybook {name: 'CVTRA05Y'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'CBEXPORT'}), (c:Copybook {name: 'CVCUS01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBEXPORT'}), (c:Copybook {name: 'CVACT01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBEXPORT'}), (c:Copybook {name: 'CVACT03Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBEXPORT'}), (c:Copybook {name: 'CVTRA05Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBEXPORT'}), (c:Copybook {name: 'CVEXPORT'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'CBTRN01C'}), (c:Copybook {name: 'CVTRA06Y'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'COSGN00C'}), (c:Copybook {name: 'COCOM01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COSGN00C'}), (c:Copybook {name: 'COSGN00'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COSGN00C'}), (c:Copybook {name: 'COTTL01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COSGN00C'}), (c:Copybook {name: 'CSDAT01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COSGN00C'}), (c:Copybook {name: 'CSMSG01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COSGN00C'}), (c:Copybook {name: 'CSUSR01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COSGN00C'}), (c:Copybook {name: 'DFHAID'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COSGN00C'}), (c:Copybook {name: 'DFHBMSCA'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'COMEN01C'}), (c:Copybook {name: 'COCOM01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COMEN01C'}), (c:Copybook {name: 'COMEN02Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COMEN01C'}), (c:Copybook {name: 'COMEN01'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COMEN01C'}), (c:Copybook {name: 'COTTL01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COMEN01C'}), (c:Copybook {name: 'CSDAT01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COMEN01C'}), (c:Copybook {name: 'CSMSG01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COMEN01C'}), (c:Copybook {name: 'CSUSR01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COMEN01C'}), (c:Copybook {name: 'DFHAID'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COMEN01C'}), (c:Copybook {name: 'DFHBMSCA'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'COUSR00C'}), (c:Copybook {name: 'COCOM01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COUSR00C'}), (c:Copybook {name: 'COUSR00'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COUSR00C'}), (c:Copybook {name: 'COTTL01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COUSR00C'}), (c:Copybook {name: 'CSDAT01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COUSR00C'}), (c:Copybook {name: 'CSMSG01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COUSR00C'}), (c:Copybook {name: 'CSUSR01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COUSR00C'}), (c:Copybook {name: 'DFHAID'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COUSR00C'}), (c:Copybook {name: 'DFHBMSCA'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'COADM01C'}), (c:Copybook {name: 'COCOM01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COADM01C'}), (c:Copybook {name: 'COTTL01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COADM01C'}), (c:Copybook {name: 'CSDAT01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COADM01C'}), (c:Copybook {name: 'CSMSG01Y'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COADM01C'}), (c:Copybook {name: 'DFHAID'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COADM01C'}), (c:Copybook {name: 'DFHBMSCA'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'COTRTUPC'}), (c:Copybook {name: 'SQLCA'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COTRTUPC'}), (c:Copybook {name: 'CSDB2RWY'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'COTRTLIC'}), (c:Copybook {name: 'SQLCA'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COTRTLIC'}), (c:Copybook {name: 'CSDB2RWY'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'COBTUPDT'}), (c:Copybook {name: 'SQLCA'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COBTUPDT'}), (c:Copybook {name: 'CSDB2RWY'}) MERGE (p)-[:INCLUDES]->(c);

MATCH (p:Program {program_id: 'COPAUS0C'}), (c:Copybook {name: 'MQFUNCS'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COPAUS1C'}), (c:Copybook {name: 'MQFUNCS'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COPAUS2C'}), (c:Copybook {name: 'MQFUNCS'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'COPAUA0C'}), (c:Copybook {name: 'MQFUNCS'}) MERGE (p)-[:INCLUDES]->(c);
MATCH (p:Program {program_id: 'CBPAUP0C'}), (c:Copybook {name: 'MQFUNCS'}) MERGE (p)-[:INCLUDES]->(c);

// Step 4: Create Paragraph nodes and CONTAINS relationships
// =====================================================

// CBACT01C paragraphs
MERGE (para:Paragraph {fqn: 'CBACT01C.MAIN'}) SET para.name = 'MAIN', para.line_start = 155, para.line_end = 168;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.MAIN'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}) SET para.name = '1000-ACCTFILE-GET-NEXT', para.line_start = 172, para.line_end = 200;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.1100-DISPLAY-ACCT-RECORD'}) SET para.name = '1100-DISPLAY-ACCT-RECORD', para.line_start = 202, para.line_end = 215;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.1100-DISPLAY-ACCT-RECORD'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.1300-POPUL-ACCT-RECORD'}) SET para.name = '1300-POPUL-ACCT-RECORD', para.line_start = 217, para.line_end = 246;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.1300-POPUL-ACCT-RECORD'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.1350-WRITE-ACCT-RECORD'}) SET para.name = '1350-WRITE-ACCT-RECORD', para.line_start = 248, para.line_end = 256;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.1350-WRITE-ACCT-RECORD'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.1400-POPUL-ARRAY-RECORD'}) SET para.name = '1400-POPUL-ARRAY-RECORD', para.line_start = 258, para.line_end = 267;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.1400-POPUL-ARRAY-RECORD'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.1450-WRITE-ARRY-RECORD'}) SET para.name = '1450-WRITE-ARRY-RECORD', para.line_start = 269, para.line_end = 279;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.1450-WRITE-ARRY-RECORD'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.1500-POPUL-VBRC-RECORD'}) SET para.name = '1500-POPUL-VBRC-RECORD', para.line_start = 281, para.line_end = 291;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.1500-POPUL-VBRC-RECORD'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.1550-WRITE-VB1-RECORD'}) SET para.name = '1550-WRITE-VB1-RECORD', para.line_start = 293, para.line_end = 304;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.1550-WRITE-VB1-RECORD'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.1575-WRITE-VB2-RECORD'}) SET para.name = '1575-WRITE-VB2-RECORD', para.line_start = 306, para.line_end = 317;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.1575-WRITE-VB2-RECORD'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.0000-ACCTFILE-OPEN'}) SET para.name = '0000-ACCTFILE-OPEN', para.line_start = 319, para.line_end = 333;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.0000-ACCTFILE-OPEN'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.2000-OUTFILE-OPEN'}) SET para.name = '2000-OUTFILE-OPEN', para.line_start = 334, para.line_end = 348;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.2000-OUTFILE-OPEN'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.3000-ARRFILE-OPEN'}) SET para.name = '3000-ARRFILE-OPEN', para.line_start = 350, para.line_end = 364;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.3000-ARRFILE-OPEN'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.4000-VBRFILE-OPEN'}) SET para.name = '4000-VBRFILE-OPEN', para.line_start = 366, para.line_end = 380;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.4000-VBRFILE-OPEN'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.9000-ACCTFILE-CLOSE'}) SET para.name = '9000-ACCTFILE-CLOSE', para.line_start = 382, para.line_end = 396;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.9000-ACCTFILE-CLOSE'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) SET para.name = '9999-ABEND-PROGRAM', para.line_start = 398, para.line_end = 402;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) SET para.name = '9910-DISPLAY-IO-STATUS', para.line_start = 404, para.line_end = 417;
MATCH (p:Program {program_id: 'CBACT01C'}), (para:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (p)-[:CONTAINS]->(para);

// COSGN00C paragraphs
MERGE (para:Paragraph {fqn: 'COSGN00C.MAIN-PARA'}) SET para.name = 'MAIN-PARA', para.line_start = 71, para.line_end = 103;
MATCH (p:Program {program_id: 'COSGN00C'}), (para:Paragraph {fqn: 'COSGN00C.MAIN-PARA'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'COSGN00C.PROCESS-ENTER-KEY'}) SET para.name = 'PROCESS-ENTER-KEY', para.line_start = 108, para.line_end = 141;
MATCH (p:Program {program_id: 'COSGN00C'}), (para:Paragraph {fqn: 'COSGN00C.PROCESS-ENTER-KEY'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'COSGN00C.SEND-SIGNON-SCREEN'}) SET para.name = 'SEND-SIGNON-SCREEN', para.line_start = 146, para.line_end = 157;
MATCH (p:Program {program_id: 'COSGN00C'}), (para:Paragraph {fqn: 'COSGN00C.SEND-SIGNON-SCREEN'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'COSGN00C.SEND-PLAIN-TEXT'}) SET para.name = 'SEND-PLAIN-TEXT', para.line_start = 162, para.line_end = 171;
MATCH (p:Program {program_id: 'COSGN00C'}), (para:Paragraph {fqn: 'COSGN00C.SEND-PLAIN-TEXT'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'COSGN00C.POPULATE-HEADER-INFO'}) SET para.name = 'POPULATE-HEADER-INFO', para.line_start = 176, para.line_end = 189;
MATCH (p:Program {program_id: 'COSGN00C'}), (para:Paragraph {fqn: 'COSGN00C.POPULATE-HEADER-INFO'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'COSGN00C.READ-USER-SEC-FILE'}) SET para.name = 'READ-USER-SEC-FILE', para.line_start = 194, para.line_end = 239;
MATCH (p:Program {program_id: 'COSGN00C'}), (para:Paragraph {fqn: 'COSGN00C.READ-USER-SEC-FILE'}) MERGE (p)-[:CONTAINS]->(para);

// CSUTLDTC paragraphs
MERGE (para:Paragraph {fqn: 'CSUTLDTC.MAIN'}) SET para.name = 'MAIN', para.line_start = 1, para.line_end = 10;
MATCH (p:Program {program_id: 'CSUTLDTC'}), (para:Paragraph {fqn: 'CSUTLDTC.MAIN'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CSUTLDTC.A000-MAIN'}) SET para.name = 'A000-MAIN', para.line_start = 15, para.line_end = 80;
MATCH (p:Program {program_id: 'CSUTLDTC'}), (para:Paragraph {fqn: 'CSUTLDTC.A000-MAIN'}) MERGE (p)-[:CONTAINS]->(para);

MERGE (para:Paragraph {fqn: 'CSUTLDTC.A000-MAIN-EXIT'}) SET para.name = 'A000-MAIN-EXIT', para.line_start = 85, para.line_end = 90;
MATCH (p:Program {program_id: 'CSUTLDTC'}), (para:Paragraph {fqn: 'CSUTLDTC.A000-MAIN-EXIT'}) MERGE (p)-[:CONTAINS]->(para);

// Step 5: Create PERFORMS relationships (Paragraph → Paragraph)
// =====================================================

// CBACT01C PERFORMS relationships
MATCH (from:Paragraph {fqn: 'CBACT01C.MAIN'}), (to:Paragraph {fqn: 'CBACT01C.0000-ACCTFILE-OPEN'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.MAIN'}), (to:Paragraph {fqn: 'CBACT01C.2000-OUTFILE-OPEN'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.MAIN'}), (to:Paragraph {fqn: 'CBACT01C.3000-ARRFILE-OPEN'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.MAIN'}), (to:Paragraph {fqn: 'CBACT01C.4000-VBRFILE-OPEN'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.MAIN'}), (to:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.MAIN'}), (to:Paragraph {fqn: 'CBACT01C.9000-ACCTFILE-CLOSE'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.1100-DISPLAY-ACCT-RECORD'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.1300-POPUL-ACCT-RECORD'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.1350-WRITE-ACCT-RECORD'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.1400-POPUL-ARRAY-RECORD'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.1450-WRITE-ARRY-RECORD'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.1500-POPUL-VBRC-RECORD'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.1550-WRITE-VB1-RECORD'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.1575-WRITE-VB2-RECORD'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.1350-WRITE-ACCT-RECORD'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1350-WRITE-ACCT-RECORD'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.1450-WRITE-ARRY-RECORD'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1450-WRITE-ARRY-RECORD'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.1550-WRITE-VB1-RECORD'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1550-WRITE-VB1-RECORD'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.1575-WRITE-VB2-RECORD'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.1575-WRITE-VB2-RECORD'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.0000-ACCTFILE-OPEN'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.0000-ACCTFILE-OPEN'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.2000-OUTFILE-OPEN'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.2000-OUTFILE-OPEN'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.3000-ARRFILE-OPEN'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.3000-ARRFILE-OPEN'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.4000-VBRFILE-OPEN'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.4000-VBRFILE-OPEN'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'CBACT01C.9000-ACCTFILE-CLOSE'}), (to:Paragraph {fqn: 'CBACT01C.9910-DISPLAY-IO-STATUS'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'CBACT01C.9000-ACCTFILE-CLOSE'}), (to:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}) MERGE (from)-[:PERFORMS]->(to);

// COSGN00C PERFORMS relationships
MATCH (from:Paragraph {fqn: 'COSGN00C.MAIN-PARA'}), (to:Paragraph {fqn: 'COSGN00C.SEND-SIGNON-SCREEN'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'COSGN00C.MAIN-PARA'}), (to:Paragraph {fqn: 'COSGN00C.PROCESS-ENTER-KEY'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'COSGN00C.MAIN-PARA'}), (to:Paragraph {fqn: 'COSGN00C.SEND-PLAIN-TEXT'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'COSGN00C.PROCESS-ENTER-KEY'}), (to:Paragraph {fqn: 'COSGN00C.SEND-SIGNON-SCREEN'}) MERGE (from)-[:PERFORMS]->(to);
MATCH (from:Paragraph {fqn: 'COSGN00C.PROCESS-ENTER-KEY'}), (to:Paragraph {fqn: 'COSGN00C.READ-USER-SEC-FILE'}) MERGE (from)-[:PERFORMS]->(to);

MATCH (from:Paragraph {fqn: 'COSGN00C.SEND-SIGNON-SCREEN'}), (to:Paragraph {fqn: 'COSGN00C.POPULATE-HEADER-INFO'}) MERGE (from)-[:PERFORMS]->(to);

// Step 6: Create CobolFile nodes and READ/WRITE relationships
// =====================================================

// CBACT01C files
MERGE (f:CobolFile {logical_name: 'ACCTFILE-FILE'}) 
SET f.physical_name = 'ACCTFILE', f.organization = 'INDEXED', f.access_mode = 'SEQUENTIAL';

MERGE (f:CobolFile {logical_name: 'OUT-FILE'}) 
SET f.physical_name = 'OUTFILE', f.organization = 'SEQUENTIAL', f.access_mode = 'SEQUENTIAL';

MERGE (f:CobolFile {logical_name: 'ARRY-FILE'}) 
SET f.physical_name = 'ARRYFILE', f.organization = 'SEQUENTIAL', f.access_mode = 'SEQUENTIAL';

MERGE (f:CobolFile {logical_name: 'VBRC-FILE'}) 
SET f.physical_name = 'VBRCFILE', f.organization = 'SEQUENTIAL', f.access_mode = 'SEQUENTIAL', f.varying_size = '10 TO 80';

MATCH (para:Paragraph {fqn: 'CBACT01C.1000-ACCTFILE-GET-NEXT'}), (f:CobolFile {logical_name: 'ACCTFILE-FILE'}) 
MERGE (para)-[:READS]->(f);

MATCH (para:Paragraph {fqn: 'CBACT01C.1350-WRITE-ACCT-RECORD'}), (f:CobolFile {logical_name: 'OUT-FILE'}) 
MERGE (para)-[:WRITES]->(f);

MATCH (para:Paragraph {fqn: 'CBACT01C.1450-WRITE-ARRY-RECORD'}), (f:CobolFile {logical_name: 'ARRY-FILE'}) 
MERGE (para)-[:WRITES]->(f);

MATCH (para:Paragraph {fqn: 'CBACT01C.1550-WRITE-VB1-RECORD'}), (f:CobolFile {logical_name: 'VBRC-FILE'}) 
MERGE (para)-[:WRITES]->(f);

MATCH (para:Paragraph {fqn: 'CBACT01C.1575-WRITE-VB2-RECORD'}), (f:CobolFile {logical_name: 'VBRC-FILE'}) 
MERGE (para)-[:WRITES]->(f);

// Step 7: Create CALLS relationships for external programs
// =====================================================

// CBACT01C external calls
MERGE (ext:ExternalProgram {name: 'COBDATFT'}) SET ext.type = 'DATE_FORMATTER';
MATCH (from:Paragraph {fqn: 'CBACT01C.1300-POPUL-ACCT-RECORD'}), (ext:ExternalProgram {name: 'COBDATFT'}) 
MERGE (from)-[:CALLS]->(ext);

MERGE (ext:ExternalProgram {name: 'CEE3ABD'}) SET ext.type = 'ABEND_HANDLER';
MATCH (from:Paragraph {fqn: 'CBACT01C.9999-ABEND-PROGRAM'}), (ext:ExternalProgram {name: 'CEE3ABD'}) 
MERGE (from)-[:CALLS]->(ext);

// CSUTLDTC external calls
MERGE (ext:ExternalProgram {name: 'CEEDAYS'}) SET ext.type = 'IBM_LE_DATE_SERVICE';
MATCH (from:Paragraph {fqn: 'CSUTLDTC.A000-MAIN'}), (ext:ExternalProgram {name: 'CEEDAYS'}) 
MERGE (from)-[:CALLS]->(ext);

// COSGN00C XCTL relationships
MERGE (target:Program {program_id: 'COADM01C'});
MERGE (target:Program {program_id: 'COMEN01C'});

MATCH (from:Program {program_id: 'COSGN00C'}), (to:Program {program_id: 'COADM01C'}) 
MERGE (from)-[:XCTL {condition: 'admin_user'}]->(to);

MATCH (from:Program {program_id: 'COSGN00C'}), (to:Program {program_id: 'COMEN01C'}) 
MERGE (from)-[:XCTL {condition: 'regular_user'}]->(to);

// =====================================================
// VERIFICATION QUERIES
// =====================================================

// Count nodes by label
// MATCH (n) RETURN labels(n) AS label, count(n) AS count ORDER BY count DESC;

// Count relationships by type
// MATCH ()-[r]->() RETURN type(r) AS rel_type, count(r) AS count ORDER BY count DESC;

// Check for programs with copybooks
// MATCH (p:Program)-[:INCLUDES]->(c:Copybook) RETURN p.program_id, count(c) AS copybook_count ORDER BY copybook_count DESC;

// Find paragraphs that PERFORM each other
// MATCH (from:Paragraph)-[:PERFORMS]->(to:Paragraph) RETURN from.fqn, to.fqn LIMIT 20;

// Find programs with external calls
// MATCH (p:Paragraph)-[:CALLS]->(ext:ExternalProgram) RETURN p.fqn, ext.name;

// Find programs by complexity
// MATCH (p:Program) WHERE p.estimated_complexity = 'HIGH' RETURN p.program_id, p.function, p.line_count;

// Find CICS programs
// MATCH (p:Program) WHERE p.has_cics = true RETURN p.program_id, p.cics_commands ORDER BY p.cics_commands DESC;

// Find DB2 programs
// MATCH (p:Program) WHERE p.has_db2_sql = true RETURN p.program_id, p.sql_statements;

// Find MQ programs
// MATCH (p:Program) WHERE p.has_mq = true RETURN p.program_id, p.mq_calls;
