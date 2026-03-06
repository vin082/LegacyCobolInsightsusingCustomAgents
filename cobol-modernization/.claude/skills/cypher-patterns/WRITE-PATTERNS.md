# Cypher Write Patterns for COBOL Ingestion

All write operations use MERGE to ensure idempotency. Running the same ingestion
twice produces the same graph state (no duplicates).

## Program Node Creation

```cypher
MERGE (p:Program {program_id: $program_id})
ON CREATE SET p.created_at = datetime()
ON MATCH SET p.updated_at = datetime()
SET p.source_path = $source_path,
    p.author = $author,
    p.date_written = $date_written,
    p.line_count = $line_count,
    p.has_goto = $has_goto,
    p.has_alter = $has_alter,
    p.has_redefines = $has_redefines,
    p.estimated_complexity = $estimated_complexity,
    p.parsed_at = $parsed_at
```

## Copybook Node Creation

```cypher
MERGE (cb:Copybook {name: $name})
ON CREATE SET cb.created_at = datetime()
SET cb.source_path = $source_path,
    cb.data_item_count = $data_item_count,
    cb.parsed_at = $parsed_at
```

## DataItem Creation with Relationship

```cypher
MERGE (di:DataItem {fqn: $copybook_name + '.' + $item_name})
SET di.name = $item_name,
    di.level = $level,
    di.pic = $pic,
    di.value = $value,
    di.has_redefines = $has_redefines,
    di.has_occurs = $has_occurs,
    di.occurs_times = $occurs_times
WITH di
MERGE (cb:Copybook {name: $copybook_name})
MERGE (cb)-[:DEFINES]->(di)
```

## Paragraph Bulk Creation (UNWIND)

```cypher
UNWIND $paragraphs AS para
MERGE (p:Paragraph {fqn: $program_id + '.' + para.name})
SET p.name = para.name,
    p.line_start = para.line_start,
    p.line_end = para.line_end,
    p.line_count = para.line_end - para.line_start,
    p.decision_points = para.decision_points
WITH p, para
MERGE (prog:Program {program_id: $program_id})
MERGE (prog)-[:CONTAINS]->(p)
MERGE (p)-[:OWNED_BY]->(prog)
```

## PERFORMS Relationship

```cypher
MATCH (from_para:Paragraph {fqn: $program_id + '.' + $from_name})
MATCH (to_para:Paragraph {fqn: $program_id + '.' + $to_name})
MERGE (from_para)-[:PERFORMS {thru: $is_thru}]->(to_para)
```

## CALLS Relationship Between Programs

```cypher
MERGE (caller:Program {program_id: $caller_id})
MERGE (callee:Program {program_id: $callee_id})
MERGE (caller)-[r:CALLS]->(callee)
SET r.using_params = $params
```

Note: Use MERGE for both Program nodes to handle cases where callee program
is not yet in the graph (stub creation).

## INCLUDES Relationship (Copybook Usage)

```cypher
MERGE (p:Program {program_id: $program_id})
MERGE (cb:Copybook {name: $copybook_name})
MERGE (p)-[:INCLUDES]->(cb)
```

## File Node and READ/WRITE Relationships

```cypher
MERGE (f:CobolFile {logical_name: $logical_name})
SET f.physical_name = $physical_name,
    f.organisation = $organisation

WITH f
MATCH (para:Paragraph {fqn: $para_fqn})
MERGE (para)-[:READS]->(f)
```

```cypher
MATCH (para:Paragraph {fqn: $para_fqn})
MERGE (f:CobolFile {logical_name: $logical_name})
MERGE (para)-[:WRITES]->(f)
```

## JCL Job with EXECUTES Relationship

```cypher
MERGE (job:JCLJob {job_name: $job_name})
SET job.source_path = $source_path,
    job.scheduler = $scheduler

WITH job
MERGE (prog:Program {program_id: $program_id})
MERGE (job)-[:EXECUTES {step_name: $step_name}]->(prog)
```

## Bulk Processing Pattern (large datasets)

Use CALL {} IN TRANSACTIONS for large datasets to avoid memory issues:

```cypher
CALL {
    UNWIND $batch AS record
    MERGE (p:Program {program_id: record.program_id})
    SET p += record.properties
} IN TRANSACTIONS OF 100 ROWS
```

## Clearing All Data (for fresh re-ingestion)

```cypher
// Delete all nodes and relationships
MATCH (n) DETACH DELETE n
```

Or selectively:
```cypher
MATCH (p:Program) DETACH DELETE p
MATCH (cb:Copybook) DETACH DELETE cb
```
