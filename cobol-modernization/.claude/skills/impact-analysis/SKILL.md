---
name: impact-analysis
description: Ripple effect analysis patterns for COBOL change impact. Covers how changes propagate through CALLS, INCLUDES, and shared data relationships. Use when impact-analyzer agent is performing blast radius assessment.
---

# Impact Analysis Reference

## Change Ripple Patterns

### Pattern 1: Program change — direct callers only
Risk: LOW to MEDIUM
Affects: Programs that directly CALL the changing program
```cypher
MATCH (caller:Program)-[:CALLS]->(target:Program {program_id: $name})
RETURN caller.program_id, caller.estimated_complexity
```

### Pattern 2: Program change — full upstream cascade
Risk: MEDIUM to HIGH
Affects: All programs in the call chain above the changed program
```cypher
MATCH path = (upstream)-[:CALLS*1..]->(target:Program {program_id: $name})
RETURN upstream.program_id, length(path) AS depth
ORDER BY depth
```

### Pattern 3: Copybook change — all users
Risk: HIGH (copybooks are shared)
Affects: Every program that INCLUDEs the copybook, plus their callers
```cypher
MATCH (p:Program)-[:INCLUDES]->(cb:Copybook {name: $name})
OPTIONAL MATCH (caller)-[:CALLS*1..5]->(p)
RETURN DISTINCT p.program_id AS direct, collect(DISTINCT caller.program_id) AS transitive
```

### Pattern 4: Data item change within copybook
Risk: HIGH if item is widely used
Strategy: Trace which paragraphs READ or WRITE files that use this data item
```cypher
MATCH (cb:Copybook {name: $copybook})-[:DEFINES]->(di:DataItem {name: $item})
MATCH (p:Program)-[:INCLUDES]->(cb)
RETURN p.program_id, p.estimated_complexity
```

## Impact Scoring Matrix

| Factor | Weight | Scoring |
|---|---|---|
| Direct caller count | 30% | 0 callers=0, 1-3=1, 4-7=2, 8+=3 |
| Transitive caller depth | 20% | depth 1=1, 2=2, 3+=3 |
| Copybook breadth | 25% | 1 program=0, 2-5=1, 6-10=2, 10+=3 |
| Program complexity | 15% | LOW=0, MEDIUM=1, HIGH=2, CRITICAL=3 |
| Risk flags | 10% | 0 flags=0, 1=1, 2=2, 3=3 |

Total score 0-3: LOW | 4-6: MEDIUM | 7-9: HIGH | 10-12: CRITICAL

## Recommended Change Sequencing
1. Change deepest-leaf artefact first
2. Work upward through the call chain
3. Run regression tests at each level
4. For copybook changes: notify all program owners before starting
5. For ALTER-containing programs: freeze all changes until ALTER is eliminated

## For detailed ripple effect patterns: read RIPPLE-PATTERNS.md
