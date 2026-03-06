# Migration Readiness — Scoring Rubrics and Wave Allocation

## Readiness Assessment Framework

For each program, assess readiness across 5 dimensions:

### Dimension 1: Technical Complexity (0-10)
| Score | Description |
|-------|-------------|
| 9-10 | Simple utility — no branches, no I/O, pure calculation |
| 7-8 | Standard program — clean EVALUATE, PERFORM structure |
| 5-6 | Medium complexity — some REDEFINES, moderate branching |
| 3-4 | Complex — GOTO present, large size, many copybooks |
| 0-2 | Critical — ALTER present, circular deps, 2000+ lines |

### Dimension 2: Interface Clarity (0-10)
How clear is the program's API contract?

| Score | Description |
|-------|-------------|
| 9-10 | Clean LINKAGE SECTION with named parameters |
| 7-8 | Parameters via CALL USING, well-named fields |
| 5-6 | Some implicit state (working-storage side effects) |
| 3-4 | Heavy global state, many undocumented callers |
| 0-2 | No clear interface — modifies shared memory directly |

### Dimension 3: Test Coverage Proxy (0-10)
Legacy COBOL rarely has automated tests. Proxy indicators:

| Score | Indicator |
|-------|-----------|
| 8-10 | Has associated test JCL, documented test data |
| 6-7 | Business rules clearly documented in comments |
| 4-5 | Some inline comments, paragraph names are descriptive |
| 2-3 | Minimal comments, cryptic paragraph names |
| 0-1 | No comments, no test data, no documentation |

### Dimension 4: Data Dependency Risk (0-10)
| Score | Description |
|-------|-------------|
| 9-10 | Owns all its data — no shared copybooks |
| 7-8 | Uses 1-2 copybooks, not widely shared |
| 5-6 | Uses 3-4 copybooks, some shared |
| 3-4 | Uses 5+ copybooks, all widely shared |
| 0-2 | Modifies widely-shared data structures directly |

### Dimension 5: Business Risk (0-10)
How critical is this program to ongoing business operations?

| Score | Description |
|-------|-------------|
| 8-10 | Non-critical utility — limited business impact if down |
| 6-7 | Batch reporting — can tolerate delay |
| 4-5 | Daily batch processing — time-critical |
| 2-3 | High-volume transaction processing |
| 0-1 | Core banking / payment processing — zero downtime required |

## Wave Allocation Rules

### Wave 1 Criteria (Low Risk, High Confidence)
All of the following must be true:
- Complexity score ≥ 7
- Interface clarity ≥ 7
- Fan-in = 0 (no programs call this one)
- migration_category = 'EASY'
- No ALTER, no circular dependencies

Target: 20-30% of the portfolio. Proves out the Java pipeline.

### Wave 2 Criteria (Medium Risk, Building Capability)
All Wave 2 callees must be Wave 1 or already migrated:
- migration_category = 'EASY' or 'MODERATE'
- Fan-in 1-5
- No ALTER
- Wave 1 callees complete

Target: 30-40% of portfolio. Replaces shared services.

### Wave 3 Criteria (High Risk, Specialist Required)
- migration_category = 'HARD'
- Has GOTO but no ALTER
- All downstream dependencies migrated
- Dedicated senior architect assigned

Target: 20-30% of portfolio. Requires strangler fig pattern.

### Wave 4 Criteria (Critical Programs)
- migration_category = 'CRITICAL'
- Has ALTER or circular dependencies
- Dedicated rewrite team
- Decision gate: Rewrite vs. Keep-and-Wrap

Target: 5-10% of portfolio. Executive sign-off required.

## Rewrite vs. Migrate Decision Gate

For CRITICAL programs, evaluate these factors:

| Factor | Migrate | Rewrite |
|--------|---------|---------|
| Line count | < 3000 | > 3000 |
| Business rules clarity | Documented | Undocumented |
| ALTER presence | Absent | Present |
| Circular dependencies | 0 | > 0 |
| Team COBOL expertise | Available | Not available |
| Time constraint | Flexible | Tight deadline |
| Test data availability | Available | Unavailable |

If 4+ factors point to "Rewrite" → Recommend full rewrite with parallel run.
If 4+ factors point to "Migrate" → Proceed with migration.

## Effort Estimation Template

| Category | Lines of Code | Estimated Days |
|----------|---------------|----------------|
| EASY | 0-200 | 3-5 days |
| EASY | 200-500 | 5-10 days |
| MODERATE | 200-500 | 10-15 days |
| MODERATE | 500-1000 | 15-25 days |
| HARD | 500-1000 | 25-40 days |
| HARD | 1000-2000 | 40-60 days |
| CRITICAL | Any | Estimate individually |

Add 50% for programs with:
- ALTER verb (+50%)
- Circular dependencies (+25%)
- CICS integration (+30%)
- DB2 embedded SQL (+20%)
- No documentation (+30%)
