// LegacyCobolInsights — Export Graph as JSON
// Exports the full graph in a portable JSON format for reporting or backup

// ============================================================
// EXPORT: All Programs with their full metadata
// ============================================================
MATCH (p:Program)
OPTIONAL MATCH (p)-[:CALLS]->(callee:Program)
OPTIONAL MATCH (caller:Program)-[:CALLS]->(p)
OPTIONAL MATCH (p)-[:INCLUDES]->(cb:Copybook)
OPTIONAL MATCH (p)-[:CONTAINS]->(para:Paragraph)
RETURN {
    program_id: p.program_id,
    source_path: p.source_path,
    author: p.author,
    date_written: p.date_written,
    line_count: p.line_count,
    estimated_complexity: p.estimated_complexity,
    migration_score: p.migration_score,
    migration_category: p.migration_category,
    has_goto: p.has_goto,
    has_alter: p.has_alter,
    has_redefines: p.has_redefines,
    calls: collect(DISTINCT callee.program_id),
    called_by: collect(DISTINCT caller.program_id),
    includes_copybooks: collect(DISTINCT cb.name),
    paragraph_count: count(DISTINCT para)
} AS program_export
ORDER BY p.program_id;

// ============================================================
// EXPORT: All Copybooks with data items
// ============================================================
MATCH (cb:Copybook)
OPTIONAL MATCH (cb)-[:DEFINES]->(di:DataItem)
OPTIONAL MATCH (p:Program)-[:INCLUDES]->(cb)
RETURN {
    name: cb.name,
    source_path: cb.source_path,
    data_item_count: cb.data_item_count,
    used_by_programs: collect(DISTINCT p.program_id),
    data_items: collect(DISTINCT {
        name: di.name,
        level: di.level,
        pic: di.pic,
        has_redefines: di.has_redefines,
        has_occurs: di.has_occurs
    })
} AS copybook_export
ORDER BY cb.name;

// ============================================================
// EXPORT: Call Graph Adjacency List
// ============================================================
MATCH (p:Program)
OPTIONAL MATCH (p)-[:CALLS]->(callee:Program)
RETURN p.program_id AS program,
       collect(callee.program_id) AS calls
ORDER BY p.program_id;

// ============================================================
// EXPORT: Migration Summary Statistics
// ============================================================
MATCH (p:Program)
RETURN {
    total_programs: count(p),
    total_lines: sum(p.line_count),
    easy_count: sum(CASE WHEN p.migration_category = 'EASY' THEN 1 ELSE 0 END),
    moderate_count: sum(CASE WHEN p.migration_category = 'MODERATE' THEN 1 ELSE 0 END),
    hard_count: sum(CASE WHEN p.migration_category = 'HARD' THEN 1 ELSE 0 END),
    critical_count: sum(CASE WHEN p.migration_category = 'CRITICAL' THEN 1 ELSE 0 END),
    programs_with_goto: sum(CASE WHEN p.has_goto THEN 1 ELSE 0 END),
    programs_with_alter: sum(CASE WHEN p.has_alter THEN 1 ELSE 0 END),
    avg_migration_score: avg(p.migration_score)
} AS summary;
