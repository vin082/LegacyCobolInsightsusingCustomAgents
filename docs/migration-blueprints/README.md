# Customer Processing System Migration - Complete Blueprint Package

**Migration Target:** BATCH-RUNNER → CUSTOMER-PROC → ACCOUNT-MGR → PAYMENT-HANDLER  
**Architecture:** Spring Boot + Spring Batch  
**Status:** Ready for Implementation  
**Date:** March 2, 2026

---

## 📋 Blueprint Index

### Program-Specific Blueprints

1. **[BATCH-RUNNER-blueprint.md](BATCH-RUNNER-blueprint.md)** ⭐ **Entry Point**
   - **Complexity:** LOW (123 lines)
   - **Target:** Spring Batch Application
   - **Key Features:**
     - ItemReader for BATCHIN file
     - ItemProcessor orchestration
     - ItemWriter for BATCHRPT
     - JobExecutionListener for statistics
   - **Effort:** 8 days
   - **Risk:** LOW (no GOTO, clean structure)

2. **[ACCOUNT-MGR-blueprint.md](ACCOUNT-MGR-blueprint.md)** 🔧 **Business Logic**
   - **Complexity:** MEDIUM (115 lines)
   - **Target:** AccountManagementService
   - **Key Features:**
     - COMP-3 → BigDecimal migration (CRITICAL)
     - 88-level conditions → Enums
     - Indexed file I/O → Spring Data JPA
     - Account state management
   - **Effort:** 9.5 days
   - **Risk:** MEDIUM-HIGH (COMP-3 precision, indexed file)

3. **[PAYMENT-HANDLER-blueprint.md](PAYMENT-HANDLER-blueprint.md)** ⚠️ **GOTO Refactoring**
   - **Complexity:** MEDIUM (118 lines)
   - **Target:** PaymentHandlerService
   - **Key Features:**
     - **GOTO elimination** (guard clause pattern)
     - Payment type routing (REGULAR, REFUND, REVERSAL)
     - Sequential file → Database persistence
     - Validation extraction
   - **Effort:** 7.5 days
   - **Risk:** HIGH (GOTO refactoring requires extensive testing)

### Integration & Deployment

4. **[INTEGRATION-STRATEGY.md](INTEGRATION-STRATEGY.md)** 🚀 **Complete Guide**
   - System architecture (monolith vs. microservices)
   - Service communication patterns
   - Comprehensive testing strategy
   - Deployment sequence (10-week timeline)
   - Rollback procedures
   - Monitoring & observability

---

## 🎯 Quick Start Guide

### For Project Managers

**Total Effort Estimate:**
- BATCH-RUNNER: 8 days
- ACCOUNT-MGR: 9.5 days
- PAYMENT-HANDLER: 7.5 days
- Integration & Testing: 10 days
- **Total: ~35 days (7 weeks)** for one developer, or **3-4 weeks** with a team of 3

**Risk Summary:**
- **LOW:** BATCH-RUNNER (clean structure, no GOTOs)
- **MEDIUM-HIGH:** ACCOUNT-MGR (COMP-3 precision, indexed file)
- **HIGH:** PAYMENT-HANDLER (GOTO elimination requires extensive testing)

**Critical Success Factors:**
1. COMP-3 → BigDecimal conversion accuracy (financial data)
2. GOTO control flow correctly mapped
3. Transaction boundaries preserved
4. Performance within 5% of COBOL baseline

### For Developers

**Read in this order:**
1. Start with [PAYMENT-HANDLER-blueprint.md](PAYMENT-HANDLER-blueprint.md) (GOTO patterns critical)
2. Then [ACCOUNT-MGR-blueprint.md](ACCOUNT-MGR-blueprint.md) (COMP-3 precision)
3. Then [BATCH-RUNNER-blueprint.md](BATCH-RUNNER-blueprint.md) (Spring Batch architecture)
4. Finally [INTEGRATION-STRATEGY.md](INTEGRATION-STRATEGY.md) (how they fit together)

**Key Implementation Notes:**
- All copybooks → Java domain models with enums for 88-level conditions
- All CALL statements → service method invocations
- All file I/O → Spring Data JPA repositories
- Transaction management via Spring `@Transactional`

### For Architects

**Architecture Decision Records:**

| Decision | Rationale |
|---|---|
| **Monolith First** | Simpler deployment, maintain call chain semantics, easier testing |
| **Spring Batch** | Industry standard for batch processing, built-in metrics, retry/skip |
| **Spring Data JPA** | Replace indexed files with database, maintain ACID properties |
| **BigDecimal** | COMP-3 precision for financial calculations (CRITICAL) |
| **Guard Clauses** | Eliminate GOTO with early return pattern (clean, testable) |
| **Enums** | Type-safe replacement for 88-level conditions |

---

## 📊 Migration Dashboard

### Programs Overview

```
┌────────────────────┬────────────┬──────────┬────────┬──────────────┐
│ Program            │ Complexity │ Lines    │ Risk   │ Effort (days)│
├────────────────────┼────────────┼──────────┼────────┼──────────────┤
│ BATCH-RUNNER       │ LOW        │ 123      │ LOW    │ 8            │
│ ACCOUNT-MGR        │ MEDIUM     │ 115      │ MED-HI │ 9.5          │
│ PAYMENT-HANDLER    │ MEDIUM     │ 118      │ HIGH   │ 7.5          │
│ Integration/Test   │ -          │ -        │ MEDIUM │ 10           │
├────────────────────┼────────────┼──────────┼────────┼──────────────┤
│ TOTAL              │            │ 356      │        │ 35           │
└────────────────────┴────────────┴──────────┴────────┴──────────────┘
```

### Risk Heat Map

```
                HIGH │                  ⚠️ PAYMENT-HANDLER
                     │                     (GOTO)
                     │
       MEDIUM-HIGH   │         🔧 ACCOUNT-MGR
                     │            (COMP-3)
                     │
              MEDIUM │
                     │
                 LOW │  ⭐ BATCH-RUNNER
                     │     (Clean)
                     │
                     └─────────────────────────────────
                       Simple          Complex
                              Structure
```

### Testing Pyramid

```
           ┌─────────────────┐
          │   E2E Tests      │  10 tests (Full batch job)
         │   (Slow)          │  Target: 100% output match
        └───────────────────┘
       ┌──────────────────────┐
      │  Integration Tests    │  50 tests (Service chains)
     │   (Medium)             │  Target: All call paths
    └────────────────────────┘
   ┌───────────────────────────┐
  │     Unit Tests             │  200+ tests
 │      (Fast)                 │  Target: 90%+ coverage
└─────────────────────────────┘
```

---

## 🔍 Critical Implementation Notes

### 1. GOTO Elimination (PAYMENT-HANDLER)

**COBOL Pattern:**
```cobol
IF WS-INVALID-PAYMENT
    MOVE 999 TO LS-RETURN-CODE
    GO TO 9000-EXIT.
```

**Java Solution (Guard Clause):**
```java
if (!paymentValidator.isValid(paymentRequest)) {
    return 999;  // Early return replaces GOTO
}
```

**Testing Requirements:**
- ✅ Map all execution paths (with/without GOTO)
- ✅ Unit tests for each path
- ✅ Integration tests for control flow
- ✅ Target: 100% branch coverage

### 2. COMP-3 Precision (ACCOUNT-MGR)

**COBOL Declaration:**
```cobol
05  ACCT-BALANCE  PIC S9(11)V99 COMP-3.
```

**Java Mapping:**
```java
@Column(name = "balance", precision = 13, scale = 2)
private BigDecimal balance;  // NEVER use double!
```

**Critical Rules:**
- ⚠️ **NEVER** use `double` or `float` for currency
- ✅ **ALWAYS** use `BigDecimal`
- ✅ Database column: `NUMERIC(13,2)` (PostgreSQL)
- ✅ Test precision with edge cases: `99999999999.99`

### 3. Spring Batch Configuration (BATCH-RUNNER)

**Chunk Size Tuning:**
```java
.<CustomerRecord, CustomerRecord>chunk(100, transactionManager)
```

**Considerations:**
- Too small: Performance overhead (many transactions)
- Too large: Memory issues, long rollback times
- Recommended: 100-500 records per chunk
- Tune based on performance testing

### 4. Transaction Management

**Single Transaction Across Call Chain:**
```java
@Bean
public Step processCustomersStep() {
    return stepBuilder
        .chunk(100, transactionManager)  // Transaction boundary
        .reader(reader)
        .processor(processor)  // Calls CUSTOMER-PROC → ACCOUNT-MGR → PAYMENT-HANDLER
        .writer(writer)
        .build();
}
```

**Behavior:**
- 100 records processed in one transaction
- If any record fails → entire chunk rolls back
- Matches COBOL implicit transaction semantics

---

## 📝 Implementation Checklist

### Phase 1: Domain Models (Week 1)
- [ ] Create CustomerRecord.java (CUSTOMER-RECORD copybook)
- [ ] Create Account.java with COMP-3 → BigDecimal (ACCOUNT-RECORD)
- [ ] Create PaymentRequest.java (PAYMENT-RECORD)
- [ ] Create enums for all 88-level conditions
- [ ] Unit tests for domain models

### Phase 2: Service Layer (Week 2-3)
- [ ] Implement PaymentHandlerService (with GOTO elimination)
- [ ] Implement AccountManagementService (with COMP-3)
- [ ] Implement CustomerProcessingService
- [ ] Unit tests for each service (200+ tests)
- [ ] Code review: GOTO paths and COMP-3 precision

### Phase 3: Data Access (Week 3-4)
- [ ] Create AccountRepository (Spring Data JPA)
- [ ] Create PaymentLogRepository
- [ ] Database schema (PostgreSQL)
- [ ] Integration tests for repositories

### Phase 4: Batch Layer (Week 4-5)
- [ ] Implement CustomerRecordReader (BATCHIN file)
- [ ] Implement CustomerRecordProcessor
- [ ] Implement BatchReportWriter (BATCHRPT file)
- [ ] Job configuration and listeners
- [ ] End-to-end batch tests

### Phase 5: Testing (Week 5-6)
- [ ] Unit test suite (90%+ coverage)
- [ ] Integration test suite (service chains)
- [ ] End-to-end batch tests
- [ ] Performance testing vs. COBOL baseline
- [ ] Regression testing (output comparison)

### Phase 6: Deployment (Week 7-10)
- [ ] Deploy to DEV environment
- [ ] Deploy to QA environment
- [ ] UAT approval
- [ ] Deploy to Staging (parallel run)
- [ ] Production cutover (blue-green)
- [ ] Stabilization period (daily monitoring)

---

## 🎓 Key Learning Points

### For Future COBOL Migrations

**Lessons from This Migration:**

1. **GOTO Elimination:**
   - Use guard clauses for early exits
   - Map all execution paths before coding
   - Require 100% branch coverage in tests

2. **COMP-3 Precision:**
   - Always use BigDecimal for currency
   - Test with maximum values
   - Document precision requirements

3. **88-Level Conditions:**
   - Convert to Java enums (type-safe)
   - Preserve business logic semantics
   - Easier to maintain than boolean flags

4. **Spring Batch:**
   - Natural fit for COBOL batch programs
   - Built-in metrics replace manual counters
   - Chunk-based processing matches COBOL behavior

5. **Testing Strategy:**
   - Compare output with COBOL baseline
   - Shadow/parallel run before cutover
   - Monitor for 90+ days post-migration

---

## 📚 Additional Resources

### Documentation
- [Spring Batch Reference](https://docs.spring.io/spring-batch/docs/current/reference/html/)
- [Spring Data JPA Guide](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/)
- [BigDecimal Best Practices](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/math/BigDecimal.html)

### Internal Documents
- Neo4j Knowledge Graph: `/docs/neo4j-query-cookbook.md`
- Agent Usage Guide: `/docs/agent-usage-guide.md`
- Parsed COBOL Data: `/.claude/state/parsed/`

### Contact
- Migration Team Slack: `#cobol-migration`
- Email: `cobol-migration@lbg.com`
- Wiki: `https://wiki.lbg.com/cobol-migration`

---

## 🚦 Migration Status

| Program | Blueprint | Dev | QA | Staging | Prod |
|---|---|---|---|---|---|
| BATCH-RUNNER | ✅ Complete | ⏳ Not Started | ⏳ Pending | ⏳ Pending | ⏳ Pending |
| ACCOUNT-MGR | ✅ Complete | ⏳ Not Started | ⏳ Pending | ⏳ Pending | ⏳ Pending |
| PAYMENT-HANDLER | ✅ Complete | ⏳ Not Started | ⏳ Pending | ⏳ Pending | ⏳ Pending |
| Integration | ✅ Complete | ⏳ Not Started | ⏳ Pending | ⏳ Pending | ⏳ Pending |

**Legend:**  
✅ Complete | 🔄 In Progress | ⏳ Not Started | ❌ Blocked

---

## 📞 Support

**For questions about:**
- Architecture decisions → Contact: Java Architect
- GOTO refactoring → See: [PAYMENT-HANDLER-blueprint.md](PAYMENT-HANDLER-blueprint.md)
- COMP-3 precision → See: [ACCOUNT-MGR-blueprint.md](ACCOUNT-MGR-blueprint.md)
- Spring Batch setup → See: [BATCH-RUNNER-blueprint.md](BATCH-RUNNER-blueprint.md)
- Integration & deployment → See: [INTEGRATION-STRATEGY.md](INTEGRATION-STRATEGY.md)

---

**Document Version:** 1.0  
**Created:** March 2, 2026  
**Last Updated:** March 2, 2026  
**Next Review:** March 9, 2026 (after Dev implementation starts)
