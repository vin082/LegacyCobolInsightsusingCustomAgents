// ============================================================
// COBOL Programs Called by Other Programs
// Query to find all programs that have incoming CALLS relationships
// ============================================================

// ============================================================
// Query 1: All programs that are called, with caller counts
// ============================================================
MATCH (caller:Program)-[:CALLS]->(called:Program)
RETURN DISTINCT called.program_id AS program_name, 
       called.estimated_complexity AS complexity,
       called.line_count AS lines,
       called.has_goto AS has_goto,
       called.has_alter AS has_alter,
       count(DISTINCT caller) AS called_by_count
ORDER BY called_by_count DESC, called.estimated_complexity DESC;

// ============================================================
// Query 2: Programs called with list of their callers
// ============================================================
MATCH (caller:Program)-[:CALLS]->(called:Program)
RETURN called.program_id AS called_program,
       collect(DISTINCT caller.program_id) AS calling_programs,
       called.estimated_complexity AS complexity,
       called.line_count AS lines,
       count(caller) AS number_of_callers
ORDER BY number_of_callers DESC;

// ============================================================
// Query 3: Top 20 most critical (most frequently called) programs
// These are key infrastructure components
// ============================================================
MATCH (p:Program)<-[:CALLS]-(caller:Program)
RETURN p.program_id AS critical_program,
       count(caller) AS inbound_calls,
       p.estimated_complexity AS complexity,
       p.migration_category AS migration_category,
       p.has_goto AS has_goto,
       p.has_alter AS has_alter,
       p.line_count AS lines
ORDER BY inbound_calls DESC
LIMIT 20;

// ============================================================
// Query 4: High-risk programs that are heavily used
// Programs with GOTO/ALTER that are called by many others
// ============================================================
MATCH (p:Program)<-[:CALLS]-(caller:Program)
WHERE p.has_goto = true OR p.has_alter = true
RETURN p.program_id AS high_risk_program,
       count(caller) AS inbound_calls,
       p.estimated_complexity AS complexity,
       p.has_goto AS has_goto,
       p.has_alter AS has_alter,
       p.line_count AS lines
ORDER BY inbound_calls DESC;

// ============================================================
// Query 5: Programs called with their full impact details
// Includes copybooks and paragraph counts
// ============================================================
MATCH (caller:Program)-[:CALLS]->(called:Program)
OPTIONAL MATCH (called)-[:INCLUDES]->(cb:Copybook)
OPTIONAL MATCH (called)-[:CONTAINS]->(para:Paragraph)
RETURN called.program_id AS program,
       count(DISTINCT caller) AS called_by_count,
       collect(DISTINCT caller.program_id)[0..5] AS sample_callers,
       count(DISTINCT cb) AS copybook_count,
       count(DISTINCT para) AS paragraph_count,
       called.estimated_complexity AS complexity,
       called.line_count AS lines
ORDER BY called_by_count DESC;
