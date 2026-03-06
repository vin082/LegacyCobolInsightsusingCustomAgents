# Cypher Query Patterns for COBOL Analysis

## Dependency Analysis

### Direct callers of a program
```cypher
MATCH (caller:Program)-[:CALLS]->(target:Program {program_id: $name})
RETURN caller.program_id,
       caller.estimated_complexity,
       caller.migration_category
ORDER BY caller.estimated_complexity DESC
```

### Full upstream call chain (all programs that eventually call X)
```cypher
MATCH path = (upstream:Program)-[:CALLS*1..15]->(target:Program {program_id: $name})
RETURN DISTINCT upstream.program_id,
       min(length(path)) AS closest_hop,
       upstream.estimated_complexity
ORDER BY closest_hop, upstream.estimated_complexity DESC
```

### Full downstream call chain (everything X calls, recursively)
```cypher
MATCH path = (start:Program {program_id: $name})-[:CALLS*1..15]->(downstream:Program)
RETURN DISTINCT downstream.program_id,
       min(length(path)) AS hop_count,
       downstream.estimated_complexity
ORDER BY hop_count, downstream.program_id
```

### Shared dependencies (programs both A and B depend on)
```cypher
MATCH (a:Program {program_id: $prog_a})-[:CALLS*1..5]->(shared:Program)
MATCH (b:Program {program_id: $prog_b})-[:CALLS*1..5]->(shared)
RETURN shared.program_id, shared.estimated_complexity
ORDER BY shared.program_id
```

## Copybook Analysis

### All programs using a copybook
```cypher
MATCH (p:Program)-[:INCLUDES]->(cb:Copybook {name: $copybook_name})
RETURN p.program_id, p.source_path, p.estimated_complexity, p.migration_category
ORDER BY p.estimated_complexity DESC, p.program_id
```

### Copybooks sorted by usage (most shared first)
```cypher
MATCH (cb:Copybook)<-[:INCLUDES]-(p:Program)
RETURN cb.name,
       count(DISTINCT p) AS used_by,
       collect(p.program_id)[0..5] AS sample_users
ORDER BY used_by DESC
LIMIT 20
```

### Data items in a copybook
```cypher
MATCH (cb:Copybook {name: $copybook_name})-[:DEFINES]->(di:DataItem)
RETURN di.level, di.name, di.pic, di.has_redefines, di.has_occurs
ORDER BY di.level, di.name
```

## Complexity and Risk Analysis

### All high-risk programs
```cypher
MATCH (p:Program)
WHERE p.has_alter = true
   OR p.has_goto = true
   OR p.estimated_complexity IN ['HIGH', 'CRITICAL']
RETURN p.program_id,
       p.has_alter,
       p.has_goto,
       p.has_redefines,
       p.estimated_complexity,
       p.line_count
ORDER BY
    p.has_alter DESC,
    p.has_goto DESC,
    p.line_count DESC
```

### Programs by complexity distribution
```cypher
MATCH (p:Program)
RETURN p.estimated_complexity AS complexity,
       count(p) AS count,
       avg(p.line_count) AS avg_lines,
       sum(p.line_count) AS total_lines
ORDER BY count DESC
```

### Coupling leaderboard (most connected programs)
```cypher
MATCH (p:Program)
OPTIONAL MATCH (p)-[:CALLS]->(callee)
OPTIONAL MATCH (caller)-[:CALLS]->(p)
OPTIONAL MATCH (p)-[:INCLUDES]->(cb)
RETURN p.program_id,
       count(DISTINCT callee) AS fan_out,
       count(DISTINCT caller) AS fan_in,
       count(DISTINCT cb) AS copybook_count,
       count(DISTINCT callee) + count(DISTINCT caller) AS total_coupling
ORDER BY total_coupling DESC
LIMIT 25
```

## Migration Planning

### Best candidates for Wave 1 (EASY, no inbound calls)
```cypher
MATCH (p:Program)
WHERE p.migration_category = 'EASY'
  AND NOT ()-[:CALLS]->(p)
  AND p.has_alter = false
  AND p.has_goto = false
RETURN p.program_id, p.migration_score, p.line_count
ORDER BY p.migration_score ASC, p.line_count ASC
```

### Programs ready to migrate (all dependencies already migrated)
```cypher
// Programs where all callees have migration_category = 'DONE'
MATCH (p:Program)
WHERE NOT EXISTS {
    MATCH (p)-[:CALLS]->(dep:Program)
    WHERE dep.migration_category <> 'DONE'
}
AND p.migration_category <> 'DONE'
RETURN p.program_id, p.migration_category, p.migration_score
ORDER BY p.migration_score ASC
```

### Programs with circular dependencies
```cypher
MATCH path = (a:Program)-[:CALLS*2..10]->(a)
RETURN DISTINCT a.program_id AS circular_program,
       length(path) AS cycle_length
ORDER BY cycle_length
```

## Graph Health Checks

### Orphaned programs (in graph but no calls to/from)
```cypher
MATCH (p:Program)
WHERE NOT ()-[:CALLS]->(p)
  AND NOT (p)-[:CALLS]->()
  AND NOT ()-[:EXECUTES]->(p)
RETURN p.program_id, p.line_count, p.estimated_complexity
ORDER BY p.line_count DESC
```

### Programs in graph but not yet scored
```cypher
MATCH (p:Program)
WHERE p.migration_score IS NULL
RETURN p.program_id, p.estimated_complexity, p.line_count
ORDER BY p.line_count DESC
```

### Paragraphs without a parent program (data integrity check)
```cypher
MATCH (para:Paragraph)
WHERE NOT ()-[:CONTAINS]->(para)
RETURN para.fqn, para.name
ORDER BY para.fqn
```
