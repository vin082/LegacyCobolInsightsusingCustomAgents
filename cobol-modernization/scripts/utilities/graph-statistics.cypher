// LegacyCobolInsights — Graph Statistics
// Quick dashboard queries for understanding the knowledge graph state

// ============================================================
// NODE COUNTS BY LABEL
// ============================================================
MATCH (n)
RETURN labels(n)[0] AS node_type,
       count(n) AS count
ORDER BY count DESC;

// ============================================================
// RELATIONSHIP COUNTS BY TYPE
// ============================================================
MATCH ()-[r]->()
RETURN type(r) AS relationship_type,
       count(r) AS count
ORDER BY count DESC;

// ============================================================
// PROGRAM SIZE DISTRIBUTION
// ============================================================
MATCH (p:Program)
RETURN
    sum(CASE WHEN p.line_count < 200 THEN 1 ELSE 0 END) AS under_200_lines,
    sum(CASE WHEN p.line_count >= 200 AND p.line_count < 500 THEN 1 ELSE 0 END) AS lines_200_500,
    sum(CASE WHEN p.line_count >= 500 AND p.line_count < 1000 THEN 1 ELSE 0 END) AS lines_500_1000,
    sum(CASE WHEN p.line_count >= 1000 AND p.line_count < 2000 THEN 1 ELSE 0 END) AS lines_1000_2000,
    sum(CASE WHEN p.line_count >= 2000 THEN 1 ELSE 0 END) AS over_2000_lines,
    sum(p.line_count) AS total_lines_of_code,
    avg(p.line_count) AS average_lines,
    max(p.line_count) AS largest_program,
    min(p.line_count) AS smallest_program;

// ============================================================
// COMPLEXITY DISTRIBUTION
// ============================================================
MATCH (p:Program)
RETURN p.estimated_complexity AS complexity,
       count(p) AS program_count,
       round(count(p) * 100.0 / toFloat((MATCH (all:Program) RETURN count(all)))) AS percentage
ORDER BY program_count DESC;

// ============================================================
// RISK FLAG SUMMARY
// ============================================================
MATCH (p:Program)
RETURN
    count(p) AS total_programs,
    sum(CASE WHEN p.has_alter = true THEN 1 ELSE 0 END) AS programs_with_alter,
    sum(CASE WHEN p.has_goto = true THEN 1 ELSE 0 END) AS programs_with_goto,
    sum(CASE WHEN p.has_redefines = true THEN 1 ELSE 0 END) AS programs_with_redefines,
    sum(CASE WHEN p.has_alter = true OR p.has_goto = true THEN 1 ELSE 0 END) AS high_risk_programs;

// ============================================================
// TOP 10 MOST CALLED PROGRAMS (Critical Infrastructure)
// ============================================================
MATCH (p:Program)<-[:CALLS]-(caller:Program)
RETURN p.program_id,
       count(caller) AS inbound_calls,
       p.estimated_complexity,
       p.migration_category
ORDER BY inbound_calls DESC
LIMIT 10;

// ============================================================
// TOP 10 COPYBOOKS BY USAGE (Shared Data Infrastructure)
// ============================================================
MATCH (cb:Copybook)<-[:INCLUDES]-(p:Program)
RETURN cb.name,
       count(p) AS used_by_count,
       cb.data_item_count
ORDER BY used_by_count DESC
LIMIT 10;

// ============================================================
// MIGRATION READINESS DASHBOARD
// ============================================================
MATCH (p:Program)
RETURN p.migration_category AS category,
       count(p) AS program_count,
       avg(p.migration_score) AS avg_score,
       sum(p.line_count) AS total_lines,
       sum(CASE WHEN NOT ()-[:CALLS]->(p) THEN 1 ELSE 0 END) AS ready_to_start
ORDER BY avg_score ASC NULLS LAST;

// ============================================================
// DATABASE FRESHNESS
// ============================================================
MATCH (p:Program)
RETURN min(p.parsed_at) AS earliest_parse,
       max(p.parsed_at) AS latest_parse,
       count(CASE WHEN p.migration_score IS NULL THEN 1 END) AS unscored_programs;
