# Agent Usage Guide

How to invoke each agent from GitHub Copilot Chat (GHCP) in VS Code.

## Quick Reference

| Agent | Invoke As | When to Use |
|-------|-----------|-------------|
| cobol-ingestion | `@cobol-ingestion` | First step — scan workspace for COBOL files |
| cobol-parser | `@cobol-parser` | After ingestion — parse files into JSON AST |
| graph-builder | `@graph-builder` | After parsing — load graph into Neo4j |
| graph-query | `@graph-query` | After graph is built — ask questions about code |
| impact-analyzer | `@impact-analyzer` | Before changing anything — assess blast radius |
| complexity-scorer | `@complexity-scorer` | After graph build — score and prioritize programs |
| migration-advisor | `@migration-advisor` | For specific programs — get Java blueprints |
| documentation-generator | `@documentation-generator` | After graph build — generate missing docs |

---

## @cobol-ingestion

**Purpose:** Discovers all COBOL artefacts in the workspace and produces a manifest.

### Example invocations:

```
@cobol-ingestion scan ./sample-cobol and produce an ingestion manifest
```

```
@cobol-ingestion scan the entire workspace for all COBOL programs and copybooks
```

```
@cobol-ingestion scan ./src/main/cobol and report what you find
```

### What it produces:
- `.claude/state/ingestion-manifest.json` — structured inventory of all files
- Console summary table with file counts and complexity flags

### Handoff:
After completion, click **"Parse discovered COBOL files"** to proceed to parsing.

---

## @cobol-parser

**Purpose:** Parses raw COBOL source into structured JSON AST files.

### Prerequisites:
- `@cobol-ingestion` must have run first
- `.claude/state/ingestion-manifest.json` must exist

### Example invocations:

```
@cobol-parser parse all files in the ingestion manifest
```

```
@cobol-parser parse just the copybooks first, then the programs
```

```
@cobol-parser re-parse CUSTOMER-PROC.cbl after I've updated it
```

### What it produces:
- `.claude/state/parsed/<PROGRAM-ID>.json` — one file per program/copybook
- Updates manifest with PARSED/ERROR status per file

### Handoff:
After completion, click **"Build knowledge graph from parsed output"** to proceed.

---

## @graph-builder

**Purpose:** Loads parsed JSON ASTs into the Neo4j knowledge graph.

### Prerequisites:
- Neo4j must be running and MCP server connected
- `.claude/state/parsed/` must contain parsed JSON files
- Schema must be initialized (agent does this automatically on first run)

### Example invocations:

```
@graph-builder build the knowledge graph from all parsed files
```

```
@graph-builder rebuild the graph — fresh ingest of all programs
```

```
@graph-builder add PAYMENT-HANDLER to the graph — it was just parsed
```

### What it produces:
- Neo4j nodes: Program, Paragraph, Copybook, DataItem, CobolFile
- Neo4j relationships: CALLS, CONTAINS, PERFORMS, INCLUDES, DEFINES, READS, WRITES
- Console summary: node and relationship counts, unresolved references

### Handoffs:
- **"Query the knowledge graph"** — start asking questions
- **"Run complexity scoring"** — score programs for migration priority

---

## @graph-query

**Purpose:** Natural-language querying of the COBOL knowledge graph.

### Prerequisites:
- Graph must be populated by `@graph-builder`

### Example invocations:

```
@graph-query which programs call ACCOUNT-MGR?
```

```
@graph-query what is the full downstream call chain from BATCH-RUNNER?
```

```
@graph-query which programs include the CUSTOMER-RECORD copybook?
```

```
@graph-query show me all high-risk programs with GOTO statements
```

```
@graph-query what are the best candidates to migrate in Wave 1?
```

```
@graph-query which copybook is used by the most programs?
```

```
@graph-query are there any circular dependencies?
```

### Response format:
1. The Cypher query executed
2. Raw result table
3. Plain-English interpretation
4. Suggested next steps

---

## @impact-analyzer

**Purpose:** Before making any change, assess what will break.

### Prerequisites:
- Graph must be populated

### Example invocations:

```
@impact-analyzer what breaks if I change the CUSTOMER-RECORD copybook?
```

```
@impact-analyzer assess the blast radius of modifying ACCOUNT-MGR
```

```
@impact-analyzer what is the impact of deleting PAYMENT-HANDLER?
```

```
@impact-analyzer I want to rename CUST-ID to CUSTOMER-ID in CUSTOMER-RECORD — what's affected?
```

### What it produces:
- `.claude/state/impact-reports/<ARTEFACT>-impact-<timestamp>.json`
- Console impact tree showing affected programs by risk level
- Recommended change sequencing and estimated effort

### Handoff:
- **"Get migration advice for impacted programs"** — for HIGH/CRITICAL impacts

---

## @complexity-scorer

**Purpose:** Score all programs and produce a prioritized migration backlog.

### Prerequisites:
- Graph must be populated

### Example invocations:

```
@complexity-scorer score all programs and produce a migration backlog
```

```
@complexity-scorer what is the migration score for ACCOUNT-MGR?
```

```
@complexity-scorer produce the Wave 1 candidate list
```

### What it produces:
- Updates `migration_score` and `migration_category` on all Program nodes in Neo4j
- `.claude/state/migration-backlog.json`
- `docs/migration-backlog.md` — formatted table

### Handoff:
- **"Get migration recommendations for high complexity programs"** — for top 10

---

## @migration-advisor

**Purpose:** Generate a concrete Java migration blueprint for a specific program.

### Prerequisites:
- Graph must be populated with program details
- Program should ideally be complexity-scored first

### Example invocations:

```
@migration-advisor give me a Java blueprint for CUSTOMER-PROC
```

```
@migration-advisor how do I migrate ACCOUNT-MGR to Spring Boot?
```

```
@migration-advisor what Spring components does BATCH-RUNNER map to?
```

```
@migration-advisor PAYMENT-HANDLER has a GOTO — how do I handle that in Java?
```

### What it produces:
- `docs/migration-blueprints/<PROGRAM-ID>-blueprint.md`
- Data mapping table (COBOL PIC → Java types)
- Method mapping table (paragraphs → Java methods)
- Risk analysis with mitigation strategies
- Effort estimate

---

## @documentation-generator

**Purpose:** Generate missing documentation for legacy COBOL programs.

### Prerequisites:
- Graph must be populated

### Example invocations:

```
@documentation-generator generate documentation for all programs in the graph
```

```
@documentation-generator create a program overview for CUSTOMER-PROC
```

```
@documentation-generator build the data dictionary for all copybooks
```

```
@documentation-generator create a Mermaid call hierarchy diagram for BATCH-RUNNER
```

```
@documentation-generator generate the portfolio summary for executive review
```

### What it produces:
- `docs/programs/<PROGRAM-ID>.md` — per-program overview
- `docs/data-dictionary.md` — all copybook fields
- `docs/portfolio-summary.md` — executive summary

---

## Pipeline Flow

The recommended sequence for a full modernization assessment:

```
1. @cobol-ingestion scan ./your-cobol-directory
2. @cobol-parser parse all discovered files
3. @graph-builder build the knowledge graph
4. @complexity-scorer score all programs
5. @impact-analyzer assess any planned changes
6. @graph-query answer ad-hoc questions
7. @migration-advisor blueprint selected programs
8. @documentation-generator generate all documentation
```

Each agent has handoff buttons — click them to pass context to the next agent
automatically.
