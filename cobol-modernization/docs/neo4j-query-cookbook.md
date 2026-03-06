# Neo4j Query Cookbook

Useful Cypher queries for exploring the COBOL knowledge graph directly.
Run these in Neo4j Browser or via `@graph-query`.

## Getting Started

### Is data loaded?
```cypher
MATCH (n) RETURN labels(n)[0] AS label, count(n) AS count ORDER BY count DESC
```

### How many relationships?
```cypher
MATCH ()-[r]->() RETURN type(r) AS rel, count(r) AS count ORDER BY count DESC
```

---

## Program Exploration

### List all programs
```cypher
MATCH (p:Program)
RETURN p.program_id, p.line_count, p.estimated_complexity, p.author
ORDER BY p.program_id
```

### Find a specific program and its details
```cypher
MATCH (p:Program {program_id: 'CUSTOMER-PROC'})
OPTIONAL MATCH (p)-[:CALLS]->(callee:Program)
OPTIONAL MATCH (caller:Program)-[:CALLS]->(p)
OPTIONAL MATCH (p)-[:INCLUDES]->(cb:Copybook)
RETURN p,
       collect(DISTINCT callee.program_id) AS calls,
       collect(DISTINCT caller.program_id) AS called_by,
       collect(DISTINCT cb.name) AS copybooks
```

### Programs sorted by complexity
```cypher
MATCH (p:Program)
RETURN p.program_id, p.estimated_complexity, p.line_count, p.migration_score
ORDER BY
    CASE p.estimated_complexity
        WHEN 'CRITICAL' THEN 4
        WHEN 'HIGH' THEN 3
        WHEN 'MEDIUM' THEN 2
        ELSE 1
    END DESC,
    p.line_count DESC
```

---

## Call Graph Queries

### Who calls ACCOUNT-MGR?
```cypher
MATCH (caller:Program)-[:CALLS]->(target:Program {program_id: 'ACCOUNT-MGR'})
RETURN caller.program_id, caller.estimated_complexity
```

### Full call chain FROM a program (downstream)
```cypher
MATCH path = (start:Program {program_id: 'BATCH-RUNNER'})-[:CALLS*1..10]->(end:Program)
RETURN DISTINCT end.program_id, min(length(path)) AS hops
ORDER BY hops
```

### Full call chain TO a program (upstream)
```cypher
MATCH path = (start:Program)-[:CALLS*1..10]->(end:Program {program_id: 'PAYMENT-HANDLER'})
RETURN DISTINCT start.program_id, min(length(path)) AS hops
ORDER BY hops
```

### Programs with no callers (entry points / candidates for Wave 1)
```cypher
MATCH (p:Program)
WHERE NOT ()-[:CALLS]->(p)
RETURN p.program_id, p.migration_score, p.line_count
ORDER BY p.migration_score ASC NULLS LAST
```

### Programs that call the most other programs (orchestrators)
```cypher
MATCH (p:Program)-[:CALLS]->(callee:Program)
RETURN p.program_id, count(callee) AS fan_out
ORDER BY fan_out DESC LIMIT 10
```

### Programs called by the most programs (shared services)
```cypher
MATCH (p:Program)<-[:CALLS]-(caller:Program)
RETURN p.program_id, count(caller) AS fan_in, p.estimated_complexity
ORDER BY fan_in DESC LIMIT 10
```

### Find circular dependencies
```cypher
MATCH path = (a:Program)-[:CALLS*2..10]->(a)
RETURN DISTINCT a.program_id, length(path) AS cycle_length
ORDER BY cycle_length
```

---

## Copybook Queries

### Which programs use CUSTOMER-RECORD?
```cypher
MATCH (p:Program)-[:INCLUDES]->(cb:Copybook {name: 'CUSTOMER-RECORD'})
RETURN p.program_id, p.source_path, p.estimated_complexity
ORDER BY p.program_id
```

### All copybooks and their usage counts
```cypher
MATCH (cb:Copybook)
OPTIONAL MATCH (p:Program)-[:INCLUDES]->(cb)
RETURN cb.name, count(p) AS used_by_count, cb.data_item_count
ORDER BY used_by_count DESC
```

### Data items in a copybook
```cypher
MATCH (cb:Copybook {name: 'CUSTOMER-RECORD'})-[:DEFINES]->(di:DataItem)
RETURN di.level, di.name, di.pic, di.has_redefines, di.has_occurs
ORDER BY di.level, di.name
```

### Copybooks with REDEFINES fields (migration risk)
```cypher
MATCH (cb:Copybook)-[:DEFINES]->(di:DataItem)
WHERE di.has_redefines = true
RETURN cb.name, collect(di.name) AS redefines_fields
ORDER BY cb.name
```

---

## Risk Analysis Queries

### All programs with GOTO or ALTER
```cypher
MATCH (p:Program)
WHERE p.has_goto = true OR p.has_alter = true
RETURN p.program_id, p.has_goto, p.has_alter, p.estimated_complexity, p.line_count
ORDER BY p.has_alter DESC, p.has_goto DESC, p.line_count DESC
```

### Programs with REDEFINES (data structure complexity)
```cypher
MATCH (p:Program {has_redefines: true})
RETURN p.program_id, p.estimated_complexity, p.line_count
ORDER BY p.line_count DESC
```

### Risk matrix: programs with multiple risk flags
```cypher
MATCH (p:Program)
WITH p,
     (CASE WHEN p.has_alter THEN 1 ELSE 0 END +
      CASE WHEN p.has_goto THEN 1 ELSE 0 END +
      CASE WHEN p.has_redefines THEN 1 ELSE 0 END) AS risk_count
WHERE risk_count > 0
RETURN p.program_id, risk_count, p.has_alter, p.has_goto, p.has_redefines
ORDER BY risk_count DESC, p.program_id
```

---

## Migration Planning Queries

### Wave 1 candidates (EASY, no inbound calls)
```cypher
MATCH (p:Program)
WHERE p.migration_category = 'EASY'
  AND NOT ()-[:CALLS]->(p)
RETURN p.program_id, p.migration_score, p.line_count
ORDER BY p.migration_score ASC NULLS LAST
```

### Migration backlog overview
```cypher
MATCH (p:Program)
RETURN p.migration_category AS wave,
       count(p) AS count,
       avg(p.migration_score) AS avg_score,
       sum(p.line_count) AS total_lines
ORDER BY avg_score ASC NULLS LAST
```

### Programs not yet scored
```cypher
MATCH (p:Program)
WHERE p.migration_score IS NULL
RETURN p.program_id, p.estimated_complexity, p.line_count
ORDER BY p.line_count DESC
```

---

## Paragraph Exploration

### Paragraphs in a program
```cypher
MATCH (prog:Program {program_id: 'CUSTOMER-PROC'})-[:CONTAINS]->(para:Paragraph)
RETURN para.name, para.line_start, para.line_end, para.decision_points
ORDER BY para.line_start
```

### PERFORMS flow within a program
```cypher
MATCH (from_para:Paragraph)-[:PERFORMS]->(to_para:Paragraph)
MATCH (prog:Program {program_id: 'CUSTOMER-PROC'})-[:CONTAINS]->(from_para)
RETURN from_para.name AS calls_from, to_para.name AS calls_to
ORDER BY from_para.name
```

### Paragraphs with most decision points (complex logic)
```cypher
MATCH (prog:Program)-[:CONTAINS]->(para:Paragraph)
WHERE para.decision_points IS NOT NULL
RETURN prog.program_id, para.name, para.decision_points, para.line_count
ORDER BY para.decision_points DESC
LIMIT 20
```
