---
name: neo4j-schema
description: LegacyCobolInsights Neo4j knowledge graph schema. Node labels, properties, relationship types, and constraints for the COBOL modernization graph database. Use when reading from or writing to the Neo4j graph in this project.
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
