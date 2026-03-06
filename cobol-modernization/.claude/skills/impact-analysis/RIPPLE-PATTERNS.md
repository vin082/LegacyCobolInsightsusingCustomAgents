# Ripple Effect Patterns — How COBOL Changes Propagate

## Ripple Pattern 1: Copybook Field Rename

**Trigger:** Renaming a field in a copybook (e.g., CUST-ID → CUSTOMER-ID)

**Ripple path:**
```
CUSTOMER-RECORD copybook
    ↓ INCLUDES
All programs that use this copybook (direct impact)
    ↓ CALLS (upstream)
All programs that CALL those programs (transitive impact)
    ↓ CALLS (further upstream)
JCL jobs that schedule any affected program
```

**Detection query:**
```cypher
MATCH (cb:Copybook {name: 'CUSTOMER-RECORD'})<-[:INCLUDES]-(p:Program)
OPTIONAL MATCH path = (upstream:Program)-[:CALLS*1..5]->(p)
RETURN p.program_id AS direct_impact,
       collect(DISTINCT upstream.program_id) AS transitive_impact
```

**Remediation steps:**
1. Update field name in copybook
2. Find all MOVE/IF/COMPUTE statements referencing old field name in all users
3. Update field references program by program
4. Rebuild and regression test each program

---

## Ripple Pattern 2: Program Interface Change (LINKAGE SECTION)

**Trigger:** Adding/removing/reordering parameters in LINKAGE SECTION

**Ripple path:**
```
Modified program
    ↓ CALLS (upstream — the callers)
All programs that CALL this program with USING clause
    ↓ May cascade if caller interface also changes
```

**Critical risk:** COBOL CALL parameters are positional, not named.
Adding a parameter in the middle breaks all callers.

**Detection query:**
```cypher
MATCH (caller:Program)-[c:CALLS]->(target:Program {program_id: $name})
RETURN caller.program_id,
       c.using_params AS current_params,
       caller.estimated_complexity
ORDER BY caller.estimated_complexity DESC
```

**Remediation strategy:**
- Always ADD new parameters at the END of the USING clause
- Use a wrapper copybook for parameter groups (so adding a field doesn't change the call)
- Consider a versioned interface: keep old entry point calling new one with defaults

---

## Ripple Pattern 3: Working-Storage Layout Change

**Trigger:** Changing a WORKING-STORAGE item that is passed to other programs

If a 01-level working-storage record is passed BY REFERENCE to a CALL, and
the layout changes, the callee's expectation of the memory layout breaks.

**Detection:** Find all CALL statements that pass the changed item:
```cypher
MATCH (p:Program {program_id: $caller})-[c:CALLS]->(callee:Program)
WHERE $changed_field IN c.using_params
RETURN callee.program_id, c.using_params
```

---

## Ripple Pattern 4: File Record Layout Change

**Trigger:** Changing a file's record structure (e.g., adding a new field to a sequential file)

**Ripple path:**
```
Modified file record structure
    ↓ READS / WRITES
All paragraphs that access this file
    ↓ CONTAINED_BY
Programs owning those paragraphs
    ↓ CALLS (upstream)
All callers of those programs
```

**Detection query:**
```cypher
MATCH (para:Paragraph)-[:READS|WRITES]->(f:CobolFile {logical_name: $file_name})
MATCH (prog:Program)-[:CONTAINS]->(para)
OPTIONAL MATCH (caller:Program)-[:CALLS*1..3]->(prog)
RETURN DISTINCT prog.program_id AS reader_writer,
       collect(DISTINCT caller.program_id) AS callers
```

**Special risk:** Sequential files must have EXACT record lengths.
Adding a field requires updating ALL programs that open the file — even
those that only READ it (they still need the correct record length).

---

## Ripple Pattern 5: Called Program Behaviour Change

**Trigger:** Modifying internal logic of a program without changing its interface

**Ripple path:** Only affects the immediate callers (interface unchanged).
However, if return code semantics change, all callers checking RETURN-CODE
are affected.

**Detection:** Check all callers and their handling of return codes:
```cypher
MATCH (caller:Program)-[:CALLS]->(target:Program {program_id: $name})
RETURN caller.program_id, caller.estimated_complexity
ORDER BY caller.estimated_complexity DESC
```

---

## Circular Dependency Ripple

**Most dangerous pattern:** When A calls B and B calls A (directly or via intermediaries).

```cypher
// Find all circular dependency chains
MATCH path = (a:Program)-[:CALLS*2..10]->(a)
RETURN a.program_id AS node_in_cycle,
       [n IN nodes(path) | n.program_id] AS cycle_path,
       length(path) AS cycle_length
ORDER BY cycle_length
```

**Remediation:** Circular dependencies must be broken BEFORE migration:
1. Identify the "weakest link" in the cycle (simplest program to refactor)
2. Extract the shared state into a new service/database
3. Have both programs call the new service instead of each other
4. Verify cycle is broken before proceeding with migration

---

## Impact Score Calculation

For each affected program, compute:

```
impact_score = (direct_callers * 0.30)
             + (transitive_depth * 0.20)
             + (copybook_breadth * 0.25)
             + (program_complexity_weight * 0.15)
             + (risk_flag_weight * 0.10)
```

**Thresholds:**
| Score | Impact Level | Action |
|-------|-------------|--------|
| 0-3 | LOW | Notify owner, run unit tests |
| 4-6 | MEDIUM | Regression test full chain, staged rollout |
| 7-9 | HIGH | Change management process, parallel run |
| 10-12 | CRITICAL | Architecture review board sign-off required |
