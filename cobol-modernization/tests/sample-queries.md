# Sample Test Queries — One Per Agent

Use these queries to verify each agent is working correctly after setup.

---

## @cobol-ingestion — Test Queries

**Test 1: Basic scan**
```
@cobol-ingestion scan ./sample-cobol and produce an ingestion manifest
```
Expected: Discovers 4 programs (.cbl) and 3 copybooks (.cpy).
Manifest written to `.claude/state/ingestion-manifest.json`.

**Test 2: Verify manifest summary**
Expected summary from agent:
- Programs: 4 (CUSTOMER-PROC, ACCOUNT-MGR, PAYMENT-HANDLER, BATCH-RUNNER)
- Copybooks: 3 (CUSTOMER-RECORD, ACCOUNT-RECORD, PAYMENT-RECORD)
- No EBCDIC encoding issues
- BATCH-RUNNER flagged as entry point (no COPY statements)

---

## @cobol-parser — Test Queries

**Test 3: Parse all files**
```
@cobol-parser parse all files in the ingestion manifest
```
Expected: 7 JSON files created in `.claude/state/parsed/`:
- `CUSTOMER-RECORD.json`, `ACCOUNT-RECORD.json`, `PAYMENT-RECORD.json`
- `CUSTOMER-PROC.json`, `ACCOUNT-MGR.json`, `PAYMENT-HANDLER.json`, `BATCH-RUNNER.json`

**Test 4: Verify PAYMENT-HANDLER has GOTO flag**
Expected: `PAYMENT-HANDLER.json` contains:
```json
"risk_flags": { "has_goto": true, "has_alter": false }
```

---

## @graph-builder — Test Queries

**Test 5: Build the graph**
```
@graph-builder build the knowledge graph from all parsed files
```
Expected output:
- Programs: 4 nodes
- Copybooks: 3 nodes
- Paragraphs: at least 15 nodes
- CALLS relationships: 3 (BATCH-RUNNER→CUSTOMER-PROC, CUSTOMER-PROC→ACCOUNT-MGR, ACCOUNT-MGR→PAYMENT-HANDLER)
- INCLUDES relationships: at least 6

**Test 6: Verify schema was initialized**
Expected: `SHOW CONSTRAINTS` returns 6 uniqueness constraints.

---

## @graph-query — Test Queries

**Test 7: Simple caller query**
```
@graph-query which programs call ACCOUNT-MGR?
```
Expected: Returns CUSTOMER-PROC as the direct caller.

**Test 8: Copybook usage query**
```
@graph-query which programs use the CUSTOMER-RECORD copybook?
```
Expected: Returns CUSTOMER-PROC, ACCOUNT-MGR, BATCH-RUNNER.

**Test 9: Full call chain query**
```
@graph-query what is the full call chain starting from BATCH-RUNNER?
```
Expected:
- BATCH-RUNNER → CUSTOMER-PROC (hop 1)
- BATCH-RUNNER → CUSTOMER-PROC → ACCOUNT-MGR (hop 2)
- BATCH-RUNNER → CUSTOMER-PROC → ACCOUNT-MGR → PAYMENT-HANDLER (hop 3)

**Test 10: Risk query**
```
@graph-query show me all programs with GOTO statements
```
Expected: Returns PAYMENT-HANDLER (has_goto = true).

---

## @impact-analyzer — Test Queries

**Test 11: Copybook impact**
```
@impact-analyzer what is the impact of modifying the CUSTOMER-RECORD copybook?
```
Expected:
- Direct users: CUSTOMER-PROC, ACCOUNT-MGR, BATCH-RUNNER
- Transitive callers: BATCH-RUNNER is also an entry point
- Impact level: HIGH (used by 3 programs)
- Impact report written to `.claude/state/impact-reports/`

**Test 12: Program impact**
```
@impact-analyzer assess the blast radius of changing ACCOUNT-MGR
```
Expected:
- Upstream: CUSTOMER-PROC (calls ACCOUNT-MGR), BATCH-RUNNER (calls CUSTOMER-PROC)
- Downstream: PAYMENT-HANDLER (called by ACCOUNT-MGR)
- Shared copybooks: CUSTOMER-RECORD, ACCOUNT-RECORD

---

## @complexity-scorer — Test Queries

**Test 13: Score all programs**
```
@complexity-scorer score all programs in the knowledge graph
```
Expected: Migration scores written to Neo4j for all 4 programs.
PAYMENT-HANDLER gets higher score due to GOTO flag.
BATCH-RUNNER (no inbound calls) suggested for Wave 1.

**Test 14: Verify scores in Neo4j**
```cypher
MATCH (p:Program)
RETURN p.program_id, p.migration_score, p.migration_category
ORDER BY p.migration_score ASC
```
Expected: All 4 programs have `migration_score` and `migration_category` set.

---

## @migration-advisor — Test Queries

**Test 15: Blueprint for simple program**
```
@migration-advisor give me a Java migration blueprint for CUSTOMER-PROC
```
Expected:
- Program type identified as: Batch Job (has file I/O + PERFORM UNTIL loop)
- Recommended Spring component: Spring Batch ItemProcessor
- Data mapping: CUST-ID → long, CUST-NAME → String (trimmed), CUST-BALANCE → BigDecimal
- Effort estimate: ~3-5 days
- Blueprint written to `docs/migration-blueprints/CUSTOMER-PROC-blueprint.md`

**Test 16: Blueprint with risk flags**
```
@migration-advisor how should I handle the GOTO in PAYMENT-HANDLER when migrating to Java?
```
Expected: Explains the GOTO pattern, suggests early return refactoring,
provides Java equivalent code.

---

## @documentation-generator — Test Queries

**Test 17: Generate program doc**
```
@documentation-generator generate documentation for CUSTOMER-PROC
```
Expected: `docs/programs/CUSTOMER-PROC.md` created with:
- Author, date, complexity info
- Call hierarchy (called by BATCH-RUNNER, calls ACCOUNT-MGR)
- Copybook dependencies (CUSTOMER-RECORD)
- Paragraph list with line numbers

**Test 18: Generate Mermaid diagram**
```
@documentation-generator create a Mermaid call hierarchy diagram for BATCH-RUNNER
```
Expected:
```
graph TD
  BATCH-RUNNER --> CUSTOMER-PROC
  CUSTOMER-PROC --> ACCOUNT-MGR
  ACCOUNT-MGR --> PAYMENT-HANDLER
```

**Test 19: Generate data dictionary**
```
@documentation-generator build the complete data dictionary for all copybooks
```
Expected: `docs/data-dictionary.md` with tables for:
- CUSTOMER-RECORD (5 fields)
- ACCOUNT-RECORD (7 fields)
- PAYMENT-RECORD (7 fields)

**Test 20: Portfolio summary**
```
@documentation-generator generate a portfolio summary for executive review
```
Expected: `docs/portfolio-summary.md` with:
- Total: 4 programs, ~450 lines of code
- 3 LOW complexity, 1 MEDIUM complexity
- 1 program with GOTO (PAYMENT-HANDLER)
- Recommended Wave 1: CUSTOMER-PROC or BATCH-RUNNER
- Estimated total migration effort: 2-4 weeks

---

## Full Pipeline Test

Run this sequence to verify the complete pipeline works end-to-end:

```
1. @cobol-ingestion scan ./sample-cobol
2. @cobol-parser parse all files
3. @graph-builder build the graph
4. @complexity-scorer score all programs
5. @graph-query which programs are Wave 1 candidates?
6. @impact-analyzer what breaks if I change CUSTOMER-RECORD?
7. @migration-advisor blueprint for CUSTOMER-PROC
8. @documentation-generator generate all documentation
```

Expected final state:
- Neo4j has 4 programs, 3 copybooks, ~15 paragraphs, ~25+ relationships
- All programs have migration scores
- Impact report exists for CUSTOMER-RECORD
- Migration blueprint exists for CUSTOMER-PROC
- Program docs exist in `docs/programs/`
- Data dictionary exists at `docs/data-dictionary.md`
