// LegacyCobolInsights — Graph Integrity Validation
// Run after ingestion to check for data quality issues

// ============================================================
// CHECK 1: Programs with no paragraphs (incomplete parse)
// ============================================================
MATCH (p:Program)
WHERE NOT (p)-[:CONTAINS]->(:Paragraph)
RETURN 'WARN: Program with no paragraphs' AS issue,
       p.program_id AS artifact,
       p.source_path AS detail
ORDER BY p.program_id;

// ============================================================
// CHECK 2: Programs that CALL programs not in the graph
// ============================================================
MATCH (caller:Program)-[:CALLS]->(callee:Program)
WHERE callee.source_path IS NULL
  AND callee.parsed_at IS NULL
RETURN 'WARN: CALL target not in graph (external or missing)' AS issue,
       callee.program_id AS artifact,
       caller.program_id AS detail
ORDER BY callee.program_id;

// ============================================================
// CHECK 3: Programs that INCLUDE copybooks not in the graph
// ============================================================
MATCH (p:Program)-[:INCLUDES]->(cb:Copybook)
WHERE cb.parsed_at IS NULL
RETURN 'WARN: Copybook referenced but not parsed' AS issue,
       cb.name AS artifact,
       p.program_id AS detail
ORDER BY cb.name;

// ============================================================
// CHECK 4: Orphaned DataItems (not DEFINED by any copybook)
// ============================================================
MATCH (di:DataItem)
WHERE NOT ()-[:DEFINES]->(di)
RETURN 'WARN: DataItem without parent copybook' AS issue,
       di.fqn AS artifact,
       di.name AS detail
ORDER BY di.fqn;

// ============================================================
// CHECK 5: Orphaned paragraphs (not CONTAINED by any program)
// ============================================================
MATCH (para:Paragraph)
WHERE NOT ()-[:CONTAINS]->(para)
RETURN 'ERROR: Paragraph without parent program' AS issue,
       para.fqn AS artifact,
       para.name AS detail
ORDER BY para.fqn;

// ============================================================
// CHECK 6: Programs with ERROR parse status (check manifest)
// ============================================================
// Note: This check requires querying the manifest file.
// Run @cobol-ingestion to regenerate the manifest if needed.

// ============================================================
// CHECK 7: Circular CALL dependencies
// ============================================================
MATCH path = (a:Program)-[:CALLS*2..10]->(a)
WITH DISTINCT a, [n IN nodes(path) | n.program_id] AS cycle
RETURN 'CRITICAL: Circular dependency detected' AS issue,
       a.program_id AS artifact,
       reduce(s = '', name IN cycle | s + name + ' -> ') AS detail
ORDER BY a.program_id;

// ============================================================
// CHECK 8: Programs with ALTER (critical risk inventory)
// ============================================================
MATCH (p:Program)
WHERE p.has_alter = true
RETURN 'CRITICAL: ALTER verb detected' AS issue,
       p.program_id AS artifact,
       p.source_path AS detail
ORDER BY p.program_id;

// ============================================================
// SUMMARY
// ============================================================
MATCH (n) RETURN labels(n)[0] AS label, count(n) AS count ORDER BY count DESC;
MATCH ()-[r]->() RETURN type(r) AS rel_type, count(r) AS count ORDER BY count DESC;
