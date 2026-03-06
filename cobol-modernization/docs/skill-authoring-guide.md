# Skill Authoring Guide

How to create and extend skills for the COBOL Modernization platform.

## What is a Skill?

A skill is a set of Markdown files in `.claude/skills/<skill-name>/` that
agents load on-demand to get domain knowledge. Skills are NOT run automatically
— agents explicitly read skill files when they need the information.

Skills are different from agents:
- **Agent** — an AI assistant with a specific task and tools
- **Skill** — a reference document an agent reads to gain knowledge

## Skill File Structure

```
.claude/skills/<skill-name>/
├── SKILL.md          ← Main entry point (required)
│                        Agent reads this first; it summarises the skill
│                        and points to sub-documents
└── DETAIL-FILE.md    ← Detailed reference (optional, linked from SKILL.md)
```

## SKILL.md Frontmatter

Every SKILL.md must have YAML frontmatter:

```yaml
---
name: skill-name-here
description: >
  One or two sentence description of what this skill provides.
  Used by agents to decide if they should load this skill.
---
```

## Writing Effective Skills

### Principle 1: One entry point, multiple detail files
SKILL.md should be concise (< 200 lines). Put long tables, examples, and
deep dives in separate files and link to them:

```markdown
## For detailed PIC clause reference, read DATA-TYPES.md
## For all procedure verbs, read VERBS.md
```

### Principle 2: Agent-first writing
Write for an AI agent that will read and apply the content, not for humans.
Be specific: use exact syntax, exact property names, exact Cypher patterns.

**Bad:** "Use MERGE to add nodes"
**Good:**
```cypher
MERGE (p:Program {program_id: $program_id})
SET p.source_path = $source_path
```

### Principle 3: Include worked examples
For every concept, include a COBOL example, a Java mapping, or a Cypher pattern.
Examples are more useful to agents than abstract descriptions.

### Principle 4: Keep skills focused
Each skill should cover one domain area:
- `cobol-syntax` — language reference only
- `neo4j-schema` — graph schema only
- `java-mapping` — type and construct mappings only

Don't mix concerns. If an agent needs both, it loads both skills.

## Creating a New Skill

### Step 1: Create the skill directory
```
.claude/skills/my-new-skill/
└── SKILL.md
```

### Step 2: Write SKILL.md with frontmatter

```markdown
---
name: my-new-skill
description: >
  Brief description of what this skill covers and when to use it.
---

# My New Skill Title

## Overview
[Short summary of the domain]

## Key Concepts
[3-5 essential concepts with examples]

## For more detail: read DETAIL-FILE.md
```

### Step 3: Create detail files as needed

For each major sub-topic, create a separate Markdown file with deep reference.

### Step 4: Reference the skill in agents

In agent `.md` files, add a line like:
```markdown
## Before starting, load your skill:
Read `.claude/skills/my-new-skill/SKILL.md`
```

## Extending Existing Skills

To add new content to an existing skill:

1. If the SKILL.md is already long, add a new detail file:
   - Create `.claude/skills/cobol-syntax/NEW-TOPIC.md`
   - Add a reference at the bottom of `SKILL.md`: `## For new topic, read NEW-TOPIC.md`

2. If the SKILL.md is short, you can add content directly to it.

3. Never remove content from skills without checking all agents that reference them.

## Skill Design Patterns

### Pattern: Reference Tables
Best for type mappings, verb lists, property tables:

```markdown
| COBOL PIC | Java Type | Notes |
|-----------|-----------|-------|
| PIC 9(8)  | long      | |
```

### Pattern: Code Patterns
Best for Cypher queries, Java snippets, COBOL examples:

```markdown
### Safe MERGE pattern
```cypher
MERGE (p:Program {program_id: $id})
SET p.source_path = $path
```
```

### Pattern: Decision Trees
Best for agent decision logic:

```markdown
## How to classify a program:
1. Has LINKAGE SECTION and is called by others? → Service (@Service)
2. Has file I/O and PERFORM UNTIL loop? → Batch (Spring Batch)
3. Has CICS commands? → Online transaction (@RestController)
4. None of the above? → Utility (static helper class)
```

## Existing Skills Reference

| Skill | Location | Used By |
|-------|----------|---------|
| cobol-syntax | `.claude/skills/cobol-syntax/` | cobol-ingestion, cobol-parser |
| cobol-patterns | `.claude/skills/cobol-patterns/` | cobol-parser |
| neo4j-schema | `.claude/skills/neo4j-schema/` | graph-builder, graph-query, impact-analyzer, complexity-scorer |
| cypher-patterns | `.claude/skills/cypher-patterns/` | graph-builder |
| cobol-insights | `.claude/skills/cobol-insights/` | graph-query, complexity-scorer, documentation-generator |
| java-mapping | `.claude/skills/java-mapping/` | migration-advisor |
| impact-analysis | `.claude/skills/impact-analysis/` | impact-analyzer |
