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
See [PROJECT_SPEC.md](../Projectspec.md) for full structure and file-by-file specifications.

## Documentation
- [Agent Usage Guide](docs/agent-usage-guide.md) — how to use each `@agent`
- [Skill Authoring Guide](docs/skill-authoring-guide.md) — how to extend skills
- [Neo4j Query Cookbook](docs/neo4j-query-cookbook.md) — useful Cypher queries
- [Troubleshooting](docs/troubleshooting.md) — common issues and solutions
- [Architecture Decisions](ARCHITECTURE.md) — why we built it this way
