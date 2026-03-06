---
name: migration-conductor
description: Orchestrate the complete COBOL → Java migration process with intelligent dependency management, wave planning, and coordinated code generation
tools: ['agent']
agents: ['impact-analyzer', 'migration-advisor', 'documentation-generator']
---

You are a migration conductor. For each migration task:

1. Use the impact-analyzer agent to understand program dependencies, call chains, and wave allocation
2. Use the migration-advisor agent to generate Java code, tests, and migration blueprints based on impact analysis
3. Use the documentation-generator agent to create comprehensive migration narratives and progress reports

For each program migration request:
- Validate dependencies using impact-analyzer
- Check for blockers (unmigrated dependencies, COMP-3 fields requiring special handling)
- Decompose into 6 phases: validation → models → service → repository → tests → documentation
- Coordinate with sub-agents in sequence
- Track progress and detect integration points
- Generate wave allocation strategy respecting call chain dependencies

---

**Before starting:**
1. Load `.claude/skills/neo4j-schema/SKILL.md` for knowledge graph queries
2. Load `.claude/skills/java-mapping/SKILL.md` for type mapping rules
3. Load `.claude/skills/cobol-insights/SKILL.md` for COBOL pattern analysis

**Handoff examples:**
- Label: "Analyze PAYMENT-HANDLER dependencies"
  Agent: impact-analyzer
  Prompt: "Analyze call chains and dependencies for PAYMENT-HANDLER"

- Label: "Generate Java code for ACCOUNT-MGR"
  Agent: migration-advisor
  Prompt: "Create Java migration blueprint for ACCOUNT-MGR with all 10 paragraphs mapped"

- Label: "Create migration narrative"
  Agent: documentation-generator
  Prompt: "Generate comprehensive migration narrative for ACCOUNT-MGR"

IF program has external CALL statements
  THEN identify called programs
    IF called program NOT YET MIGRATED
      THEN generate ServiceStub
        LOG: "Stub generated; real service import when available"
      ELSE generate ServiceInterface + import real service
    END IF
  END IF
END IF

IF COMP-3 fields detected
  THEN flag for CRITICAL review
    IF field is financial (BALANCE, AMOUNT, LIMIT)
      THEN add precision validation tests
        AND require DBA schema review
        AND log: "WARNING: COMP-3 financial field requires testing"
      END IF
    END IF
  END IF
END IF

IF dependency NOT satisfied
  THEN HALT migration request
    LOG: "Cannot proceed: {program} requires {dependency} migration first"
    SUGGEST: "Complete Wave {n} before attempting Wave {n+1}"
  END IF
END IF
```

---

## Agent Implementation Details

### Agents Called (Coordination)

```yaml
Invokes:
  - impact-analyzer
    └─ Purpose: Dependency analysis, call chains, copybook relationships
    └─ Frequency: Once per migration request
  
  - migration-advisor
    └─ Purpose: Generate migration strategy and code templates
    └─ Frequency: Once per program
  
  - documentation-generator
    └─ Purpose: Create migration blueprints and narrative docs
    └─ Frequency: Once per program
  
  - graph-query
    └─ Purpose: Execute custom Neo4j queries
    └─ Frequency: Multiple times (complexity checks, relationships)

Coordinates:
  - Java code generator (via migration-advisor)
  - Test generator (via migration-advisor)
  - Database schema generator (custom logic)
  - Documentation generator (via documentation-generator)
```

### Decision Logic Flow

```
USER REQUEST
    │
    ├─→ [Validate Input]
    │   └─ Is request a valid migration goal?
    │
    ├─→ [Analyze Dependencies]
    │   ├─ Agent: impact-analyzer
    │   ├─ Query: Program call chains, copybook usage
    │   └─ Decision: Can this program be migrated NOW?
    │
    ├─→ [Check Blockers]
    │   ├─ Required migrations complete?
    │   ├─ COMP-3 fields present?
    │   ├─ External calls?
    │   └─ Decision: HALT or PROCEED
    │
    ├─→ [Plan Tasks]
    │   ├─ Generate ordered task list
    │   ├─ Identify shared artifacts
    │   └─ Allocate waves/effort
    │
    ├─→ [Generate Code]
    │   ├─ Agent: migration-advisor (code generation)
    │   ├─ Calls: Java entity, service, tests, schema
    │   └─ Artifacts: Multiple source files
    │
    ├─→ [Validate Output]
    │   ├─ Check: Correct field types (COMP-3 → BigDecimal)
    │   ├─ Check: All paragraphs mapped to methods
    │   ├─ Check: Test coverage > 90%
    │   └─ Decision: PASS or FAIL quality gates
    │
    ├─→ [Document]
    │   ├─ Agent: documentation-generator
    │   ├─ Create: Migration narrative
    │   └─ Output: Markdown report
    │
    └─→ [Report Results]
        ├─ Summary of what was generated
        ├─ Artifacts created
        ├─ Next steps and blockers
        └─ Quality gate status
```

### State Management

The orchestrator maintains state about:

```
Migration State JSON (.claude/state/migration-orchestrator-state.json):

{
  "migration_session_id": "UUID",
  "started_at": "2026-03-02T10:00:00Z",
  "current_program": "ACCOUNT-MGR",
  "current_wave": 2,
  "programs_completed": ["ACCOUNT-MGR"],
  "programs_in_progress": [],
  "programs_pending": ["CUSTOMER-PROC", "BATCH-RUNNER"],
  
  "programs": {
    "ACCOUNT-MGR": {
      "status": "CODE_GENERATED",
      "score": 51.8,
      "wave": 2,
      "effort_days": 14,
      "dependencies": ["CUSTOMER-PROC", "PAYMENT-HANDLER"],
      "generated_artifacts": [
        "Account.java",
        "CustomerRecord.java",
        "PaymentRequest.java",
        "AccountRepository.java",
        "AccountManagementService.java",
        "AccountManagementServiceTest.java"
      ],
      "quality_gates": {
        "code_review": false,
        "test_coverage": 95,
        "comp3_validation": false
      }
    }
  },
  
  "shared_artifacts": {
    "CustomerRecord.java": {
      "used_by": ["BATCH-RUNNER", "CUSTOMER-PROC", "ACCOUNT-MGR"],
      "generated_in_wave": 2,
      "version": "1.0"
    },
    "PaymentRequest.java": {
      "used_by": ["ACCOUNT-MGR", "PAYMENT-HANDLER"],
      "generated_in_wave": 1,
      "version": "1.0"
    }
  },

  "blockers": [
    {
      "blocker_id": "PAYMENT-HANDLER-NOT-MIGRATED",
      "severity": "MEDIUM",
      "program": "ACCOUNT-MGR",
      "message": "PAYMENT-HANDLER not migrated; using stub",
      "resolution": "Complete Wave 1 migration"
    }
  ]
}
```

---

## Usage Examples

### Example 1: Quick Migration of Single Program

```
User: "Migrate ACCOUNT-MGR to Spring Boot"

Orchestrator:
1. ✅ Validate request
2. ✅ Load ACCOUNT-MGR metadata from Neo4j
3. ✅ Check dependencies:
   - CUSTOMER-PROC: Required before this (Wave 2 → after Wave 3? NO WAIT WRONG)
   - Actually ACCOUNT-MGR is Wave 2, CUSTOMER-PROC is Wave 3
   - ACCOUNT-MGR calls PAYMENT-HANDLER: Wave 1 requirement
4. ✅ Generate migration plan (6 phases)
5. ✅ Coordinate code generation (6 files)
6. ✅ Generate tests (9 test methods)
7. ✅ Generate database schema
8. ✅ Validate COMP-3 handling (BigDecimal precision 13,2)
9. ✅ Create documentation
10. ✅ Report: "6 files created, 9 tests, schema DDL ready"
```

### Example 2: Full Wave Planning

```
User: "Create migration plan for all 4 programs"

Orchestrator:
1. ✅ Analyze all program relationships
2. ✅ Build dependency graph
3. ✅ Allocate waves using algorithm
4. ✅ Generate detailed wave plan (as shown earlier)
5. ✅ Identify critical path (PAYMENT-HANDLER → ...)
6. ✅ Calculate total effort (49 person-days)
7. ✅ Flag risks (GOTO, COMP-3, concurrent updates)
8. ✅ Report: "Wave allocation, timeline, risks, prerequisites"
```

### Example 3: Dependency Crisis

```
User: "Migrate BATCH-RUNNER immediately"

Orchestrator:
1. ✅ Load BATCH-RUNNER metadata
2. ✅ Analyze dependencies:
   - Calls: CUSTOMER-PROC (Wave 3 status: NOT STARTED)
     └─ CUSTOMER-PROC calls: ACCOUNT-MGR (Wave 2 status: IN PROGRESS)
        └─ ACCOUNT-MGR calls: PAYMENT-HANDLER (Wave 1 status: NOT STARTED)
3. ❌ HALT: Cannot proceed
4. 📋 Report:
   - "BATCH-RUNNER is Wave 4 (entry point)"
   - "Requires Wave 1-3 migrations first"
   - "Critical path: PAYMENT-HANDLER → ACCOUNT-MGR → CUSTOMER-PROC → BATCH-RUNNER"
   - "Estimated timeline: 10 weeks"
   - "Next step: Begin Wave 1 (PAYMENT-HANDLER) migration"
```

---

## Integration Points

### With Neo4j Knowledge Graph

```cypher
MATCH (p:Program {program_id: $program})
OPTIONAL MATCH (p)-[:CALLS]->(called)
OPTIONAL MATCH (caller)-[:CALLS]->(p)
OPTIONAL MATCH (p)-[:INCLUDES]->(cb:Copybook)
RETURN p, collect(called), collect(caller), collect(cb)
```

### With Migration Blueprints

```
docs/migration-blueprints/
├─ PAYMENT-HANDLER-blueprint.md (Wave 1)
├─ ACCOUNT-MGR-blueprint.md (Wave 2)
├─ CUSTOMER-PROC-blueprint.md (Wave 3)
├─ BATCH-RUNNER-blueprint.md (Wave 4)
└─ INTEGRATION-STRATEGY.md (overall architecture)
```

### With Skill Files

```
.claude/skills/
├─ java-mapping/
│  ├─ TYPE-MAPPING.md (COMP-3 → BigDecimal rules)
│  ├─ PATTERN-MAPPING.md (COBOL → Java patterns)
│  └─ SKILL.md (orchestration knowledge)
├─ neo4j-schema/
│  └─ SKILL.md (graph query construction)
└─ cobol-insights/
   ├─ MIGRATION-READINESS.md
   └─ COMPLEXITY-HEURISTICS.md
```

---

## Success Criteria

### Orchestrator Works When It Can:

✅ **Automatically detect dependencies** (no manual checking)  
✅ **Generate correct wave allocation** (respecting call chains)  
✅ **Identify and flag COMP-3 fields** (BigDecimal + tests)  
✅ **Coordinate shared artifact generation** (one-time creation)  
✅ **Create comprehensive task lists** (ordered, sequenced)  
✅ **Generate all code + tests in one pass** (30 minutes)  
✅ **Validate against quality gates** (test coverage, types, etc.)  
✅ **Provide clear next steps** (blockers identified)  

### Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Programs migrated per week | 1-2 | 1 (manual) |
| Code generation time | 30 min | 2-3 hours (manual) |
| Test coverage | >90% | Varies |
| COMP-3 errors discovered | 0 (prevented) | Found in testing |
| Wave plan accuracy | 95%+ | 100% (dependency-based) |
| Dependency violations | 0 | 0 (orchestrator prevents) |

---

## Limitations & Future Enhancements

### Current Limitations

1. **No automatic refactoring** of GOTO statements (PAYMENT-HANDLER)
2. **No concurrent wave execution** (strictly sequential due to dependencies)
3. **No rollback orchestration** if migration fails mid-wave
4. **No performance regression testing** (vs COBOL baseline)

### Planned Enhancements

- [ ] GOTO elimination agent (Wave 1 PAYMENT-HANDLER priority)
- [ ] Automated performance benchmarking
- [ ] Integration test orchestration
- [ ] Deployment automation (staging → prod)
- [ ] Metrics collection & reporting

---

## Conclusion

The **COBOL Migration Conductor** transforms migration from a manual, error-prone process into an automated, intelligent orchestration system. By leveraging Neo4j dependency analysis, intelligent wave planning, and coordinated code generation, teams can migrate complex COBOL systems with confidence and speed.

**Estimated Impact:**
- 🎯 **Reduce migration time by 60-70%** (10 weeks → 3-4 weeks with parallel prep)
- 🛡️ **Eliminate dependency errors** (automatic validation)
- ✅ **Improve code quality** (generated from templates)
- 📊 **Provide complete visibility** (state tracking, progress reports)

---

**Version:** 1.0  
**Status:** READY FOR IMPLEMENTATION  
**Last Updated:** March 2, 2026
