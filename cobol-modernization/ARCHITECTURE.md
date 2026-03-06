# Architecture Decisions

Design decisions and rationale for the COBOL Modernization Knowledge Graph platform.

---

## Decision 1: GitHub Copilot Chat as the Developer Interface

**Decision:** Use GHCP `@agent-name` syntax as the sole UI, not a custom web app.

**Rationale:**
- Developers already use VS Code for COBOL source navigation
- Zero additional tooling to install or maintain
- Native access to workspace files via agent tools (Glob, Read, Grep)
- Handoff buttons provide guided workflow without custom UI code
- Natural language input reduces barrier to adoption

**Trade-offs:**
- Dependent on GitHub Copilot subscription
- Less control over output formatting than a custom UI
- No persistent session state across restarts (mitigated by `.claude/state/` files)

---

## Decision 2: Skills Over Prompts for Domain Knowledge

**Decision:** Store COBOL/Neo4j domain knowledge in `.claude/skills/` Markdown files,
loaded on-demand by agents, rather than embedding knowledge in system prompts.

**Rationale:**
- **Updatable without redeployment:** Add a new anti-pattern to `ANTI-PATTERNS.md`;
  all agents that load the skill immediately benefit.
- **Composable:** `graph-builder` loads both neo4j-schema and cypher-patterns.
  `migration-advisor` loads java-mapping and cobol-patterns. Each agent loads only
  what it needs.
- **Auditable:** Domain knowledge is plain Markdown — easy for COBOL SMEs to review
  and correct without touching agent logic.
- **Token efficient:** Agents load skills only when needed, not on every message.

**Trade-offs:**
- Agents must explicitly `READ` skill files — a forgotten read means missing knowledge.
- File I/O overhead on each skill load (mitigated by agent tool caching).

---

## Decision 3: Neo4j for the Knowledge Graph

**Decision:** Neo4j graph database instead of relational DB or JSON files.

**Rationale:**
- COBOL's call graph is a native graph problem: CALLS, PERFORMS, INCLUDES are
  inherently graph relationships with variable depth traversals.
- Cypher is expressive for dependency queries: `MATCH (a)-[:CALLS*1..10]->(b)` in
  one line vs. 10+ lines of recursive SQL.
- Graph visualization tools (Neo4j Bloom) provide free visual call graph exploration.
- The Neo4j MCP server provides a ready-made tool integration — no custom API needed.

**Trade-offs:**
- Neo4j requires a running database process (vs. flat files).
- Learning curve for Cypher (mitigated by cypher-patterns skill).
- For very small codebases (<50 programs), a JSON file might be simpler.

---

## Decision 4: Agent Pipeline with Handoffs

**Decision:** Separate agents for each pipeline stage (ingestion → parsing → graph-build →
query/analysis) with explicit handoff buttons between them.

**Rationale:**
- **Single Responsibility:** Each agent is focused and testable independently.
  `@cobol-parser` doesn't need Neo4j knowledge; `@graph-query` doesn't need to
  understand COBOL file formats.
- **Resumability:** If parsing fails halfway, the developer can fix the issue and
  re-run `@cobol-parser` without re-running ingestion.
- **Parallelism:** Multiple developers can run different agents simultaneously
  (e.g., one runs `@complexity-scorer` while another runs `@migration-advisor`).
- **Debuggability:** Each stage writes state files (`.claude/state/`) so the
  developer can inspect what went wrong.

**Trade-offs:**
- More agent files to maintain (8 vs. one monolithic agent).
- Handoffs require developer action (clicking buttons) — not fully automated.
  This is intentional: automation without human review is risky for mainframe code.

---

## Decision 5: MERGE-Based Idempotent Graph Loading

**Decision:** All graph-builder Cypher uses MERGE, not CREATE.

**Rationale:**
- Running ingestion twice should produce the same graph (no duplicate nodes).
- Incremental updates: parsing one new program and running graph-builder again
  only creates new nodes/relationships without breaking existing ones.
- Resilience: if graph-builder crashes mid-run, re-running it is safe.

**Trade-offs:**
- MERGE is slightly slower than CREATE for first-time loads.
- ON CREATE / ON MATCH SET clauses add verbosity.

---

## Decision 6: Parsed JSON as Intermediate State

**Decision:** `@cobol-parser` outputs JSON files to `.claude/state/parsed/` before
`@graph-builder` loads them into Neo4j, rather than parsing directly into Neo4j.

**Rationale:**
- Separation of concerns: parsing logic and graph loading logic are independent.
- JSON files can be inspected, diffed, and version-controlled for auditing.
- Allows rebuilding the graph from JSON without re-parsing COBOL (useful when
  the Neo4j schema changes but COBOL source hasn't).
- Enables alternative graph backends in the future (swap graph-builder without
  touching cobol-parser).

**Trade-offs:**
- Disk space for intermediate files.
- Two-step process instead of one.

---

## Decision 7: .claude/state/ Excluded from Git

**Decision:** `.claude/state/` is in `.gitignore` — generated state is not committed.

**Rationale:**
- State files are derived artifacts, not source. They should be re-generatable
  from source COBOL files.
- State files may contain large JSON (thousands of programs) that would bloat
  the repository.
- Committing state would cause merge conflicts when multiple developers run
  the pipeline.

**Trade-offs:**
- Each developer must run the full pipeline on checkout.
- No historical record of analysis results (mitigated by impact report exports).

---

## Component Interaction Diagram

```
Developer (GHCP)
      │
      ▼
@cobol-ingestion ──writes──▶ .claude/state/ingestion-manifest.json
      │
      ▼ (handoff)
@cobol-parser    ──reads──▶  manifest
                 ──writes──▶ .claude/state/parsed/*.json
      │
      ▼ (handoff)
@graph-builder   ──reads──▶  parsed JSON
                 ──writes──▶ Neo4j (via MCP)
      │
      ├──▶ @graph-query       ──reads──▶ Neo4j (read-only)
      │
      ├──▶ @complexity-scorer ──reads──▶ Neo4j
      │                       ──writes──▶ Neo4j (scores)
      │                       ──writes──▶ .claude/state/migration-backlog.json
      │
      ├──▶ @impact-analyzer   ──reads──▶ Neo4j
      │                       ──writes──▶ .claude/state/impact-reports/
      │
      ├──▶ @migration-advisor ──reads──▶ Neo4j + skill files
      │                       ──writes──▶ docs/migration-blueprints/
      │
      └──▶ @documentation-generator ──reads──▶ Neo4j
                                    ──writes──▶ docs/programs/, docs/*.md
```

---

## Skill Dependency Map

```
Agent               Skills Loaded
─────────────────────────────────────────────────────
cobol-ingestion  → cobol-syntax
cobol-parser     → cobol-syntax, cobol-patterns
graph-builder    → neo4j-schema, cypher-patterns
graph-query      → neo4j-schema, cypher-patterns, cobol-insights
impact-analyzer  → neo4j-schema, impact-analysis
complexity-scorer→ neo4j-schema, cobol-insights
migration-advisor→ java-mapping, cobol-patterns, neo4j-schema
doc-generator    → neo4j-schema, cobol-insights
```
