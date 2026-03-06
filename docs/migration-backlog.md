# COBOL Migration Backlog Report

**Generated:** 2026-03-02  
**Total Programs:** 4  
**Total Estimated Effort:** 49 person-days (~10 weeks single developer)

## Executive Summary

| Category | Count | Avg Score | Total Effort (days) |
|----------|-------|-----------|---------------------|
| MODERATE | 3 | 35.5 | 35 |
| HARD | 1 | 51.8 | 14 |

**Key Findings:**
- ✅ No CRITICAL complexity programs
- ⚠️ 1 HARD program (ACCOUNT-MGR) - highest coupling
- ⚠️ 1 program with GOTO statements (PAYMENT-HANDLER)
- ✅ No ALTER statements or circular dependencies

---

## Migration Wave Allocation

### Wave 1: Foundation (Leaf Programs)
**Programs:** 1 | **Effort:** 15 days

*Priority: Quick wins and leaf programs with no dependencies*

| Program | Score | Category | Effort | Risk Flags |
|---------|-------|----------|--------|------------|
| PAYMENT-HANDLER | 44.3 | MODERATE | 15d | **GOTO** ⚠️ |

**Wave 1 Focus:** PAYMENT-HANDLER is the leaf program (no downstream calls). Despite having GOTO statements requiring refactoring, it must be migrated first as it blocks ACCOUNT-MGR.

**Key Deliverables:**
- Eliminate GOTO statements using guard clauses/early returns
- Implement PaymentHandlerService in Java
- Create PaymentRecord entity mappings
- Comprehensive unit tests for all 3 payment types

---

### Wave 2: Core Business Logic
**Programs:** 1 | **Effort:** 14 days

*Priority: Medium complexity programs with resolved dependencies*

| Program | Score | Category | Effort | Risk Flags |
|---------|-------|----------|--------|------------|
| ACCOUNT-MGR | 51.8 | HARD | 14d | High Copybook Coupling ⚠️ |

**Wave 2 Focus:** Core account management logic. Highest complexity due to:
- 3 copybook dependencies (CUSTOMER-RECORD, ACCOUNT-RECORD, PAYMENT-RECORD)
- COMP-3 decimal field conversions (critical for financial accuracy)
- Indexed file operations (ACCOUNT-FILE)

**Key Deliverables:**
- AccountManagerService with Spring @Service pattern
- COMP-3 → BigDecimal conversion utilities
- AccountRepository with JPA
- Integration tests with PAYMENT-HANDLER

---

### Wave 3: Orchestration Layer
**Programs:** 1 | **Effort:** 10 days

*Priority: Orchestrators coordinating business logic*

| Program | Score | Category | Effort | Risk Flags |
|---------|-------|----------|--------|------------|
| CUSTOMER-PROC | 32.8 | MODERATE | 10d | - |

**Wave 3 Focus:** Lightweight orchestration layer between BATCH-RUNNER and ACCOUNT-MGR. Simplest program (57 lines) with clean structure.

**Key Deliverables:**
- CustomerProcessingService
- Integration with AccountManagerService
- End-to-end testing

---

### Wave 4: Entry Points (Migrate LAST)
**Programs:** 1 | **Effort:** 10 days

*Priority: Entry points requiring full system integration*

| Program | Score | Category | Effort | Risk Flags |
|---------|-------|----------|--------|------------|
| BATCH-RUNNER | 29.3 | MODERATE | 10d | - |

**Wave 4 Focus:** Batch job entry point. Must wait for all downstream programs to be migrated.

**Key Deliverables:**
- Spring Batch Job configuration
- FlatFileItemReader for BATCH-INPUT
- CustomerItemProcessor integration
- Full system integration tests
- Production cutover plan

---

## Detailed Program Analysis

| Program | Score | Category | Lines | Fan-In | Fan-Out | Copybooks | Risk Flags | Effort | Wave |
|---------|-------|----------|-------|--------|---------|-----------|------------|--------|------|
| PAYMENT-HANDLER | 44.3 | MODERATE | 118 | 1 | 0 | 1 | **GOTO** | 15d | 1 |
| ACCOUNT-MGR | 51.8 | HARD | 115 | 1 | 1 | 3 | - | 14d | 2 |
| CUSTOMER-PROC | 32.8 | MODERATE | 57 | 1 | 1 | 1 | - | 10d | 3 |
| BATCH-RUNNER | 29.3 | MODERATE | 123 | 0 | 1 | 1 | - | 10d | 4 |

---

## Recommended Migration Sequence

Based on dependency analysis and complexity scores, migrate in this order:

1. **PAYMENT-HANDLER** (Wave 1, MODERATE) - Leaf program - migrate first to unblock ACCOUNT-MGR. **CRITICAL: GOTO elimination required**

2. **ACCOUNT-MGR** (Wave 2, HARD) - Core business logic with highest coupling (3 copybooks). Complex COMP-3 conversions.

3. **CUSTOMER-PROC** (Wave 3, MODERATE) - Lightweight orchestrator. Clean 57-line program.

4. **BATCH-RUNNER** (Wave 4, MODERATE) - Entry point - migrate LAST after all dependencies complete. Spring Batch implementation.

---

## Risk Analysis

### High Risk Programs

Programs requiring special attention:

#### 🔴 PAYMENT-HANDLER - GOTO Elimination Critical
- **Risk:** GOTO statements create complex control flow
- **Mitigation:** Refactor using guard clauses, early returns, or state machine pattern
- **Estimated Refactoring:** +50% effort = 15 days
- **Blueprint:** See [PAYMENT-HANDLER-blueprint.md](migration-blueprints/PAYMENT-HANDLER-blueprint.md) for patterns

#### ⚠️ ACCOUNT-MGR - High Coupling Risk
- **Risk:** 3 shared copybooks create tight coupling
- **Dependencies:** 
  - CUSTOMER-RECORD (shared with BATCH-RUNNER, CUSTOMER-PROC)
  - ACCOUNT-RECORD (unique)
  - PAYMENT-RECORD (shared with PAYMENT-HANDLER)
- **Mitigation:** Create shared Java entity library early in migration
- **Estimated Impact:** Any copybook change affects multiple programs

---

### Copybook Coupling Analysis

#### CUSTOMER-RECORD (3 programs) 🔴 **HIGH COUPLING**
Used by: BATCH-RUNNER, CUSTOMER-PROC, ACCOUNT-MGR

**Impact:** Any change to CUSTOMER-RECORD requires coordinated updates across 75% of programs.

**Recommendation:** Migrate this copybook to shared Java entities in Wave 1 alongside PAYMENT-HANDLER.

#### PAYMENT-RECORD (2 programs) ⚠️ **MEDIUM COUPLING**
Used by: ACCOUNT-MGR, PAYMENT-HANDLER

**Impact:** Tight coupling between these programs via CALL parameters.

**Recommendation:** Migrate together in Waves 1-2 to maintain data contract.

#### ACCOUNT-RECORD (1 program) ✅ **LOW COUPLING**
Used by: ACCOUNT-MGR only

**Impact:** Isolated to single program.

**Recommendation:** Can be migrated independently in Wave 2.

---

## Effort Breakdown by Phase

| Phase | Programs | Effort (days) | Duration (weeks) | Team Size |
|-------|----------|---------------|------------------|-----------|
| Wave 1 | PAYMENT-HANDLER | 15 | 3 | 1-2 developers |
| Wave 2 | ACCOUNT-MGR | 14 | 2-3 | 2 developers |
| Wave 3 | CUSTOMER-PROC | 10 | 2 | 1 developer |
| Wave 4 | BATCH-RUNNER | 10 | 2 | 1-2 developers |
| **Total** | **4 programs** | **49 days** | **9-10 weeks** | **Single developer** |

**With 3-person team:** 4-5 months (parallelizing independent work)

---

## Scoring Methodology

Programs scored across 5 dimensions per [COMPLEXITY-HEURISTICS.md](../.claude/skills/cobol-insights/COMPLEXITY-HEURISTICS.md):

### Dimension Scores (1-5 scale):

**PAYMENT-HANDLER:**
- Size: 2/5 (118 lines → small-medium)
- Complexity: 3/5 (10 paragraphs, medium structure)
- Coupling: 1/5 (fan-in: 1, fan-out: 0, copybooks: 1)
- Risk: 1/3 (has GOTO)
- Data: 2/5 (1 copybook)
- **Final Score: 44.3** → MODERATE

**ACCOUNT-MGR:**
- Size: 2/5 (115 lines)
- Complexity: 3/5 (10 paragraphs)
- Coupling: 3/5 (fan-in: 1, fan-out: 1, copybooks: 3 **HIGH**)
- Risk: 0/3 (clean)
- Data: 3/5 (3 copybooks)
- **Final Score: 51.8** → HARD

**CUSTOMER-PROC:**
- Size: 1/5 (57 lines → small)
- Complexity: 2/5 (5 paragraphs, simple)
- Coupling: 2/5 (fan-in: 1, fan-out: 1, copybooks: 1)
- Risk: 0/3 (clean)
- Data: 2/5 (1 copybook)
- **Final Score: 32.8** → MODERATE

**BATCH-RUNNER:**
- Size: 2/5 (123 lines)
- Complexity: 2/5 (5 paragraphs, simple loop)
- Coupling: 1/5 (fan-in: 0, fan-out: 1, copybooks: 1)
- Risk: 0/3 (clean)
- Data: 2/5 (1 copybook)
- **Final Score: 29.3** → MODERATE

**Formula:** `(size * 0.2) + (complexity * 0.3) + (coupling * 0.3) + (risk * 0.2 * 5/3)`

---

## Next Steps

### ✅ Phase 1: Preparation (Week 1-2)
- [ ] Review all migration blueprints in [docs/migration-blueprints/](migration-blueprints/)
- [ ] Set up Java project structure (Spring Boot 3.x)
- [ ] Create shared entity library for copybooks
- [ ] Establish CI/CD pipeline with automated testing

### 🎯 Phase 2: Wave 1 Execution (Week 3-5)
- [ ] Migrate PAYMENT-HANDLER
- [ ] Eliminate GOTO statements
- [ ] Create comprehensive test suite
- [ ] Performance benchmark against COBOL version

### 🎯 Phase 3: Wave 2 Execution (Week 6-8)
- [ ] Migrate ACCOUNT-MGR
- [ ] Validate COMP-3 conversions
- [ ] Integration testing with PAYMENT-HANDLER
- [ ] Load testing for indexed file operations

### 🎯 Phase 4: Wave 3 Execution (Week 9-10)
- [ ] Migrate CUSTOMER-PROC
- [ ] End-to-end system testing
- [ ] Performance validation

### 🎯 Phase 5: Wave 4 Execution (Week 11-12)
- [ ] Migrate BATCH-RUNNER to Spring Batch
- [ ] Full system integration
- [ ] Production cutover planning
- [ ] Rollback procedures

---

## Success Criteria

- ✅ All programs achieve >80% unit test coverage
- ✅ Integration tests pass for full call chain
- ✅ Performance within 10% of COBOL baseline
- ✅ Zero data loss during migration
- ✅ Successful parallel run for 2 weeks minimum

---

**Report Generated:** 2026-03-02  
**Knowledge Graph:** neo4j://localhost:7687/neo4j  
**Scoring Agent:** complexity-scorer v1.0
