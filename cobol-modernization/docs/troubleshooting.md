# Troubleshooting Guide

Common issues and solutions for the COBOL Modernization platform.

---

## Neo4j / MCP Connection Issues

### Issue: "neo4j MCP server not connected" in GHCP output

**Symptoms:** `@graph-builder`, `@graph-query` etc. fail with no Neo4j tools available.

**Check 1:** Verify Neo4j is running:
- Open Neo4j Browser at `http://localhost:7474`
- If it doesn't load, start Neo4j Desktop or run `neo4j start`

**Check 2:** Verify your `.env` file exists:
```bash
cp .env.example .env
# Edit .env and set NEO4J_PASSWORD=yourpassword
```

**Check 3:** Verify `.vscode/mcp.json` is correct:
```json
{
  "mcpServers": {
    "neo4j": {
      "command": "npx",
      "args": ["-y", "@neo4j/mcp-server"],
      "env": {
        "NEO4J_PASSWORD": "${env:NEO4J_PASSWORD}"
      }
    }
  }
}
```

**Check 4:** Restart the MCP server:
- Open VS Code Command Palette (`Ctrl+Shift+P`)
- Run: `GitHub Copilot: Restart MCP Server`

---

## Agent Not Found / @agent-name Not Recognized

### Issue: Typing `@cobol-ingestion` in chat does nothing

**Check 1:** Verify `.vscode/settings.json` has the agents location configured:
```json
{
  "chat.agentFilesLocations": [".claude/agents"]
}
```

**Check 2:** Verify agent files exist:
```
.claude/agents/cobol-ingestion.md
.claude/agents/cobol-parser.md
... (all 8 agent files)
```

**Check 3:** Verify agent frontmatter is valid YAML:
```markdown
---
name: cobol-ingestion
description: >
  ...
tools: Glob, Read, Bash, Write
---
```

**Check 4:** Reload VS Code window:
- `Ctrl+Shift+P` → `Developer: Reload Window`

---

## Ingestion Issues

### Issue: Agent finds 0 COBOL files

**Check 1:** Are you pointing at the right directory?
```
@cobol-ingestion scan ./sample-cobol
```
Note the `./` prefix for relative paths.

**Check 2:** Check file extensions — agent looks for `.cbl`, `.cob`, `.cobol`, `.cpy`.
If your files use different extensions, you need to extend the Glob patterns.

**Check 3:** Check for `.gitignore` or access restrictions on the directory.

---

## Parsing Issues

### Issue: Files parsed with status "ERROR"

**Symptom:** `.claude/state/parsed/<PROGRAM>.json` contains `"parse_error": "reason"`.

**Common causes:**
- **EBCDIC encoding:** Mainframe files downloaded without translation.
  Solution: Convert to ASCII using iconv or your mainframe transfer tool.

- **Non-standard COBOL dialect:** IBM VS COBOL, MICROFOCUS COBOL, ACUCOBOL have
  dialect-specific syntax. Agent parses standard ANS COBOL.

- **Truncated file:** Incomplete download. Re-transfer the file.

- **Columns outside 7-72:** Fixed-format COBOL uses columns 7-72 for code.
  Content in columns 73-80 (sequence numbers) should be ignored by parser.

---

## Graph Build Issues

### Issue: Constraint violation error when running graph-builder

**Symptom:** `Neo4j error: already exists with label Program and property program_id`

**Cause:** Graph already has data from a previous run. `@graph-builder` uses MERGE
(idempotent) so this should not happen. If it does:

**Solution:** The error is likely from a constraint not yet created:
```cypher
// Run in Neo4j Browser:
CREATE CONSTRAINT program_id_unique IF NOT EXISTS
FOR (p:Program) REQUIRE p.program_id IS UNIQUE;
```

Or clear the database and re-run schema setup:
```cypher
// WARNING: Deletes all data
MATCH (n) DETACH DELETE n;
```
Then run `scripts/setup/create-neo4j-schema.cypher` again.

---

## Query Issues

### Issue: @graph-query returns no results

**Check 1:** Is the graph populated?
```cypher
MATCH (n) RETURN labels(n)[0], count(n)
```
If this returns empty, run `@graph-builder` first.

**Check 2:** Check the Cypher query the agent ran — is it using the right
property name? Refer to `.claude/skills/neo4j-schema/SKILL.md` for exact names.

**Check 3:** For case-sensitive queries like `{program_id: 'customer-proc'}`,
note that PROGRAM-IDs are stored UPPERCASED:
```cypher
// WRONG:
MATCH (p:Program {program_id: 'customer-proc'})

// CORRECT:
MATCH (p:Program {program_id: 'CUSTOMER-PROC'})
```

---

## Skill Loading Issues

### Issue: Agent doesn't seem to know COBOL syntax / Neo4j schema

**Cause:** Agent may not have explicitly loaded the skill file.

**Solution:** In your prompt, ask the agent to load the skill:
```
@cobol-parser before parsing, please read .claude/skills/cobol-syntax/SKILL.md
```

Or check that the agent's `.md` file includes a "Before starting, load your skills" section.

---

## Performance Issues

### Issue: @graph-builder is very slow

**Cause:** Loading thousands of nodes one at a time via MCP tool calls.

**Solution:** Use the UNWIND bulk loading pattern for paragraphs:
```cypher
UNWIND $paragraphs AS para
MERGE (p:Paragraph {fqn: $prog_id + '.' + para.name})
SET p += para
```

For very large codebases (1000+ programs), consider running the graph-builder
agent in batches: "Process copybooks, then the first 50 programs".

---

## Debugging Tips

### View agent state files
```
.claude/state/ingestion-manifest.json   ← What was discovered
.claude/state/parsed/<PROGRAM>.json     ← What was parsed
.claude/state/migration-backlog.json    ← Complexity scores
.claude/state/impact-reports/           ← Impact analyses
```

### Check Neo4j directly
Open Neo4j Browser (`http://localhost:7474`) and run:
```cypher
MATCH (n) RETURN labels(n)[0], count(n) ORDER BY count DESC
```

### Reset and restart
```cypher
// Clear everything and start fresh
MATCH (n) DETACH DELETE n;
```
Then re-run ingestion → parsing → graph-build pipeline.
