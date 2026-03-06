# Complexity Heuristics for COBOL Migration Scoring

## Cyclomatic Complexity Proxy

COBOL doesn't expose cyclomatic complexity directly. We approximate it by counting
decision points in the PROCEDURE DIVISION:

| Construct | Decision Points |
|-----------|----------------|
| IF ... END-IF | +1 |
| IF ... ELSE ... END-IF | +2 |
| EVALUATE WHEN clause | +1 per WHEN |
| PERFORM ... UNTIL | +1 |
| PERFORM ... VARYING | +1 |
| READ ... AT END | +1 |
| CALL ... ON EXCEPTION | +1 |
| GO TO (conditional: IF x GO TO) | +1 |

### Complexity Buckets

| Decision Points | Complexity Score | Label |
|-----------------|-----------------|-------|
| 0-9 | 1 | Very low — almost sequential |
| 10-24 | 2 | Low — simple branching |
| 25-49 | 3 | Medium — moderate branching |
| 50-99 | 4 | High — complex logic |
| 100+ | 5 | Critical — very high complexity |

## Size Heuristics

### Lines of Code Buckets

| Lines of Code | Size Score | Migration Implication |
|---------------|------------|----------------------|
| < 200 | 1 | Small utility — easy to rewrite |
| 200-500 | 2 | Small program — 1-2 weeks |
| 500-1000 | 3 | Medium program — 2-4 weeks |
| 1000-2000 | 4 | Large program — 1-2 months |
| > 2000 | 5 | Very large — evaluate splitting |

### Size vs Complexity Matrix

Programs can be large but simple (batch loops) or small but complex (dense EVALUATE chains).
Always combine size and cyclomatic complexity:

| Size \ Complexity | Low (1-2) | Medium (3) | High (4-5) |
|-------------------|-----------|------------|------------|
| Small (1-2) | EASY | MODERATE | HARD |
| Medium (3) | MODERATE | MODERATE | HARD |
| Large (4-5) | HARD | HARD | CRITICAL |

## Coupling Heuristics

### Fan-In (How many programs call this one)

| Fan-In | Coupling Score | Implication |
|--------|---------------|-------------|
| 0 | 0 | Isolated — safe to migrate first |
| 1-3 | 1 | Low coupling — manageable |
| 4-7 | 2 | Medium coupling — need coordination |
| 8-15 | 3 | High coupling — shared service |
| 16+ | 4 | Critical — central infrastructure |

High fan-in = migrate LAST (many callers depend on this program's interface).

### Fan-Out (How many programs this one calls)

| Fan-Out | Coupling Score | Implication |
|---------|---------------|-------------|
| 0 | 0 | No dependencies — free to migrate |
| 1-3 | 1 | Low — a few dependencies |
| 4-7 | 2 | Medium — must migrate dependencies first |
| 8-15 | 3 | High — many dependencies |
| 16+ | 4 | Very high — orchestrator-type program |

### Copybook Dependencies

Each shared copybook is a hidden coupling point:

| Copybooks Used | Score |
|----------------|-------|
| 0-1 | 0 |
| 2-3 | 1 |
| 4-6 | 2 |
| 7+ | 3 |

## Risk Flag Multipliers

Risk flags directly impact migration difficulty:

| Flag | Base Add | Reason |
|------|----------|--------|
| has_alter | +3 | Self-modifying — requires deep manual analysis |
| has_goto | +1 | Spaghetti flow — harder to refactor |
| has_redefines | +1 | Union types — careful Java modeling needed |
| has_occurs_depending_on | +1 | Dynamic arrays — size management |
| circular_dependency | +2 | Must break cycle before migrating |

## Worked Example

**Program: CUSTOMER-PROC**
- Lines: 450 → Size score = 2
- Decision points: 18 → Complexity score = 2
- Fan-in: 2, Fan-out: 2, Copybooks: 2 → Coupling = (2+2+2) = 6 → Score = 2
- Risk flags: has_redefines=true → Risk score = 1

```
migration_score = (2 * 0.2) + (2 * 0.3) + (2 * 0.3) + (1 * 0.2 * 5/3)
               = 0.4 + 0.6 + 0.6 + 0.33
               = 1.93 (raw)
```

Normalized to 1-100: multiply raw by ~17 → score ≈ 33 → MODERATE

**Interpretation:** Standard effort, can be tackled in Wave 2 after simpler programs.
