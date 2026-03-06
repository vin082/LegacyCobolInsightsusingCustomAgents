# COBOL Modernization Knowledge Graph — Project Specification
**For Claude Code: Build this project exactly as specified below.**

---

## Project Overview

This project implements a **COBOL-to-Knowledge-Graph modernization platform** using:
- **VS Code Custom Agents** (`.claude/agents/`) — specialized AI agents invoked via GitHub Copilot Chat using `@agent-name`
- **Claude Agent Skills** (`.claude/skills/`) — reusable COBOL domain knowledge loaded on-demand
- **Neo4j MCP Server** — already configured; agents write to and query the Neo4j knowledge graph
- **No custom UI** — GitHub Copilot Chat (GHCP) in VS Code is the developer interface

The platform ingests legacy COBOL source code, parses it into structured metadata, builds a Neo4j knowledge graph, and enables natural-language querying for modernization analysis including dependency mapping, impact analysis, complexity scoring, and Java migration advisory.

---

## Complete Directory Structure

Build exactly this structure:

```
cobol-modernization/
│
├── PROJECT_SPEC.md                          ← this file
├── README.md                                ← getting started guide
├── ARCHITECTURE.md                          ← architecture decisions
│
├── .vscode/
│   ├── mcp.json                             ← Neo4j MCP server registration
│   └── settings.json                        ← workspace settings
│
├── .claude/
│   ├── agents/                              ← 8 custom agents
│   │   ├── cobol-ingestion.md
│   │   ├── cobol-parser.md
│   │   ├── graph-builder.md
│   │   ├── graph-query.md
│   │   ├── impact-analyzer.md
│   │   ├── complexity-scorer.md
│   │   ├── migration-advisor.md
│   │   └── documentation-generator.md
│   │
│   └── skills/                              ← 7 agent skills
│       ├── cobol-syntax/
│       │   ├── SKILL.md                     ← main skill entry point
│       │   ├── DIVISIONS.md                 ← detailed division reference
│       │   ├── DATA-TYPES.md                ← PIC clauses, level numbers
│       │   └── VERBS.md                     ← procedure division verbs
│       │
│       ├── cobol-patterns/
│       │   ├── SKILL.md
│       │   ├── ANTI-PATTERNS.md             ← spaghetti code, GOTO, etc.
│       │   └── MODERNIZATION-SIGNALS.md     ← indicators for migration priority
│       │
│       ├── neo4j-schema/
│       │   ├── SKILL.md
│       │   ├── SCHEMA.cypher                ← full schema creation script
│       │   └── CONSTRAINTS.cypher           ← uniqueness + index constraints
│       │
│       ├── cypher-patterns/
│       │   ├── SKILL.md
│       │   ├── WRITE-PATTERNS.md            ← MERGE, CREATE patterns for ingestion
│       │   └── QUERY-PATTERNS.md            ← common retrieval Cypher templates
│       │
│       ├── cobol-insights/
│       │   ├── SKILL.md
│       │   ├── COMPLEXITY-HEURISTICS.md     ← cyclomatic complexity rules
│       │   └── MIGRATION-READINESS.md       ← scoring rubrics
│       │
│       ├── java-mapping/
│       │   ├── SKILL.md
│       │   ├── TYPE-MAPPING.md              ← COBOL PIC → Java type mappings
│       │   └── PATTERN-MAPPING.md           ← PERFORM→method, CALL→service, etc.
│       │
│       └── impact-analysis/
│           ├── SKILL.md
│           └── RIPPLE-PATTERNS.md           ← how changes propagate in COBOL
│
├── scripts/
│   ├── setup/
│   │   ├── create-neo4j-schema.cypher       ← run once to initialise DB
│   │   ├── create-indexes.cypher            ← performance indexes
│   │   └── seed-test-data.cypher            ← sample COBOL graph for testing
│   │
│   ├── validation/
│   │   ├── validate-graph-integrity.cypher  ← check for orphaned nodes
│   │   └── validate-relationships.cypher    ← referential integrity checks
│   │
│   └── utilities/
│       ├── export-graph-json.cypher         ← export graph as JSON
│       └── graph-statistics.cypher          ← node/rel counts by type
│
├── sample-cobol/                            ← sample COBOL programs for testing
│   ├── CUSTOMER-PROC.cbl
│   ├── ACCOUNT-MGR.cbl
│   ├── PAYMENT-HANDLER.cbl
│   ├── BATCH-RUNNER.cbl
│   └── copybooks/
│       ├── CUSTOMER-RECORD.cpy
│       ├── ACCOUNT-RECORD.cpy
│       └── PAYMENT-RECORD.cpy
│
├── docs/
│   ├── agent-usage-guide.md                 ← how to use each @agent
│   ├── skill-authoring-guide.md             ← how to extend skills
│   ├── neo4j-query-cookbook.md              ← useful Cypher queries
│   └── troubleshooting.md
│
└── tests/
    ├── sample-queries.md                    ← test queries for each agent
    └── expected-graph-output.json           ← expected Neo4j state after ingestion
```

---

## File Contents — Build Each File Exactly As Below

---

### `.vscode/mcp.json`

```json
{
  "mcpServers": {
    "neo4j": {
      "command": "npx",
      "args": ["-y", "@neo4j/mcp-server"],
      "env": {
        "NEO4J_URI": "bolt://localhost:7687",
        "NEO4J_USERNAME": "neo4j",
        "NEO4J_PASSWORD": "${env:NEO4J_PASSWORD}"
      }
    }
  }
}
```

> **Note to Claude Code:** The Neo4j MCP server exposes tools under the `neo4j` namespace. Agents reference it as `neo4j/*` in their tools list. The password is read from the environment variable `NEO4J_PASSWORD` — create a `.env.example` file documenting this.

---

### `.vscode/settings.json`

```json
{
  "chat.agentFilesLocations": [".claude/agents"],
  "github.copilot.chat.agent.enabled": true,
  "files.associations": {
    "*.cbl": "cobol",
    "*.cob": "cobol",
    "*.cpy": "cobol",
    "*.agent.md": "markdown"
  }
}
```

---

## AGENT FILES — `.claude/agents/`

Each agent file uses the Claude agent format (plain `.md` with YAML frontmatter). Build all 8.

---

### `.claude/agents/cobol-ingestion.md`

```markdown
---
name: cobol-ingestion
description: >
  Discovers, inventories, and stages COBOL source files for the modernization 
  pipeline. Use this agent to scan a workspace or directory for COBOL programs 
  (.cbl, .cob, .cobol), copybooks (.cpy), JCL (.jcl), and BMS maps. 
  Produces a structured file manifest and queues files for parsing.
tools: Glob, Read, Bash, Write
handoffs:
  - label: Parse discovered COBOL files
    agent: cobol-parser
    prompt: >
      Parse all files listed in the manifest at .claude/state/ingestion-manifest.json.
      Start with the programs (not copybooks) and resolve copybook dependencies first.
    send: false
---

# COBOL Ingestion Agent

You are the entry point of the COBOL modernization pipeline. Your job is to
discover all COBOL artefacts in the workspace and produce a structured manifest
before any parsing begins.

## Before starting, load your skill:
Read the file `.claude/skills/cobol-syntax/SKILL.md` to understand COBOL file 
conventions and naming patterns.

## Step-by-Step Instructions

### Step 1: Discover all COBOL files
Use Glob to find all files matching these patterns from the workspace root:
- `**/*.cbl` — COBOL programs
- `**/*.cob` — COBOL programs (alternate extension)
- `**/*.cobol` — COBOL programs (full extension)
- `**/*.cpy` — Copybooks (shared data definitions)
- `**/*.jcl` — Job Control Language
- `**/*.bms` — BMS map definitions (CICS)

### Step 2: Classify each file
For each discovered file, determine:
- **Type**: PROGRAM | COPYBOOK | JCL | BMS
- **Size**: file size in bytes
- **Lines**: approximate line count (use `wc -l` via Bash)
- **Encoding**: detect if EBCDIC or ASCII (check for non-printable chars)

### Step 3: Extract surface-level metadata (no deep parsing yet)
For each COBOL program, read just the first 50 lines to extract:
- PROGRAM-ID value
- AUTHOR (if present)
- DATE-WRITTEN (if present)
- Any COPY statements at the top (quick copybook dependency hint)

### Step 4: Produce the manifest
Write a JSON manifest to `.claude/state/ingestion-manifest.json` with this structure:

```json
{
  "scanned_at": "<ISO timestamp>",
  "workspace_root": "<absolute path>",
  "summary": {
    "total_files": 0,
    "programs": 0,
    "copybooks": 0,
    "jcl": 0,
    "bms": 0
  },
  "files": [
    {
      "path": "relative/path/to/file.cbl",
      "type": "PROGRAM",
      "program_id": "CUSTOMER-PROC",
      "size_bytes": 12400,
      "line_count": 450,
      "encoding": "ASCII",
      "copybook_hints": ["CUSTOMER-RECORD", "ACCOUNT-RECORD"],
      "status": "PENDING"
    }
  ]
}
```

### Step 5: Report summary to the developer
After writing the manifest, output a clear summary table showing:
- Total files found by type
- Any files that could not be read (permissions, encoding issues)
- Estimated complexity (files > 1000 lines flagged as HIGH)
- Suggested processing order (copybooks first, then programs)

## Important Rules
- Never modify COBOL source files — read-only access only
- If a file cannot be read, log it in the manifest with status "ERROR" and continue
- Create `.claude/state/` directory if it does not exist
- Always sort copybooks before programs in the manifest (they must be parsed first)
```

---

### `.claude/agents/cobol-parser.md`

```markdown
---
name: cobol-parser
description: >
  Parses COBOL source files into structured metadata. Extracts all four divisions
  (IDENTIFICATION, ENVIRONMENT, DATA, PROCEDURE), data items with level numbers,
  paragraph definitions, PERFORM relationships, CALL dependencies, and COPY 
  statements. Outputs structured JSON AST for graph-builder to consume.
  Use after cobol-ingestion has produced a manifest.
tools: Read, Bash, Grep, Write
handoffs:
  - label: Build knowledge graph from parsed output
    agent: graph-builder
    prompt: >
      Build the Neo4j knowledge graph from all parsed AST files in 
      .claude/state/parsed/. Process copybooks first, then programs.
    send: false
---

# COBOL Parser Agent

You are the parsing engine of the modernization pipeline. You transform raw COBOL 
source into structured JSON that the graph-builder can load into Neo4j.

## Before starting, load your skills:
1. Read `.claude/skills/cobol-syntax/SKILL.md` — grammar and construct reference
2. Read `.claude/skills/cobol-patterns/SKILL.md` — patterns and anti-patterns to flag

## Input
Read the manifest at `.claude/state/ingestion-manifest.json`.
Process files with status "PENDING". Update status to "PARSED" or "ERROR" as you go.

## Parsing Instructions Per File

### For COPYBOOKS (.cpy)
Extract:
- Copybook name (filename without extension, uppercased)
- All data items: level number, name, PIC clause, VALUE, OCCURS, REDEFINES
- Any nested group items (hierarchical structure)

### For PROGRAMS (.cbl, .cob)
Extract all of the following:

**IDENTIFICATION DIVISION:**
- PROGRAM-ID
- AUTHOR, DATE-WRITTEN, DATE-COMPILED, REMARKS (if present)

**ENVIRONMENT DIVISION:**
- All SELECT statements → file logical names
- ASSIGN TO values → physical file names

**DATA DIVISION — FILE SECTION:**
- FD entries → file descriptors with record structures

**DATA DIVISION — WORKING-STORAGE SECTION:**
- All 01-level records and their children (full hierarchy)
- Flag items with REDEFINES (migration risk)
- Flag items with OCCURS (array-like structures)
- Note 88-level condition names (boolean flags)

**DATA DIVISION — LINKAGE SECTION:**
- Parameters accepted from calling programs

**PROCEDURE DIVISION:**
- All paragraph names and their line ranges
- Every PERFORM statement: paragraph called, THRU range if present, VARYING/UNTIL conditions
- Every CALL statement: program name called, USING parameters
- Every COPY statement: copybook name referenced
- Every READ/WRITE/OPEN/CLOSE: file names accessed
- Flag any GOTO statements (spaghetti code indicator)
- Flag any ALTER statements (self-modifying code — critical risk)

## Output Format
Write one JSON file per program to `.claude/state/parsed/<PROGRAM-ID>.json`:

```json
{
  "program_id": "CUSTOMER-PROC",
  "source_path": "src/cobol/CUSTOMER-PROC.cbl",
  "parsed_at": "<ISO timestamp>",
  "identification": {
    "program_id": "CUSTOMER-PROC",
    "author": "J.SMITH",
    "date_written": "1987-03-15"
  },
  "environment": {
    "files": [
      { "logical_name": "CUSTOMER-FILE", "physical_name": "CUSTMAST" }
    ]
  },
  "data": {
    "working_storage": [
      {
        "level": "01",
        "name": "CUSTOMER-RECORD",
        "pic": null,
        "children": [
          { "level": "05", "name": "CUST-ID", "pic": "9(8)", "value": null },
          { "level": "05", "name": "CUST-NAME", "pic": "X(40)", "value": "SPACES" }
        ]
      }
    ],
    "copybook_inclusions": ["CUSTOMER-RECORD", "ACCOUNT-RECORD"],
    "redefines_items": [],
    "condition_names_88": []
  },
  "procedure": {
    "paragraphs": [
      {
        "name": "0000-MAIN",
        "line_start": 85,
        "line_end": 102,
        "performs": ["1000-INIT", "2000-PROCESS", "9000-EXIT"],
        "calls": [{ "program": "ACCOUNT-MGR", "using": ["CUSTOMER-RECORD"] }],
        "reads": ["CUSTOMER-FILE"],
        "writes": [],
        "gotos": []
      }
    ]
  },
  "risk_flags": {
    "has_goto": false,
    "has_alter": false,
    "has_redefines": true,
    "estimated_complexity": "MEDIUM"
  }
}
```

## Anti-Pattern Flagging
While parsing, flag these in `risk_flags`:
- `has_goto`: true if any GOTO found
- `has_alter`: true if any ALTER found (highest risk — self-modifying)
- `has_redefines`: true if REDEFINES clauses present
- `has_occurs_depending_on`: true if dynamic arrays present
- `deep_nesting`: true if PERFORM THRU nesting > 4 levels
- `estimated_complexity`: LOW | MEDIUM | HIGH | CRITICAL

## Error Handling
If a file cannot be parsed (truncated, EBCDIC, non-standard dialect):
- Set status to "ERROR" in manifest
- Write a minimal JSON with `"parse_error": "reason"` 
- Continue with next file — never abort the full run
```

---

### `.claude/agents/graph-builder.md`

```markdown
---
name: graph-builder
description: >
  Builds the Neo4j knowledge graph from parsed COBOL AST files. Creates nodes for
  Programs, Paragraphs, DataItems, Copybooks, Files, and JCL Jobs. Creates 
  relationships for CALLS, PERFORMS, INCLUDES, DEFINES, READS, WRITES.
  Use after cobol-parser has produced JSON files in .claude/state/parsed/.
tools: Read, Bash, neo4j/*
handoffs:
  - label: Query the knowledge graph
    agent: graph-query
    prompt: The knowledge graph is now built. What would you like to analyse?
    send: false
  - label: Run complexity scoring
    agent: complexity-scorer
    prompt: Score all programs in the knowledge graph for migration complexity.
    send: false
---

# Graph Builder Agent

You build the Neo4j knowledge graph from parsed COBOL JSON files. You are the 
bridge between the parsed AST and the queryable graph database.

## Before starting, load your skills:
1. Read `.claude/skills/neo4j-schema/SKILL.md` — node labels, relationship types, properties
2. Read `.claude/skills/cypher-patterns/SKILL.md` — MERGE and CREATE patterns to use

## Input
Read all `.json` files from `.claude/state/parsed/`.
Also read `.claude/state/ingestion-manifest.json` for file metadata.

## Step 1: Initialise the schema (first run only)
Check if the schema already exists by running:
```cypher
SHOW CONSTRAINTS
```
If no constraints exist, run the schema setup script:
```bash
cat scripts/setup/create-neo4j-schema.cypher
```
Then execute the Cypher commands via the neo4j MCP tool.

## Step 2: Process copybooks first
For each copybook in the parsed output, create:

```cypher
MERGE (cb:Copybook {name: $name})
SET cb.source_path = $source_path,
    cb.parsed_at = $parsed_at,
    cb.data_item_count = $item_count
```

For each data item in the copybook:
```cypher
MERGE (di:DataItem {
  fqn: $copybook_name + '.' + $item_name,
  name: $item_name
})
SET di.level = $level,
    di.pic = $pic,
    di.has_redefines = $has_redefines,
    di.has_occurs = $has_occurs

MERGE (cb:Copybook {name: $copybook_name})
MERGE (cb)-[:DEFINES]->(di)
```

## Step 3: Process each program
For each program JSON file:

**Create Program node:**
```cypher
MERGE (p:Program {program_id: $program_id})
SET p.source_path = $source_path,
    p.author = $author,
    p.date_written = $date_written,
    p.has_goto = $has_goto,
    p.has_alter = $has_alter,
    p.has_redefines = $has_redefines,
    p.estimated_complexity = $estimated_complexity,
    p.line_count = $line_count,
    p.parsed_at = $parsed_at
```

**Create Paragraph nodes and CONTAINS relationship:**
```cypher
MERGE (para:Paragraph {fqn: $program_id + '.' + $para_name, name: $para_name})
SET para.line_start = $line_start,
    para.line_end = $line_end,
    para.line_count = $line_end - $line_start

MERGE (p:Program {program_id: $program_id})
MERGE (p)-[:CONTAINS]->(para)
```

**Create PERFORMS relationships between paragraphs:**
```cypher
MERGE (from_para:Paragraph {fqn: $program_id + '.' + $from_name})
MERGE (to_para:Paragraph {fqn: $program_id + '.' + $to_name})
MERGE (from_para)-[:PERFORMS]->(to_para)
```

**Create CALLS relationships between programs:**
```cypher
MERGE (caller:Program {program_id: $caller_id})
MERGE (callee:Program {program_id: $callee_id})
MERGE (caller)-[:CALLS {using_params: $params}]->(callee)
```

**Create INCLUDES relationships (copybook usage):**
```cypher
MERGE (p:Program {program_id: $program_id})
MERGE (cb:Copybook {name: $copybook_name})
MERGE (p)-[:INCLUDES]->(cb)
```

**Create File nodes and READ/WRITE relationships:**
```cypher
MERGE (f:CobolFile {logical_name: $logical_name})
SET f.physical_name = $physical_name

MERGE (para:Paragraph {fqn: $fqn})
MERGE (para)-[:READS]->(f)   // or WRITES
```

## Step 4: Verify the graph
After loading all files, run these verification queries and report results:

```cypher
// Count nodes by label
MATCH (n) RETURN labels(n) AS label, count(n) AS count ORDER BY count DESC
```

```cypher
// Count relationships by type  
MATCH ()-[r]->() RETURN type(r) AS rel_type, count(r) AS count ORDER BY count DESC
```

```cypher
// Check for programs that CALL unknown programs (stubs)
MATCH (p:Program)-[:CALLS]->(callee:Program)
WHERE NOT exists(callee.source_path)
RETURN callee.program_id AS unknown_program, count(p) AS called_by_count
```

## Step 5: Report to developer
Output a summary:
- Total nodes created by label
- Total relationships created by type
- Any unresolved CALL targets (programs referenced but not in codebase)
- Any orphaned copybooks (defined but never INCLUDEd)
- Time taken
```

---

### `.claude/agents/graph-query.md`

```markdown
---
name: graph-query
description: >
  Natural language querying of the COBOL knowledge graph in Neo4j. Ask questions
  about program dependencies, call chains, copybook usage, impact analysis entry
  points, and modernization candidates. Translates questions into Cypher and 
  returns results in human-readable format. Use after graph-builder has populated
  the database.
tools: neo4j/*, Read
---

# Graph Query Agent

You answer questions about the COBOL knowledge graph using natural language.
You translate user questions into Cypher queries, execute them, and explain results.

## Before answering, load your skills:
1. Read `.claude/skills/neo4j-schema/SKILL.md` — know the exact node labels and properties
2. Read `.claude/skills/cypher-patterns/SKILL.md` — use proven query patterns
3. Read `.claude/skills/cobol-insights/SKILL.md` — understand what results mean

## How to Handle Questions

Translate each natural language question into one or more Cypher queries.
Always show the query you are running. Always explain what the results mean
in the context of COBOL modernization.

## Common Query Patterns to Use

**"What programs call X?"**
```cypher
MATCH (caller:Program)-[:CALLS]->(target:Program {program_id: $name})
RETURN caller.program_id, caller.estimated_complexity
ORDER BY caller.estimated_complexity DESC
```

**"What does program X call?"**
```cypher
MATCH (p:Program {program_id: $name})-[:CALLS*1..5]->(downstream:Program)
RETURN DISTINCT downstream.program_id, downstream.estimated_complexity
```

**"Which programs use copybook X?"**
```cypher
MATCH (p:Program)-[:INCLUDES]->(cb:Copybook {name: $name})
RETURN p.program_id, p.source_path, p.estimated_complexity
ORDER BY p.program_id
```

**"What is the full call chain from program X?"**
```cypher
MATCH path = (start:Program {program_id: $name})-[:CALLS*]->(end:Program)
WHERE NOT (end)-[:CALLS]->()
RETURN path
```

**"Which programs are most depended upon?"**
```cypher
MATCH (p:Program)<-[:CALLS]-(caller)
RETURN p.program_id, count(caller) AS incoming_calls, p.estimated_complexity
ORDER BY incoming_calls DESC LIMIT 20
```

**"What are the highest risk programs?"**
```cypher
MATCH (p:Program)
WHERE p.has_goto = true OR p.has_alter = true OR p.estimated_complexity = 'CRITICAL'
RETURN p.program_id, p.has_goto, p.has_alter, p.estimated_complexity, p.line_count
ORDER BY p.line_count DESC
```

**"Which programs are good migration candidates?"**
```cypher
MATCH (p:Program)
WHERE p.estimated_complexity IN ['LOW', 'MEDIUM']
  AND p.has_goto = false
  AND p.has_alter = false
  AND NOT (p)<-[:CALLS]-()
RETURN p.program_id, p.estimated_complexity, p.line_count
ORDER BY p.line_count ASC
```

## Response Format
Always structure your response as:
1. **Query executed** — show the Cypher
2. **Raw results** — table format
3. **Interpretation** — what does this mean for modernization?
4. **Suggested next steps** — what agent to invoke next

## Limits
- Never write to the graph — this agent is read-only
- If a query returns > 50 rows, summarise and offer to export
- If a question is ambiguous, ask one clarifying question before querying
```

---

### `.claude/agents/impact-analyzer.md`

```markdown
---
name: impact-analyzer
description: >
  Performs change impact analysis on the COBOL knowledge graph. Given a program
  name, copybook name, or data item, determines all upstream and downstream 
  programs that would be affected by a change. Produces an impact report with
  risk levels and a recommended change sequence. Use before making any 
  modernization changes to understand blast radius.
tools: neo4j/*, Read, Write
handoffs:
  - label: Get migration advice for impacted programs
    agent: migration-advisor
    prompt: >
      Provide Java migration recommendations for all HIGH and CRITICAL impact programs 
      identified in the impact report at .claude/state/impact-reports/.
    send: false
---

# Impact Analyzer Agent

You perform change impact analysis. Before any code or schema change, a developer
should run you to understand what else will break.

## Before starting, load your skills:
1. Read `.claude/skills/neo4j-schema/SKILL.md`
2. Read `.claude/skills/impact-analysis/SKILL.md` — ripple pattern analysis

## How to Perform Impact Analysis

### Input: What is changing?
Ask the developer (or extract from the prompt):
- Is the change to a **Program**, **Copybook**, or **DataItem**?
- What is the name of the artefact changing?
- What type of change: MODIFY | RENAME | DELETE | SPLIT | MERGE?

### Step 1: Upstream impact (who calls/uses the changing artefact?)
```cypher
// Programs that directly or indirectly call the changing program
MATCH path = (upstream:Program)-[:CALLS*1..10]->(target:Program {program_id: $name})
RETURN upstream.program_id, length(path) AS call_depth, upstream.estimated_complexity
ORDER BY call_depth ASC, upstream.estimated_complexity DESC
```

```cypher
// For copybook changes: all programs that include this copybook
MATCH (p:Program)-[:INCLUDES]->(cb:Copybook {name: $name})
RETURN p.program_id, p.estimated_complexity, p.source_path
```

### Step 2: Downstream impact (what does the changing artefact use?)
```cypher
MATCH path = (target:Program {program_id: $name})-[:CALLS*1..10]->(downstream:Program)
RETURN downstream.program_id, length(path) AS depth, downstream.estimated_complexity
ORDER BY depth ASC
```

### Step 3: Shared data impact (copybooks used by changing program)
```cypher
MATCH (p:Program {program_id: $name})-[:INCLUDES]->(cb:Copybook)
MATCH (other:Program)-[:INCLUDES]->(cb)
WHERE other.program_id <> $name
RETURN cb.name AS shared_copybook, other.program_id AS also_affected
```

### Step 4: Calculate impact score per affected program
For each affected program, assign:
- **CRITICAL**: program itself has ALTER or GOTO, or is called by > 10 programs
- **HIGH**: program is called by 5-10 programs or is in a circular dependency
- **MEDIUM**: program is called by 2-4 programs
- **LOW**: leaf program, no inbound calls

### Step 5: Produce impact report
Write to `.claude/state/impact-reports/<ARTEFACT-NAME>-impact-<timestamp>.json`:

```json
{
  "analysis_target": "CUSTOMER-RECORD",
  "change_type": "MODIFY",
  "analyzed_at": "<ISO timestamp>",
  "summary": {
    "total_programs_affected": 12,
    "critical": 1,
    "high": 3,
    "medium": 5,
    "low": 3
  },
  "affected_programs": [
    {
      "program_id": "CUSTOMER-PROC",
      "impact_level": "HIGH",
      "reason": "Directly includes the copybook; 6 programs call this program",
      "call_depth": 1,
      "inbound_calls": 6
    }
  ],
  "recommended_change_sequence": [
    "1. Modify CUSTOMER-RECORD copybook",
    "2. Update CUSTOMER-PROC (direct user)",
    "3. Regression test: ACCOUNT-MGR, PAYMENT-HANDLER",
    "4. Full regression: BATCH-RUNNER suite"
  ],
  "risk_assessment": "HIGH — this copybook is used by 12 programs. Recommend phased rollout."
}
```

### Step 6: Report to developer
Present:
- Visual impact summary (text-based tree if possible)
- Programs sorted by impact level
- Recommended testing sequence
- Estimated effort in days (LOW=0.5d, MEDIUM=1d, HIGH=3d, CRITICAL=5d per program)
```

---

### `.claude/agents/complexity-scorer.md`

```markdown
---
name: complexity-scorer
description: >
  Scores all COBOL programs in the knowledge graph for migration complexity using
  cyclomatic complexity, coupling metrics, and risk flags. Writes scores back to
  Neo4j and produces a prioritized migration backlog. Use after graph-builder has
  populated the knowledge graph to get a migration-ready prioritization.
tools: neo4j/*, Read, Write
handoffs:
  - label: Get migration recommendations for high complexity programs
    agent: migration-advisor
    prompt: >
      Provide Java migration strategy for the top 10 highest complexity programs 
      identified by complexity-scorer.
    send: false
---

# Complexity Scorer Agent

You calculate complexity scores for all COBOL programs and rank them for 
migration prioritization.

## Before starting, load your skills:
1. Read `.claude/skills/neo4j-schema/SKILL.md`
2. Read `.claude/skills/cobol-insights/SKILL.md` — scoring heuristics and rubrics

## Scoring Dimensions

Calculate these metrics for every Program node:

### Dimension 1: Size Score (1-5)
- < 200 lines → 1
- 200-500 lines → 2
- 500-1000 lines → 3
- 1000-2000 lines → 4
- > 2000 lines → 5

### Dimension 2: Cyclomatic Complexity Proxy (1-5)
Count decision points: EVALUATE branches + IF statements + PERFORM VARYING + WHEN
Query:
```cypher
MATCH (p:Program {program_id: $id})-[:CONTAINS]->(para:Paragraph)
RETURN p.program_id, sum(para.decision_points) AS total_decisions
```
Score: 1-5 based on total_decisions buckets: <10, 10-25, 25-50, 50-100, >100

### Dimension 3: Coupling Score (1-5)
```cypher
MATCH (p:Program {program_id: $id})
OPTIONAL MATCH (p)-[:CALLS]->(callees)
OPTIONAL MATCH (callers)-[:CALLS]->(p)
OPTIONAL MATCH (p)-[:INCLUDES]->(cbs)
RETURN count(DISTINCT callees) AS fan_out, 
       count(DISTINCT callers) AS fan_in,
       count(DISTINCT cbs) AS copybook_deps
```
Score: (fan_out + fan_in + copybook_deps) bucketed 0-2→1, 3-5→2, 6-10→3, 11-20→4, >20→5

### Dimension 4: Risk Flag Score (0-3)
- +1 if has_goto = true
- +1 if has_alter = true
- +1 if has_redefines = true

### Dimension 5: Data Complexity (1-5)
Count data items in WORKING-STORAGE with OCCURS, REDEFINES, or nested > 4 levels.

## Final Score Calculation
```
migration_score = (size_score * 0.2) + (complexity_score * 0.3) + 
                  (coupling_score * 0.3) + (risk_score * 0.2 * 5/3)
```
Normalize to 1-100. Categorize:
- 1-25: **EASY** — good first migration candidates
- 26-50: **MODERATE** — standard effort
- 51-75: **HARD** — needs experienced team
- 76-100: **CRITICAL** — rewrite vs migrate decision needed

## Write Scores Back to Neo4j
```cypher
MATCH (p:Program {program_id: $id})
SET p.migration_score = $score,
    p.migration_category = $category,
    p.size_score = $size_score,
    p.complexity_score = $complexity_score,
    p.coupling_score = $coupling_score,
    p.risk_score = $risk_score,
    p.scored_at = $timestamp
```

## Output: Migration Backlog
Write `.claude/state/migration-backlog.json` — programs sorted by:
1. EASY programs with zero inbound calls first (safe starting points)
2. Then EASY with inbound calls
3. Then MODERATE
4. HARD and CRITICAL last

Also write a markdown report to `docs/migration-backlog.md` with a table:
| Program | Score | Category | Fan-In | Fan-Out | Risk Flags | Recommended Wave |
```

---

### `.claude/agents/migration-advisor.md`

```markdown
---
name: migration-advisor
description: >
  Provides Java migration recommendations for specific COBOL programs. Maps COBOL
  constructs to Java equivalents, suggests Spring Boot service patterns, identifies
  data structure mappings, and generates a migration blueprint. Use for programs
  that have been complexity-scored and selected for migration.
tools: Read, neo4j/*, Write
---

# Migration Advisor Agent

You provide concrete Java migration recommendations for individual COBOL programs.

## Before starting, load your skills:
1. Read `.claude/skills/java-mapping/SKILL.md` — COBOL to Java construct mappings
2. Read `.claude/skills/cobol-patterns/SKILL.md` — patterns to watch for
3. Read `.claude/skills/neo4j-schema/SKILL.md` — to query program details

## For Each Program, Produce a Migration Blueprint

### Step 1: Load program details from Neo4j
```cypher
MATCH (p:Program {program_id: $name})
OPTIONAL MATCH (p)-[:CONTAINS]->(para:Paragraph)
OPTIONAL MATCH (p)-[:CALLS]->(callees:Program)
OPTIONAL MATCH (p)-[:INCLUDES]->(cbs:Copybook)
OPTIONAL MATCH (p)-[:READS|WRITES]->(files:CobolFile)
RETURN p, collect(DISTINCT para) AS paragraphs, 
       collect(DISTINCT callees) AS callees,
       collect(DISTINCT cbs) AS copybooks,
       collect(DISTINCT files) AS files
```

### Step 2: Map constructs to Java

**Data Division → Java Classes:**
- Each 01-level record → Java POJO / Record class
- Copybook inclusions → shared domain objects (put in `common` module)
- PIC 9(n) → int / long / BigDecimal (based on size and usage)
- PIC X(n) → String
- OCCURS n TIMES → List<T> or T[]
- 88-level conditions → enum or boolean constants

**Procedure Division → Java Methods:**
- Main paragraph (0000-MAIN) → `public void execute()` method
- PERFORM → method call
- PERFORM VARYING → for/while loop
- CALL → injected service call (@Autowired)
- EVALUATE → switch expression (Java 14+)
- READ/WRITE → Repository method call (Spring Data)

**Program type detection:**
- Has INPUT-OUTPUT files + PERFORM main loop → Batch Job → Spring Batch ItemProcessor
- Receives LINKAGE SECTION params, returns data → Service → Spring @Service
- Has CICS commands → needs CICS-to-REST migration path → Spring MVC @RestController

### Step 3: Identify migration risks in this program
Query for risk flags and explain each one:
```cypher
MATCH (p:Program {program_id: $name})
RETURN p.has_goto, p.has_alter, p.has_redefines, p.estimated_complexity
```

For each risk:
- **GOTO**: explain which paragraphs have GOTOs, suggest restructuring as state machine or loop
- **ALTER**: flag as CRITICAL — requires manual analysis; no automated mapping exists
- **REDEFINES**: explain each REDEFINES usage; map to Java sealed classes or union types

### Step 4: Suggest target Java architecture
Based on program type, recommend:
- **Package structure** (e.g., `com.lbg.legacy.customer.service`)
- **Spring Boot components** needed
- **Dependencies** (Spring Batch, Spring Data JPA, etc.)
- **Test approach** (JUnit 5, Mockito for service mocks)

### Step 5: Write migration blueprint
Write to `docs/migration-blueprints/<PROGRAM-ID>-blueprint.md`:

```markdown
# Migration Blueprint: CUSTOMER-PROC → CustomerProcessingService

## Program Summary
- Complexity: MODERATE (score: 42)
- Lines: 450
- Paragraphs: 8
- External calls: 2 (ACCOUNT-MGR, PAYMENT-HANDLER)
- Copybooks: 2 (CUSTOMER-RECORD, ACCOUNT-RECORD)

## Recommended Java Architecture
- Type: Spring @Service
- Package: com.lbg.legacy.customer.service
- Class: CustomerProcessingService

## Data Mapping
| COBOL Item | Java Type | Notes |
|---|---|---|
| CUSTOMER-RECORD | CustomerRecord.java | Shared domain object |
| CUST-ID PIC 9(8) | Long customerId | |
| CUST-NAME PIC X(40) | String customerName | trim() on read |

## Method Mapping
| Paragraph | Java Method | Notes |
|---|---|---|
| 0000-MAIN | execute() | Entry point |
| 1000-INIT | initialise() | Constructor logic |

## Risks and Mitigations
...

## Estimated Effort
- Data mapping: 2 days
- Logic conversion: 3 days  
- Testing: 2 days
- Total: ~7 days
```
```

---

### `.claude/agents/documentation-generator.md`

```markdown
---
name: documentation-generator
description: >
  Generates human-readable documentation for COBOL programs directly from the
  knowledge graph. Produces program overview docs, call hierarchy diagrams 
  (in Mermaid), data dictionary exports, and a full portfolio summary.
  Use after the knowledge graph is built to create documentation that no longer
  exists for legacy code.
tools: neo4j/*, Read, Write
---

# Documentation Generator Agent

You generate documentation for COBOL programs that often has no existing docs.
You query the knowledge graph and produce structured markdown documentation.

## Before starting, load your skills:
1. Read `.claude/skills/neo4j-schema/SKILL.md`
2. Read `.claude/skills/cobol-insights/SKILL.md`

## Document Types to Generate

### 1. Program Overview Doc (`docs/programs/<PROGRAM-ID>.md`)
For each program:
```cypher
MATCH (p:Program {program_id: $name})
OPTIONAL MATCH (p)-[:CALLS]->(callees)
OPTIONAL MATCH (callers)-[:CALLS]->(p)
OPTIONAL MATCH (p)-[:INCLUDES]->(cbs)
RETURN p, collect(callees.program_id) AS calls,
       collect(callers.program_id) AS called_by,
       collect(cbs.name) AS copybooks
```

Output format:
```markdown
# CUSTOMER-PROC

**Author:** J.SMITH  
**Written:** 1987-03-15  
**Complexity:** MODERATE  
**Lines:** 450

## Purpose
[Infer from program name, paragraph names, and file access patterns]

## Call Hierarchy
Called by: BATCH-RUNNER, ONLINE-HANDLER
Calls: ACCOUNT-MGR, PAYMENT-HANDLER

## Data Dependencies  
Uses copybooks: CUSTOMER-RECORD, ACCOUNT-RECORD
Reads files: CUSTOMER-FILE
Writes files: AUDIT-FILE

## Paragraphs
| Name | Lines | Purpose |
|---|---|---|
| 0000-MAIN | 85-102 | Main control flow |

## Risk Flags
[List any GOTOs, ALTERs, REDEFINES]
```

### 2. Mermaid Call Hierarchy Diagram
```cypher
MATCH path = (p:Program {program_id: $name})-[:CALLS*1..3]->(downstream)
RETURN path
```

Output as Mermaid flowchart:
```
graph TD
  CUSTOMER-PROC --> ACCOUNT-MGR
  CUSTOMER-PROC --> PAYMENT-HANDLER
  PAYMENT-HANDLER --> AUDIT-WRITER
```

### 3. Data Dictionary (`docs/data-dictionary.md`)
Query all copybooks and their data items:
```cypher
MATCH (cb:Copybook)-[:DEFINES]->(di:DataItem)
RETURN cb.name AS copybook, di.name, di.level, di.pic, 
       di.has_redefines, di.has_occurs
ORDER BY cb.name, di.level, di.name
```

Format as a comprehensive data dictionary table.

### 4. Portfolio Summary (`docs/portfolio-summary.md`)
High-level executive summary of the entire COBOL estate:
- Total programs, copybooks, lines of code
- Distribution by complexity category  
- Top 10 most-called programs (critical infrastructure)
- Top 10 most complex programs (migration challenges)
- Estimated total migration effort
- Recommended migration wave plan
```

---

## SKILL FILES — `.claude/skills/`

---

### `.claude/skills/cobol-syntax/SKILL.md`

```markdown
---
name: cobol-syntax
description: >
  COBOL language grammar, division and section structure, PIC clause syntax, 
  level numbers, procedure division verbs, and language construct reference.
  Use when parsing, analysing, or explaining COBOL source code structure.
---

# COBOL Syntax Reference

COBOL programs are divided into four mandatory divisions in fixed order.
See DIVISIONS.md for detailed coverage. Key summary below.

## The Four Divisions

1. **IDENTIFICATION DIVISION** — Program metadata
   - PROGRAM-ID (required), AUTHOR, DATE-WRITTEN, REMARKS

2. **ENVIRONMENT DIVISION** — System and file linkage
   - CONFIGURATION SECTION: SOURCE-COMPUTER, OBJECT-COMPUTER
   - INPUT-OUTPUT SECTION: FILE-CONTROL with SELECT/ASSIGN pairs

3. **DATA DIVISION** — All data definitions
   - FILE SECTION: FD entries (file descriptors)
   - WORKING-STORAGE SECTION: in-memory variables and records
   - LINKAGE SECTION: parameters from calling programs
   - LOCAL-STORAGE SECTION: thread-local data (CICS/modern COBOL)

4. **PROCEDURE DIVISION** — Executable logic
   - Organized into sections and paragraphs
   - USING clause lists LINKAGE SECTION parameters

## Level Numbers

| Level | Meaning |
|---|---|
| 01 | Top-level group item or record |
| 02-49 | Subordinate group or elementary items |
| 66 | RENAMES clause (aliases) |
| 77 | Standalone elementary item (no group) |
| 88 | Condition name (boolean flag for a parent item's value) |

## PIC Clause Quick Reference

| Symbol | Meaning | Example |
|---|---|---|
| 9 | Numeric digit | PIC 9(8) = 8-digit number |
| X | Alphanumeric character | PIC X(40) = 40-char string |
| A | Alphabetic only | PIC A(10) |
| V | Implied decimal point | PIC 9(5)V99 = 99999.99 |
| S | Signed number | PIC S9(7)V99 |
| Z | Zero-suppress leading zeros | PIC ZZZ9 |
| $ | Currency sign (display) | PIC $$$9.99 |

## Key Procedure Division Verbs

- **PERFORM** — Call a paragraph (structured GOTO equivalent)
  - `PERFORM para-name` — single call
  - `PERFORM para-name THRU end-para` — range
  - `PERFORM para-name UNTIL condition` — loop
  - `PERFORM para-name VARYING x FROM 1 BY 1 UNTIL x > 10` — counted loop

- **CALL** — Invoke external COBOL program
  - `CALL 'PROGRAM-NAME' USING param1, param2`
  - `CALL 'PROGRAM-NAME' USING BY REFERENCE param` (pass by ref)
  - `CALL 'PROGRAM-NAME' USING BY CONTENT param` (pass by value)

- **COPY** — Include a copybook
  - `COPY copybook-name` — verbatim include
  - `COPY copybook-name REPLACING ==OLD== BY ==NEW==` — with substitution

- **MOVE** — Data assignment
  - `MOVE value TO target`
  - `MOVE CORRESPONDING source TO target` — field-name matching

- **EVALUATE** — Switch/case
  - `EVALUATE TRUE WHEN condition1 ... WHEN condition2 ...`
  - `EVALUATE variable WHEN value1 ... WHEN OTHER ...`

- **READ/WRITE/OPEN/CLOSE/REWRITE/DELETE** — File I/O verbs

- **GOTO** — Unconditional branch (legacy, avoid in modern COBOL)
- **ALTER** — Modifies a GOTO target at runtime (self-modifying, critical risk)

## For more detail:
- Division deep dive: read DIVISIONS.md
- Data type details: read DATA-TYPES.md  
- All procedure verbs: read VERBS.md
```

---

### `.claude/skills/neo4j-schema/SKILL.md`

```markdown
---
name: neo4j-schema
description: >
  LegacyCobolInsights Neo4j knowledge graph schema. Node labels, properties,
  relationship types, and constraints for the COBOL modernization graph database.
  Use when reading from or writing to the Neo4j graph in this project.
---

# LegacyCobolInsights — Neo4j Schema Reference

## Node Labels and Properties

### :Program
Represents a COBOL program source file.

| Property | Type | Description |
|---|---|---|
| program_id | String (unique) | PROGRAM-ID value e.g. "CUSTOMER-PROC" |
| source_path | String | Relative path to .cbl file |
| author | String | AUTHOR from IDENTIFICATION DIVISION |
| date_written | String | DATE-WRITTEN value |
| line_count | Integer | Total source lines |
| has_goto | Boolean | Contains GOTO statements |
| has_alter | Boolean | Contains ALTER statements (critical risk) |
| has_redefines | Boolean | Contains REDEFINES clauses |
| estimated_complexity | String | LOW / MEDIUM / HIGH / CRITICAL |
| migration_score | Float | 1-100 score (set by complexity-scorer) |
| migration_category | String | EASY / MODERATE / HARD / CRITICAL |
| parsed_at | String | ISO timestamp of last parse |
| scored_at | String | ISO timestamp of last scoring |

### :Paragraph
A named paragraph within a COBOL program's PROCEDURE DIVISION.

| Property | Type | Description |
|---|---|---|
| fqn | String (unique) | Fully-qualified: "PROGRAM-ID.PARA-NAME" |
| name | String | Paragraph name e.g. "0000-MAIN" |
| line_start | Integer | First line number |
| line_end | Integer | Last line number |
| line_count | Integer | line_end - line_start |
| decision_points | Integer | Count of IF/EVALUATE/PERFORM VARYING |

### :Copybook
A shared data definition file (.cpy).

| Property | Type | Description |
|---|---|---|
| name | String (unique) | Copybook name e.g. "CUSTOMER-RECORD" |
| source_path | String | Relative path to .cpy file |
| data_item_count | Integer | Number of data items defined |
| parsed_at | String | ISO timestamp |

### :DataItem
A data field or record defined in a copybook or program.

| Property | Type | Description |
|---|---|---|
| fqn | String (unique) | "COPYBOOK-NAME.FIELD-NAME" |
| name | String | Field name |
| level | String | Level number ("01", "05", etc.) |
| pic | String | PIC clause e.g. "9(8)" |
| value | String | VALUE clause if present |
| has_redefines | Boolean | Has REDEFINES clause |
| has_occurs | Boolean | Has OCCURS clause |
| occurs_times | Integer | OCCURS n TIMES value if present |

### :CobolFile
A file accessed by COBOL programs (SELECT/ASSIGN).

| Property | Type | Description |
|---|---|---|
| logical_name | String (unique) | SELECT name e.g. "CUSTOMER-FILE" |
| physical_name | String | ASSIGN TO value e.g. "CUSTMAST" |
| organisation | String | SEQUENTIAL / INDEXED / RELATIVE |

### :JCLJob
A JCL job that executes COBOL programs.

| Property | Type | Description |
|---|---|---|
| job_name | String (unique) | JOB card name |
| source_path | String | Path to .jcl file |
| scheduler | String | TWS / CA7 / ZOWE / UNKNOWN |

## Relationship Types

| Relationship | From → To | Properties | Meaning |
|---|---|---|---|
| CALLS | Program → Program | using_params: [String] | Program invokes another via CALL |
| CONTAINS | Program → Paragraph | — | Program owns a paragraph |
| PERFORMS | Paragraph → Paragraph | thru: Boolean | Paragraph calls another via PERFORM |
| INCLUDES | Program → Copybook | — | Program uses a copybook via COPY |
| DEFINES | Copybook → DataItem | — | Copybook declares a data field |
| READS | Paragraph → CobolFile | — | Paragraph reads from a file |
| WRITES | Paragraph → CobolFile | — | Paragraph writes to a file |
| EXECUTES | JCLJob → Program | step_name: String | JCL job runs a program in a step |
| REDEFINES | DataItem → DataItem | — | DataItem redefines another's memory |
| OWNED_BY | Paragraph → Program | — | Reverse of CONTAINS (for traversal) |

## Schema Setup Cypher
For full schema creation, run: `scripts/setup/create-neo4j-schema.cypher`

## Common Pattern — MERGE Template
Always use MERGE (not CREATE) to ensure idempotency:
```cypher
MERGE (p:Program {program_id: $program_id})
SET p.source_path = $source_path,
    p.line_count = $line_count
```
See `.claude/skills/cypher-patterns/SKILL.md` for full pattern library.
```

---

### `.claude/skills/cypher-patterns/SKILL.md`

```markdown
---
name: cypher-patterns
description: >
  Proven Cypher query and write patterns for the LegacyCobolInsights graph.
  Includes MERGE templates for ingestion, common traversal queries for analysis,
  and aggregation patterns for reporting. Use when writing to or querying Neo4j.
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
```

---

### `.claude/skills/cobol-patterns/SKILL.md`

```markdown
---
name: cobol-patterns
description: >
  COBOL anti-patterns, modernization signals, and risk patterns to identify during
  parsing and analysis. Use when evaluating COBOL code quality, flagging migration
  risks, or assessing programs for Java conversion feasibility.
---

# COBOL Patterns Reference

## Anti-Patterns (Flag During Parsing)

### CRITICAL Risk — Flag immediately
| Pattern | Identifier | Risk |
|---|---|---|
| ALTER verb | `ALTER para-name TO PROCEED TO other-para` | Self-modifying code — no automated migration path |
| GOTO with complex control flow | Multiple GOTOs across sections | Spaghetti control flow |
| REDEFINES on large groups | REDEFINES on 01-level items | Memory overlap — maps to complex union types |

### HIGH Risk
| Pattern | Identifier | Risk |
|---|---|---|
| Deep PERFORM THRU | `PERFORM A THRU Z` spanning many paragraphs | Implicit flow coupling |
| Numeric GOTO (COMPUTED GO TO) | `GO TO para1 para2 DEPENDING ON var` | Switch via GOTO — complex to map |
| OCCURS DEPENDING ON | `OCCURS 1 TO 100 DEPENDING ON counter` | Dynamic arrays — need careful Java handling |
| Global working storage mutation | Paragraphs modifying 01-level items with no encapsulation | Hidden state — risk in concurrent Java |

### MEDIUM Risk
| Pattern | Identifier | Risk |
|---|---|---|
| Implicit string padding | MOVE short-string TO long-string (COBOL pads with spaces) | Java Strings don't pad — behaviour change |
| Numeric truncation | MOVE large-pic TO small-pic | Java throws; COBOL truncates silently |
| INSPECT/STRING/UNSTRING | String manipulation verbs | Complex but mappable to String methods |
| Timezone-unaware date arithmetic | DATE-OF-INTEGER, INTEGER-OF-DATE without timezone | Careful Java LocalDate mapping needed |

## Modernization Signals (Positive Indicators)

### Easy Migration Signals
- Single entry/exit paragraph structure (0000-MAIN → sub-paragraphs)
- No GOTO, no ALTER
- LINKAGE SECTION matches clean service interface
- Pure computational programs (no file I/O, no CICS)
- Small line count (<300 lines) with low coupling

### Batch Job Signals (→ Spring Batch)
- OPEN INPUT ... OPEN OUTPUT patterns
- PERFORM UNTIL EOF loops
- READ ... AT END patterns
- No LINKAGE SECTION (no external callers)

### Service/API Signals (→ Spring @Service or @RestController)
- Has LINKAGE SECTION parameters
- Called by many programs (high fan-in)
- No direct file I/O (delegates to other programs)

### CICS Transaction Signals (→ REST API or Spring MVC)
- EXEC CICS SEND/RECEIVE MAP
- EXEC CICS RETURN TRANSID
- EXEC CICS READ/WRITE

## For complexity scoring heuristics, read ANTI-PATTERNS.md
## For migration readiness rubrics, read MODERNIZATION-SIGNALS.md
```

---

### `.claude/skills/java-mapping/SKILL.md`

```markdown
---
name: java-mapping
description: >
  Mappings from COBOL constructs to Java equivalents. Covers data type mappings,
  control flow mappings, file I/O patterns, and Spring Boot architecture recommendations.
  Use when migration-advisor is producing Java blueprints for COBOL programs.
---

# COBOL → Java Mapping Reference

## Data Type Mappings

| COBOL PIC | Java Type | Notes |
|---|---|---|
| PIC 9(1-4) | int | Small integers |
| PIC 9(5-9) | long | Larger integers |
| PIC 9(10+) | BigInteger | Very large integers |
| PIC 9(n)V9(m) | BigDecimal | Always use BigDecimal for money |
| PIC S9(n)V9(m) | BigDecimal | Signed decimal |
| PIC X(n) | String | Use .trim() when reading COBOL data |
| PIC A(n) | String | Alphabetic — still String in Java |
| 01-level group | POJO / Java Record | Field-per-child mapping |
| 88-level condition | boolean / enum constant | `if (ws.customerActive)` |
| OCCURS n TIMES | T[] or List<T> | Prefer List for mutability |
| OCCURS DEPENDING ON | List<T> (dynamic) | Size from the depending-on field |

## Control Flow Mappings

| COBOL Construct | Java Equivalent |
|---|---|
| PERFORM para-name | privateMethod() call |
| PERFORM para VARYING x FROM 1 BY 1 UNTIL x > n | for (int x = 1; x <= n; x++) |
| PERFORM para UNTIL condition | while (!condition) { method(); } |
| EVALUATE TRUE WHEN cond1 | if/else if chain or switch expression |
| EVALUATE var WHEN val1 | switch(var) { case val1: } |
| GOTO (simple) | Extract to loop or if/else |
| GOTO (complex) | State machine pattern |
| ALTER | Manual refactor required — no mapping |
| STOP RUN | return; (from main method) |

## File I/O Mappings

| COBOL Pattern | Java/Spring Pattern |
|---|---|
| OPEN INPUT file | repository.findAll() or FileReader |
| READ file AT END | Iterator hasNext() check |
| WRITE record | repository.save(entity) |
| CLOSE file | (handled by Spring / try-with-resources) |
| Sequential file processing | Spring Batch ItemReader/ItemWriter |
| VSAM KSDS (keyed) | Spring Data JPA with @Id |

## Program Type → Spring Boot Architecture

| COBOL Program Type | Spring Component | Pattern |
|---|---|---|
| Batch program (file in/out) | @Configuration + ItemProcessor | Spring Batch Job |
| Subroutine (LINKAGE SECTION) | @Service | Injected service bean |
| CICS transaction | @RestController | REST endpoint |
| Report generator | @Service + @Component | Service + template |
| DB2 embedded SQL | @Repository + JPA | Spring Data JPA |

## Copybook → Shared Domain Object
Each copybook becomes a shared Java class in a `common` or `domain` module:
```java
// COBOL: CUSTOMER-RECORD copybook
// Java:
public record CustomerRecord(
    long customerId,      // PIC 9(8)
    String customerName,  // PIC X(40) — trim() on construction
    BigDecimal balance,   // PIC S9(9)V99
    boolean isActive      // 88 CUSTOMER-ACTIVE VALUE 'Y'
) {}
```

## For full type mapping tables: read TYPE-MAPPING.md
## For structural pattern mappings: read PATTERN-MAPPING.md
```

---

### `.claude/skills/cobol-insights/SKILL.md`

```markdown
---
name: cobol-insights
description: >
  Modernization analysis heuristics, complexity scoring rubrics, migration wave 
  planning guidance, and interpretation of COBOL knowledge graph metrics.
  Use when graph-query, complexity-scorer, or migration-advisor needs to interpret
  results or make recommendations.
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
```

---

### `.claude/skills/impact-analysis/SKILL.md`

```markdown
---
name: impact-analysis
description: >
  Ripple effect analysis patterns for COBOL change impact. Covers how changes
  propagate through CALLS, INCLUDES, and shared data relationships. Use when
  impact-analyzer agent is performing blast radius assessment.
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
```

---

## SCRIPTS — `scripts/setup/create-neo4j-schema.cypher`

```cypher
// LegacyCobolInsights — Schema Initialisation
// Run once before first ingestion

// Uniqueness constraints (also create indexes automatically)
CREATE CONSTRAINT program_id_unique IF NOT EXISTS
FOR (p:Program) REQUIRE p.program_id IS UNIQUE;

CREATE CONSTRAINT copybook_name_unique IF NOT EXISTS
FOR (c:Copybook) REQUIRE c.name IS UNIQUE;

CREATE CONSTRAINT data_item_fqn_unique IF NOT EXISTS
FOR (d:DataItem) REQUIRE d.fqn IS UNIQUE;

CREATE CONSTRAINT paragraph_fqn_unique IF NOT EXISTS
FOR (para:Paragraph) REQUIRE para.fqn IS UNIQUE;

CREATE CONSTRAINT file_logical_unique IF NOT EXISTS
FOR (f:CobolFile) REQUIRE f.logical_name IS UNIQUE;

CREATE CONSTRAINT jcl_job_name_unique IF NOT EXISTS
FOR (j:JCLJob) REQUIRE j.job_name IS UNIQUE;

// Additional indexes for common query patterns
CREATE INDEX program_complexity IF NOT EXISTS
FOR (p:Program) ON (p.estimated_complexity);

CREATE INDEX program_migration_category IF NOT EXISTS
FOR (p:Program) ON (p.migration_category);

CREATE INDEX program_migration_score IF NOT EXISTS
FOR (p:Program) ON (p.migration_score);

CREATE INDEX paragraph_name IF NOT EXISTS
FOR (para:Paragraph) ON (para.name);
```

---

## SAMPLE COBOL — `sample-cobol/CUSTOMER-PROC.cbl`

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTOMER-PROC.
       AUTHOR. J.SMITH.
       DATE-WRITTEN. 1987-03-15.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-FILE ASSIGN TO CUSTMAST
               ORGANIZATION IS SEQUENTIAL.
           SELECT AUDIT-FILE ASSIGN TO AUDITMAST
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD CUSTOMER-FILE.
       01 CUSTOMER-REC.
          COPY CUSTOMER-RECORD.

       FD AUDIT-FILE.
       01 AUDIT-REC         PIC X(200).

       WORKING-STORAGE SECTION.
       01 WS-FLAGS.
          05 WS-EOF-FLAG     PIC X VALUE 'N'.
             88 WS-EOF       VALUE 'Y'.
          05 WS-ERROR-FLAG   PIC X VALUE 'N'.
             88 WS-ERROR     VALUE 'Y'.
       01 WS-COUNTERS.
          05 WS-RECORDS-READ    PIC 9(7) VALUE ZEROES.
          05 WS-RECORDS-WRITTEN PIC 9(7) VALUE ZEROES.

       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-OPEN-FILES
           PERFORM 2000-PROCESS-CUSTOMERS
               UNTIL WS-EOF
           PERFORM 9000-CLOSE-FILES
           STOP RUN.

       1000-OPEN-FILES.
           OPEN INPUT CUSTOMER-FILE
           OPEN OUTPUT AUDIT-FILE
           PERFORM 1100-READ-CUSTOMER.

       1100-READ-CUSTOMER.
           READ CUSTOMER-FILE
               AT END MOVE 'Y' TO WS-EOF-FLAG.
           ADD 1 TO WS-RECORDS-READ.

       2000-PROCESS-CUSTOMERS.
           CALL 'ACCOUNT-MGR' USING CUSTOMER-REC
           PERFORM 1100-READ-CUSTOMER.

       9000-CLOSE-FILES.
           CLOSE CUSTOMER-FILE
           CLOSE AUDIT-FILE.
```

---

## `sample-cobol/copybooks/CUSTOMER-RECORD.cpy`

```cobol
       05 CUST-ID           PIC 9(8).
       05 CUST-NAME         PIC X(40).
       05 CUST-STATUS       PIC X VALUE 'A'.
          88 CUST-ACTIVE    VALUE 'A'.
          88 CUST-INACTIVE  VALUE 'I'.
          88 CUST-CLOSED    VALUE 'C'.
       05 CUST-BALANCE      PIC S9(9)V99.
       05 CUST-OPEN-DATE    PIC 9(8).
```

---

## `README.md`

````markdown
# COBOL Modernization Knowledge Graph

A VS Code + GitHub Copilot Chat powered platform for analysing and modernising
legacy COBOL codebases using AI agents, Claude Agent Skills, and Neo4j.

## Prerequisites

- VS Code with GitHub Copilot extension
- Claude extension (or Copilot configured with Claude)
- Neo4j running locally (`bolt://localhost:7687`) or remote
- Node.js (for Neo4j MCP server)

## Setup

### 1. Configure Neo4j connection
```bash
cp .env.example .env
# Edit .env and set NEO4J_PASSWORD
```

### 2. Initialise the Neo4j schema
```bash
# In Neo4j Browser or cypher-shell:
cat scripts/setup/create-neo4j-schema.cypher | cypher-shell -u neo4j -p <password>
```

### 3. Open workspace in VS Code
```bash
code cobol-modernization/
```

### 4. Verify MCP server is connected
In VS Code: View → Output → GitHub Copilot → check neo4j MCP shows as connected.

## Usage

Open GitHub Copilot Chat and use `@agent-name` to invoke agents:

### Full Pipeline (start here)
```
@cobol-ingestion scan ./sample-cobol and produce an ingestion manifest
```
Then follow the handoff buttons that appear after each agent completes.

### Individual Agent Queries
```
@graph-query which programs call ACCOUNT-MGR?
@graph-query what is the full call chain from BATCH-RUNNER?
@impact-analyzer what breaks if I change the CUSTOMER-RECORD copybook?
@complexity-scorer score all programs and produce a migration backlog
@migration-advisor give me a Java blueprint for CUSTOMER-PROC
@documentation-generator generate docs for all programs in the graph
```

## Agent Handoff Chain
```
@cobol-ingestion → @cobol-parser → @graph-builder → @graph-query
                                                  ↘ @complexity-scorer → @migration-advisor
                                                  ↘ @impact-analyzer → @migration-advisor
                                                  ↘ @documentation-generator
```

## Directory Structure
See PROJECT_SPEC.md for full structure and file-by-file specifications.
````

---

## `.env.example`

```
# Neo4j Connection (used by .vscode/mcp.json)
NEO4J_PASSWORD=your_password_here
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
```

---

## Build Instructions for Claude Code

**Claude Code: When building this project, follow this sequence:**

1. Create the full directory structure exactly as specified in the tree above
2. Write every file listed under "File Contents" — do not skip any file
3. For skill files that reference sub-documents (DIVISIONS.md, TYPE-MAPPING.md, etc.), create those files with appropriate content based on the skill's topic — use the main SKILL.md as guidance for what depth to go into
4. Create `sample-cobol/ACCOUNT-MGR.cbl`, `PAYMENT-HANDLER.cbl`, and `BATCH-RUNNER.cbl` as realistic COBOL programs that interact with CUSTOMER-PROC via CALL statements
5. Create `sample-cobol/copybooks/ACCOUNT-RECORD.cpy` and `PAYMENT-RECORD.cpy` as realistic copybook files
6. Create `scripts/validation/validate-graph-integrity.cypher` and `scripts/utilities/export-graph-json.cypher` with appropriate Cypher
7. Create `docs/agent-usage-guide.md` with examples of every agent invocation pattern
8. Create `tests/sample-queries.md` with 20 example GHCP queries one per agent
9. Create `ARCHITECTURE.md` documenting the design decisions: why Skills over prompts, why GHCP as UI, how handoffs work, how MCP integrates
10. Initialise as a git repository with a `.gitignore` that excludes `.env` and `.claude/state/`

**Validation: After building, verify:**
- Every `.agent.md` file has valid YAML frontmatter with `name`, `description`, `tools`
- Every `SKILL.md` has valid YAML frontmatter with `name` and `description`
- `.vscode/mcp.json` is valid JSON
- All referenced sub-skill files (DIVISIONS.md, TYPE-MAPPING.md, etc.) exist
- Sample COBOL files are syntactically plausible COBOL
- The README accurately describes how to run the system