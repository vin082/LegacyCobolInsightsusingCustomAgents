---
name: cobol-patterns
description: COBOL anti-patterns, modernization signals, and risk patterns to identify during parsing and analysis. Use when evaluating COBOL code quality, flagging migration risks, or assessing programs for Java conversion feasibility.
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
