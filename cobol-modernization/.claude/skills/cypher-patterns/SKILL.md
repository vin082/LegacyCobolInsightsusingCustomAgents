---
name: cypher-patterns
description: Proven Cypher query and write patterns for the LegacyCobolInsights graph. Includes MERGE templates for ingestion, common traversal queries for analysis, and aggregation patterns for reporting. Use when writing to or querying Neo4j.
---

# Cypher Pattern Library

## Write Patterns (Ingestion)

### Safe MERGE — always idempotent
```cypher
MERGE (p:Program {program_id: $program_id})
ON CREATE SET p.created_at = datetime()
ON MATCH SET p.updated_at = datetime()
SET p.source_path = $source_path,
    p.line_count = $line_count
```

### Create relationship safely
```cypher
MATCH (a:Program {program_id: $caller})
MATCH (b:Program {program_id: $callee})
MERGE (a)-[r:CALLS]->(b)
SET r.using_params = $params
```

### Bulk paragraph creation (use UNWIND for arrays)
```cypher
UNWIND $paragraphs AS para
MERGE (p:Paragraph {fqn: $program_id + '.' + para.name})
SET p.name = para.name,
    p.line_start = para.line_start,
    p.line_end = para.line_end
MERGE (prog:Program {program_id: $program_id})
MERGE (prog)-[:CONTAINS]->(p)
```

## Read Patterns (Analysis)

### Full dependency tree (bounded depth)
```cypher
MATCH path = (start:Program {program_id: $name})-[:CALLS*1..10]->(end:Program)
RETURN path, length(path) AS depth
ORDER BY depth
```

### Reverse: everything that calls this program
```cypher
MATCH path = (caller:Program)-[:CALLS*1..10]->(target:Program {program_id: $name})
RETURN caller.program_id, length(path) AS hops
ORDER BY hops
```

### Copybook blast radius
```cypher
MATCH (cb:Copybook {name: $copybook_name})<-[:INCLUDES]-(p:Program)
OPTIONAL MATCH (p)<-[:CALLS*1..5]-(upstream:Program)
RETURN DISTINCT p.program_id AS direct_user,
       collect(DISTINCT upstream.program_id) AS transitive_callers
```

### Find circular dependencies
```cypher
MATCH (a:Program)-[:CALLS*2..]->(a)
RETURN a.program_id AS circular_program
```

### Programs with no inbound calls (leaf programs — safe to migrate first)
```cypher
MATCH (p:Program)
WHERE NOT ()-[:CALLS]->(p)
RETURN p.program_id, p.migration_score, p.migration_category
ORDER BY p.migration_score ASC
```

### Fan-in / Fan-out coupling metrics
```cypher
MATCH (p:Program)
OPTIONAL MATCH (p)-[:CALLS]->(callee)
OPTIONAL MATCH (caller)-[:CALLS]->(p)
RETURN p.program_id,
       count(DISTINCT callee) AS fan_out,
       count(DISTINCT caller) AS fan_in,
       count(DISTINCT callee) + count(DISTINCT caller) AS total_coupling
ORDER BY total_coupling DESC
LIMIT 20
```

### Data items shared across most programs (high-risk copybooks)
```cypher
MATCH (cb:Copybook)<-[:INCLUDES]-(p:Program)
RETURN cb.name, count(p) AS used_by_programs
ORDER BY used_by_programs DESC
LIMIT 10
```

## Aggregation Patterns (Reporting)

### Node count by label
```cypher
MATCH (n) RETURN labels(n)[0] AS label, count(n) AS count ORDER BY count DESC
```

### Relationship count by type
```cypher
MATCH ()-[r]->() RETURN type(r) AS rel, count(r) AS count ORDER BY count DESC
```

### Migration readiness dashboard
```cypher
MATCH (p:Program)
RETURN p.migration_category AS category,
       count(p) AS programs,
       avg(p.migration_score) AS avg_score,
       sum(p.line_count) AS total_lines
ORDER BY avg_score ASC
```

## For ingestion-specific patterns: read WRITE-PATTERNS.md
## For analysis query templates: read QUERY-PATTERNS.md
