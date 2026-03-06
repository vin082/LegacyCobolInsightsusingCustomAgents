// LegacyCobolInsights — Relationship Integrity Validation
// Checks referential integrity of all relationship types

// ============================================================
// CALLS relationships
// ============================================================

// All CALLS: verify both endpoints are Programs
MATCH (a)-[r:CALLS]->(b)
WHERE NOT a:Program OR NOT b:Program
RETURN 'ERROR: CALLS relationship with non-Program endpoint' AS issue,
       type(r) AS rel_type,
       labels(a) AS from_labels,
       labels(b) AS to_labels;

// ============================================================
// CONTAINS relationships
// ============================================================

// All CONTAINS: verify Program → Paragraph
MATCH (a)-[r:CONTAINS]->(b)
WHERE NOT a:Program OR NOT b:Paragraph
RETURN 'ERROR: CONTAINS relationship not Program->Paragraph' AS issue,
       labels(a) AS from_labels,
       labels(b) AS to_labels;

// ============================================================
// PERFORMS relationships
// ============================================================

// All PERFORMS: verify Paragraph → Paragraph
MATCH (a)-[r:PERFORMS]->(b)
WHERE NOT a:Paragraph OR NOT b:Paragraph
RETURN 'ERROR: PERFORMS relationship not Paragraph->Paragraph' AS issue,
       labels(a) AS from_labels,
       labels(b) AS to_labels;

// PERFORMS target paragraphs should be in same program
MATCH (from_para:Paragraph)-[:PERFORMS]->(to_para:Paragraph)
MATCH (prog_from:Program)-[:CONTAINS]->(from_para)
WHERE NOT (prog_from)-[:CONTAINS]->(to_para)
RETURN 'WARN: PERFORMS crosses program boundary' AS issue,
       from_para.fqn AS from_para,
       to_para.fqn AS to_para,
       prog_from.program_id AS program;

// ============================================================
// INCLUDES relationships
// ============================================================

// All INCLUDES: verify Program → Copybook
MATCH (a)-[r:INCLUDES]->(b)
WHERE NOT a:Program OR NOT b:Copybook
RETURN 'ERROR: INCLUDES relationship not Program->Copybook' AS issue,
       labels(a) AS from_labels,
       labels(b) AS to_labels;

// ============================================================
// DEFINES relationships
// ============================================================

// All DEFINES: verify Copybook → DataItem
MATCH (a)-[r:DEFINES]->(b)
WHERE NOT a:Copybook OR NOT b:DataItem
RETURN 'ERROR: DEFINES relationship not Copybook->DataItem' AS issue,
       labels(a) AS from_labels,
       labels(b) AS to_labels;

// ============================================================
// READS / WRITES relationships
// ============================================================

// All READS/WRITES: verify Paragraph → CobolFile
MATCH (a)-[r:READS|WRITES]->(b)
WHERE NOT a:Paragraph OR NOT b:CobolFile
RETURN 'ERROR: READS/WRITES relationship not Paragraph->CobolFile' AS issue,
       type(r) AS rel_type,
       labels(a) AS from_labels,
       labels(b) AS to_labels;

// ============================================================
// REFERENTIAL INTEGRITY: Files referenced in READS/WRITES exist
// ============================================================
MATCH (f:CobolFile)
WHERE NOT ()-[:READS]->(f) AND NOT ()-[:WRITES]->(f)
RETURN 'WARN: CobolFile defined but never accessed' AS issue,
       f.logical_name AS artifact,
       f.physical_name AS detail
ORDER BY f.logical_name;

// ============================================================
// SUMMARY: Relationship counts by type
// ============================================================
MATCH ()-[r]->()
RETURN type(r) AS relationship_type,
       count(r) AS count
ORDER BY count DESC;
