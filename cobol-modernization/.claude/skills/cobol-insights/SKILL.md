---
name: cobol-insights
description: Modernization analysis heuristics, complexity scoring rubrics, migration wave planning guidance, and interpretation of COBOL knowledge graph metrics. Use when graph-query, complexity-scorer, or migration-advisor needs to interpret results or make recommendations.
---

# COBOL Modernization Insights

## Reading Complexity Scores

| Score | Category | Interpretation | Typical Effort |
|---|---|---|---|
| 1-25 | EASY | Leaf programs, low coupling, clean structure | 3-7 days |
| 26-50 | MODERATE | Some coupling, possible REDEFINES, medium size | 1-3 weeks |
| 51-75 | HARD | High coupling, GOTOs, large size, shared copybooks | 1-2 months |
| 76-100 | CRITICAL | ALTER present, circular deps, 2000+ lines | Evaluate rewrite |

## Migration Wave Planning

### Wave 1 — Foundation (Months 1-2)
Target: EASY programs with zero inbound calls
Goal: Build Java muscle, establish patterns, prove the toolchain
Criteria:
```cypher
MATCH (p:Program)
WHERE p.migration_category = 'EASY'
  AND NOT ()-[:CALLS]->(p)
RETURN p.program_id ORDER BY p.migration_score
```

### Wave 2 — Service Extraction (Months 3-5)
Target: MODERATE programs that are highly called (high fan-in)
Goal: Replace shared subroutines with Java services others can call
Criteria:
```cypher
MATCH (p:Program)<-[:CALLS]-(callers)
WHERE p.migration_category = 'MODERATE'
RETURN p.program_id, count(callers) AS fan_in
ORDER BY fan_in DESC
```

### Wave 3 — Core Programs (Months 6-10)
Target: HARD programs after their dependencies are migrated
Strategy: Strangler fig pattern — wrap in Java, migrate incrementally

### Wave 4 — Legacy Cores (Month 10+)
Target: CRITICAL programs
Decision point: Full rewrite vs. keep-and-wrap
Tools: Anti-corruption layer pattern

## Key Metrics to Track

| Metric | Good | Warning | Critical |
|---|---|---|---|
| Average fan-in (incoming calls) | < 3 | 3-8 | > 8 |
| Programs with GOTO | < 5% | 5-15% | > 15% |
| Programs with ALTER | 0 | 1-2 | > 2 |
| Copybook usage breadth | < 5 programs | 5-10 | > 10 |
| Circular dependency count | 0 | 1-3 | > 3 |

## Interpreting the Call Graph

- **High fan-in programs** (many callers) → migrate LAST; they are shared infrastructure
- **High fan-out programs** (many callees) → migrate AFTER all callees are done
- **Isolated programs** (no calls in or out) → migrate FIRST; zero risk
- **Circular dependencies** → must be broken before migration; introduce interface layer

## Common Questions and Cypher Answers

**"Where should we start migrating?"**
→ Run complexity-scorer, then query EASY + zero fan-in programs

**"What breaks if we change X?"**
→ Run impact-analyzer on X

**"Which copybook change would cause the most disruption?"**
→ Query copybooks ordered by program usage count (descending)

**"Are there any dead programs (never called)?"**
```cypher
MATCH (p:Program)
WHERE NOT ()-[:CALLS]->(p) AND NOT ()-[:EXECUTES]->(p)
RETURN p.program_id, p.line_count
ORDER BY p.line_count DESC
```

## For full complexity scoring heuristics: read COMPLEXITY-HEURISTICS.md
## For migration readiness scoring rubrics: read MIGRATION-READINESS.md
