# Integration Strategy & Deployment Guide
## Customer Processing System Migration

**Programs:** BATCH-RUNNER → CUSTOMER-PROC → ACCOUNT-MGR → PAYMENT-HANDLER  
**Target Architecture:** Spring Boot Microservices / Spring Batch  
**Migration Date:** TBD  
**Version:** 1.0

---

## Table of Contents
1. [System Overview](#system-overview)
2. [Integration Architecture](#integration-architecture)
3. [Service Communication Patterns](#service-communication-patterns)
4. [Testing Strategy](#testing-strategy)
5. [Deployment Sequence](#deployment-sequence)
6. [Rollback Strategy](#rollback-strategy)
7. [Monitoring & Observability](#monitoring--observability)

---

## System Overview

### Current COBOL Call Chain
```
BATCH-RUNNER (Entry Point)
    ↓ CALL 'CUSTOMER-PROC' USING BATCH-INPUT-REC
    CUSTOMER-PROC
        ↓ CALL 'ACCOUNT-MGR' USING CUSTOMER-REC
        ACCOUNT-MGR
            ↓ CALL 'PAYMENT-HANDLER' USING WS-PAYMENT-REQUEST, WS-RETURN-CODE
            PAYMENT-HANDLER (Leaf Program)
```

### Target Java Architecture
```
Spring Batch Application (batch-runner-service)
    ↓ Service Method Call
    CustomerProcessingService (customer-proc-service)
        ↓ Service Method Call
        AccountManagementService (account-mgr-service)
            ↓ Service Method Call
            PaymentHandlerService (payment-handler-service)
```

### Migration Approach: Monolith First, Then Microservices

**Phase 1: Monolithic Spring Boot Application** (Recommended for initial migration)
- All four programs migrated into a single Spring Boot application
- Maintain call chain through service method invocations
- Simpler deployment and testing
- Lower operational complexity

**Phase 2: Microservices (Future state)**
- Split into independent services once migration is stable
- Use REST APIs or message queues for communication
- Independent scaling and deployment

---

## Integration Architecture

### Phase 1: Monolithic Spring Boot (Recommended)

```
┌─────────────────────────────────────────────────────────────────┐
│                   batch-runner-application                      │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │            Spring Batch Layer                              │ │
│  │  ┌─────────────────────────────────────────────────────┐  │ │
│  │  │  CustomerProcessingJob                              │  │ │
│  │  │    - ItemReader<CustomerRecord>                     │  │ │
│  │  │    - ItemProcessor<CustomerRecord>                  │  │ │
│  │  │    - ItemWriter<CustomerRecord>                     │  │ │
│  │  └─────────────────────────────────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              ↓                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │            Service Layer                                   │ │
│  │                                                            │ │
│  │  CustomerProcessingService  (CUSTOMER-PROC)               │ │
│  │           ↓                                                │ │
│  │  AccountManagementService   (ACCOUNT-MGR)                 │ │
│  │           ↓                                                │ │
│  │  PaymentHandlerService      (PAYMENT-HANDLER)             │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              ↓                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │            Data Access Layer                               │ │
│  │                                                            │ │
│  │  AccountRepository (Spring Data JPA)                      │ │
│  │  PaymentLogRepository (Spring Data JPA)                   │ │
│  └───────────────────────────────────────────────────────────┘ │
│                              ↓                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │            Database Layer                                  │ │
│  │                                                            │ │
│  │  PostgreSQL:                                              │ │
│  │    - accounts table    (replaces ACCTMAST indexed file)   │ │
│  │    - payment_log table (replaces PAYLOG sequential file)  │ │
│  │    - batch_job_* tables (Spring Batch metadata)           │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Project Structure
```
batch-runner-application/
├── src/main/java/com/lbg/legacy/
│   ├── BatchRunnerApplication.java          # Spring Boot entry point
│   │
│   ├── batch/                                # Spring Batch components
│   │   ├── config/
│   │   │   └── CustomerProcessingJobConfig.java
│   │   ├── reader/
│   │   │   └── CustomerRecordReader.java
│   │   ├── processor/
│   │   │   └── CustomerRecordProcessor.java
│   │   ├── writer/
│   │   │   └── BatchReportWriter.java
│   │   └── listener/
│   │       └── JobExecutionListener.java
│   │
│   ├── service/                              # Business logic services
│   │   ├── customer/
│   │   │   └── CustomerProcessingService.java   # CUSTOMER-PROC
│   │   ├── account/
│   │   │   ├── AccountManagementService.java    # ACCOUNT-MGR
│   │   │   └── AccountValidator.java
│   │   └── payment/
│   │       ├── PaymentHandlerService.java       # PAYMENT-HANDLER
│   │       └── PaymentValidator.java
│   │
│   ├── repository/                           # Data access
│   │   ├── AccountRepository.java
│   │   └── PaymentLogRepository.java
│   │
│   ├── model/                                # Domain models (copybooks)
│   │   ├── CustomerRecord.java              # CUSTOMER-RECORD
│   │   ├── Account.java                     # ACCOUNT-RECORD
│   │   └── PaymentRequest.java              # PAYMENT-RECORD
│   │
│   ├── exception/                            # Custom exceptions
│   │   ├── AccountNotFoundException.java
│   │   └── PaymentProcessingException.java
│   │
│   └── config/
│       ├── DatabaseConfig.java
│       └── BatchConfig.java
│
├── src/main/resources/
│   ├── application.yml
│   ├── application-dev.yml
│   ├── application-prod.yml
│   ├── schema.sql                            # Database schema
│   └── data.sql                              # Test data
│
└── src/test/java/com/lbg/legacy/
    ├── integration/                          # Integration tests
    │   ├── BatchProcessingIntegrationTest.java
    │   └── ServiceChainIntegrationTest.java
    └── unit/                                 # Unit tests
        ├── service/
        ├── batch/
        └── repository/
```

---

## Service Communication Patterns

### 1. Spring Batch Processor → CustomerProcessingService

**COBOL:**
```cobol
CALL 'CUSTOMER-PROC' USING BATCH-INPUT-REC.
```

**Java (CustomerRecordProcessor.java):**
```java
@Component
@RequiredArgsConstructor
public class CustomerRecordProcessor implements ItemProcessor<CustomerRecord, CustomerRecord> {
    
    private final CustomerProcessingService customerProcessingService;
    
    @Override
    public CustomerRecord process(CustomerRecord record) throws Exception {
        // Direct method call - synchronous
        customerProcessingService.processCustomer(record);
        return record;
    }
}
```

### 2. CustomerProcessingService → AccountManagementService

**COBOL:**
```cobol
CALL 'ACCOUNT-MGR' USING CUSTOMER-REC.
```

**Java (CustomerProcessingService.java):**
```java
@Service
@RequiredArgsConstructor
public class CustomerProcessingService {
    
    private final AccountManagementService accountManagementService;
    
    public void processCustomer(CustomerRecord customer) {
        // Direct method call with return code
        int returnCode = accountManagementService.processCustomerAccount(customer);
        
        if (returnCode != 0) {
            throw new CustomerProcessingException("Account management failed: " + returnCode);
        }
    }
}
```

### 3. AccountManagementService → PaymentHandlerService

**COBOL:**
```cobol
CALL 'PAYMENT-HANDLER' USING WS-PAYMENT-REQUEST, WS-RETURN-CODE.
```

**Java (AccountManagementService.java):**
```java
@Service
@RequiredArgsConstructor
public class AccountManagementService {
    
    private final PaymentHandlerService paymentHandlerService;
    
    @Transactional
    public int processCustomerAccount(CustomerRecord customer) {
        // ... account logic ...
        
        PaymentRequest paymentRequest = buildPaymentRequest(account);
        int returnCode = paymentHandlerService.processPayment(paymentRequest);
        
        if (returnCode != 0) {
            throw new PaymentProcessingException("Payment failed: " + returnCode);
        }
        
        return 0;
    }
}
```

### Transaction Management

**Strategy:** Single Transaction Spanning Entire Call Chain

```java
// Option 1: Transaction at Batch Step Level (RECOMMENDED)
@Bean
public Step processCustomersStep() {
    return new StepBuilder("processCustomersStep", jobRepository)
        .<CustomerRecord, CustomerRecord>chunk(100, transactionManager)
        .reader(customerRecordReader)
        .processor(customerRecordProcessor)  // Entire call chain in one transaction
        .writer(batchReportWriter)
        .build();
}

// Service methods use REQUIRES_NEW if needed
@Transactional(propagation = Propagation.REQUIRES_NEW)
public void processCustomer(CustomerRecord customer) {
    // ...
}
```

**COBOL Behavior:**
- COBOL had implicit transaction boundaries at program level
- Java transaction spans entire chunk (100 records)
- Rollback on any exception within chunk

### Error Handling Pattern

```java
@Service
@RequiredArgsConstructor
public class CustomerProcessingService {
    
    private final AccountManagementService accountManagementService;
    
    public void processCustomer(CustomerRecord customer) {
        try {
            int returnCode = accountManagementService.processCustomerAccount(customer);
            
            if (returnCode != 0) {
                // Map COBOL return codes to exceptions
                switch (returnCode) {
                    case 404:
                        throw new AccountNotFoundException("Account not found for customer: " + customer.getCustomerId());
                    case 999:
                        throw new ValidationException("Account validation failed");
                    default:
                        throw new CustomerProcessingException("Unknown error: " + returnCode);
                }
            }
        } catch (Exception e) {
            log.error("Error processing customer {}: {}", customer.getCustomerId(), e.getMessage());
            // Spring Batch will skip or fail based on configuration
            throw e;
        }
    }
}
```

---

## Testing Strategy

### 1. Unit Testing (Component Level)

#### Test Each Service in Isolation

**PaymentHandlerService Tests:**
```java
@ExtendWith(MockitoExtension.class)
class PaymentHandlerServiceTest {
    
    @Mock
    private PaymentValidator validator;
    
    @Mock
    private PaymentLogRepository repository;
    
    @InjectMocks
    private PaymentHandlerService service;
    
    @Test
    void shouldProcessRegularPayment() {
        // Test individual service behavior
        PaymentRequest payment = createValidPayment(PaymentType.REGULAR);
        when(validator.isValid(payment)).thenReturn(true);
        
        int result = service.processPayment(payment);
        
        assertThat(result).isEqualTo(0);
        verify(repository).save(payment);
    }
    
    @Test
    void shouldReturnErrorCodeWhenValidationFails() {
        // Test error handling (GOTO elimination)
        PaymentRequest payment = createInvalidPayment();
        when(validator.isValid(payment)).thenReturn(false);
        
        int result = service.processPayment(payment);
        
        assertThat(result).isEqualTo(999);
        verify(repository, never()).save(any());
    }
}
```

**Target Coverage:** 90%+ code coverage for each service

### 2. Integration Testing (Service Chain)

#### Test Call Chain Without Spring Batch

```java
@SpringBootTest
@Transactional
class ServiceChainIntegrationTest {
    
    @Autowired
    private CustomerProcessingService customerProcessingService;
    
    @Autowired
    private AccountRepository accountRepository;
    
    @Autowired
    private PaymentLogRepository paymentLogRepository;
    
    @Test
    void shouldProcessCustomerThroughEntireChain() {
        // Given: Customer with account in database
        CustomerRecord customer = createTestCustomer();
        Account account = createTestAccount(customer.getCustomerId());
        accountRepository.save(account);
        
        // When: Process customer (triggers full call chain)
        customerProcessingService.processCustomer(customer);
        
        // Then: Verify all layers executed
        Account updatedAccount = accountRepository.findByCustomerId(customer.getCustomerId()).get();
        assertThat(updatedAccount.getStatus()).isEqualTo(AccountStatus.ACTIVE);
        
        List<PaymentLogEntry> payments = paymentLogRepository.findByCustomerId(customer.getCustomerId());
        assertThat(payments).hasSize(1);
        assertThat(payments.get(0).getStatus()).isEqualTo(PaymentStatus.APPROVED);
    }
    
    @Test
    void shouldRollbackOnPaymentFailure() {
        // Test transaction rollback behavior
        CustomerRecord customer = createTestCustomer();
        Account account = createTestAccount(customer.getCustomerId());
        accountRepository.save(account);
        
        // Mock payment failure
        // ... configure mock to fail payment processing ...
        
        assertThrows(PaymentProcessingException.class, () -> {
            customerProcessingService.processCustomer(customer);
        });
        
        // Verify account update was rolled back
        Account rolledBackAccount = accountRepository.findByCustomerId(customer.getCustomerId()).get();
        assertThat(rolledBackAccount.getStatus()).isEqualTo(AccountStatus.INACTIVE);  // Original state
    }
}
```

### 3. End-to-End Testing (Full Batch Job)

#### Test Complete Spring Batch Execution

```java
@SpringBatchTest
@SpringBootTest
@ActiveProfiles("test")
class BatchProcessingIntegrationTest {
    
    @Autowired
    private JobLauncherTestUtils jobLauncherTestUtils;
    
    @Autowired
    private AccountRepository accountRepository;
    
    @Autowired
    private PaymentLogRepository paymentLogRepository;
    
    @Test
    void shouldProcessEntireBatchSuccessfully() throws Exception {
        // Given: Test input file with 100 customer records
        createTestInputFile("BATCHIN-test.dat", 100);
        
        // When: Launch batch job
        JobExecution jobExecution = jobLauncherTestUtils.launchJob();
        
        // Then: Verify job completed successfully
        assertThat(jobExecution.getStatus()).isEqualTo(BatchStatus.COMPLETED);
        assertThat(jobExecution.getExitStatus().getExitCode()).isEqualTo("COMPLETED");
        
        // Verify metrics match COBOL behavior
        StepExecution stepExecution = jobExecution.getStepExecutions().iterator().next();
        assertThat(stepExecution.getReadCount()).isEqualTo(100);      // WS-TOTAL-READ
        assertThat(stepExecution.getWriteCount()).isEqualTo(100);     // WS-TOTAL-PROCESSED
        assertThat(stepExecution.getSkipCount()).isEqualTo(0);        // WS-TOTAL-ERRORS
        
        // Verify output report file matches COBOL format
        assertThat(readReportFile("BATCHRPT-test.txt"))
            .contains("CUSTOMER PROCESSING BATCH REPORT")
            .contains("Records Read: 100")
            .contains("Records Processed: 100");
    }
    
    @Test
    void shouldHandleErrorsWithSkipLogic() throws Exception {
        // Given: Input file with 10 valid and 2 invalid records
        createMixedInputFile("BATCHIN-error-test.dat", 10, 2);
        
        // When: Launch job with skip limit = 10
        JobExecution jobExecution = jobLauncherTestUtils.launchJob();
        
        // Then: Job completes, skipping invalid records
        assertThat(jobExecution.getStatus()).isEqualTo(BatchStatus.COMPLETED);
        
        StepExecution stepExecution = jobExecution.getStepExecutions().iterator().next();
        assertThat(stepExecution.getReadCount()).isEqualTo(12);
        assertThat(stepExecution.getWriteCount()).isEqualTo(10);
        assertThat(stepExecution.getSkipCount()).isEqualTo(2);
    }
}
```

### 4. Performance Testing

#### Baseline Against COBOL Performance

```java
@Test
void shouldMeetPerformanceSLAs() throws Exception {
    // Given: Large batch file (10,000 records)
    createTestInputFile("BATCHIN-perf.dat", 10_000);
    
    // When: Execute batch
    long startTime = System.currentTimeMillis();
    JobExecution jobExecution = jobLauncherTestUtils.launchJob();
    long endTime = System.currentTimeMillis();
    
    // Then: Performance meets or exceeds COBOL baseline
    long durationSeconds = (endTime - startTime) / 1000;
    assertThat(durationSeconds).isLessThan(60);  // Complete in under 1 minute
    
    double recordsPerSecond = 10_000.0 / durationSeconds;
    assertThat(recordsPerSecond).isGreaterThan(100);  // At least 100 records/sec
}
```

### 5. Regression Testing (Behavioral Equivalence)

#### Compare Java Output to COBOL Output

```java
@Test
void shouldProduceSameOutputAsCOBOL() throws Exception {
    // Given: Same input file used in COBOL test
    Path cobolInput = Paths.get("test-data/COBOL-BATCHIN.dat");
    Path cobolOutput = Paths.get("test-data/COBOL-BATCHRPT.txt");
    
    // When: Run Java batch with same input
    JobExecution jobExecution = jobLauncherTestUtils.launchJob(
        new JobParametersBuilder()
            .addString("inputFile", cobolInput.toString())
            .toJobParameters()
    );
    
    Path javaOutput = Paths.get("output/JAVA-BATCHRPT.txt");
    
    // Then: Compare key metrics (content may differ slightly)
    String cobolReport = Files.readString(cobolOutput);
    String javaReport = Files.readString(javaOutput);
    
    assertThat(extractReadCount(javaReport)).isEqualTo(extractReadCount(cobolReport));
    assertThat(extractProcessedCount(javaReport)).isEqualTo(extractProcessedCount(cobolReport));
    assertThat(extractErrorCount(javaReport)).isEqualTo(extractErrorCount(cobolReport));
}
```

### Test Pyramid

```
           ┌─────────────────┐
          │   E2E Tests      │  10 tests (Full batch job)
         │  (Slow)           │
        └───────────────────┘
       ┌──────────────────────┐
      │  Integration Tests    │  50 tests (Service chains)
     │   (Medium)             │
    └────────────────────────┘
   ┌───────────────────────────┐
  │     Unit Tests             │  200+ tests (Individual methods)
 │      (Fast)                 │
└─────────────────────────────┘
```

**Total Test Count:** ~260 tests  
**Execution Time:** < 5 minutes  
**Coverage Target:** 90%+

---

## Deployment Sequence

### Pre-Deployment Checklist

- [ ] All three migration blueprints reviewed and approved
- [ ] Database schema created in target environment
- [ ] Test data migrated from COBOL files to PostgreSQL
- [ ] Performance baseline established (COBOL metrics)
- [ ] Rollback plan documented and tested
- [ ] Monitoring and alerting configured
- [ ] Team trained on new architecture

### Deployment Phases

#### Phase 1: Development Environment (Week 1-2)

**Objective:** Complete migration and initial testing

1. Create PostgreSQL database: `customer_processing_dev`
2. Deploy Spring Boot application to dev server
3. Load test data (1,000 sample records)
4. Run full test suite
5. Performance testing
6. Fix any issues identified

**Success Criteria:**
- All tests passing (260+ tests)
- Performance >= COBOL baseline
- No data discrepancies

#### Phase 2: QA Environment (Week 3-4)

**Objective:** Comprehensive regression testing

1. Deploy to QA environment
2. Load production-like data (100,000 records)
3. Execute regression test suite:
   - Compare Java output to COBOL output (side-by-side)
   - Validate all account status transitions
   - Verify payment processing accuracy
   - Test error handling scenarios
4. User Acceptance Testing (UAT)
5. Performance testing under load

**Success Criteria:**
- UAT approval from business stakeholders
- Zero critical bugs
- Performance within 5% of COBOL
- Output reconciliation 100% match

#### Phase 3: Staging/Pre-Production (Week 5)

**Objective:** Final validation before production

1. Deploy to staging (production-identical environment)
2. Load production data snapshot
3. Run batch in parallel with COBOL:
   - COBOL processes actual production data
   - Java processes copy of production data
   - Compare outputs
4. Stress testing (peak load scenarios)
5. Disaster recovery testing
6. Final security scan

**Success Criteria:**
- Output matches COBOL 100%
- Handles peak load (500,000 records)
- Rollback procedure validated
- Security scan passes

#### Phase 4: Production Deployment (Week 6+)

**Approach:** Blue-Green Deployment with Parallel Run

##### Day 1-7: Parallel Run (Shadow Mode)
```
┌──────────────┐
│  BATCHIN.dat │
└──────┬───────┘
       │
       ├──────────► COBOL BATCH-RUNNER (PRIMARY) ──► BATCHRPT.txt
       │                                              (Used for production)
       │
       └──────────► Java batch-runner-app (SHADOW) ──► BATCHRPT-JAVA.txt
                                                        (Compare only)
```

**Actions:**
- COBOL continues to process production
- Java runs in parallel (read-only mode or separate copy)
- Compare outputs daily
- Monitor Java performance metrics

**Success Criteria:**
- 7 consecutive days of 100% output match
- No performance issues
- No errors or exceptions

##### Day 8: Cutover (Blue-Green Switch)

**Cutover Window:** Saturday 2:00 AM - 6:00 AM

**Steps:**
1. **2:00 AM** - Stop COBOL batch job
2. **2:15 AM** - Database final sync (if needed)
3. **2:30 AM** - Deploy Java application to production
4. **3:00 AM** - Smoke test with sample data
5. **3:30 AM** - Run production batch with Java
6. **4:30 AM** - Verify output and metrics
7. **5:00 AM** - UAT signoff
8. **6:00 AM** - Go-live or rollback decision

**Rollback Trigger:**
- Output mismatch > 0.1%
- Performance degradation > 20%
- Critical errors
- UAT rejection

##### Day 9-30: Stabilization Period

**Actions:**
- Daily monitoring of batch execution
- Compare output to COBOL baseline
- Quick-response team on standby
- Collect performance metrics

**Week 1:** Daily check-ins  
**Week 2-4:** Weekly reviews  
**Week 5+:** Normal operations

---

## Rollback Strategy

### Rollback Criteria

Trigger rollback if any of the following occur:

| Criteria | Threshold | Action |
|---|---|---|
| Output mismatch | > 0.1% of records | Immediate rollback |
| Data corruption | Any detected | Immediate rollback |
| Performance degradation | > 20% slower than COBOL | Rollback within 24h |
| Critical errors | > 10 per batch run | Rollback within 24h |
| Customer complaints | > 5 escalations | Assess for rollback |

### Rollback Procedure

**Time Required:** < 2 hours

#### Step 1: Stop Java Application (5 minutes)
```bash
# Stop Spring Boot application
sudo systemctl stop batch-runner-app

# Verify stopped
sudo systemctl status batch-runner-app
```

#### Step 2: Restore COBOL Environment (15 minutes)
```bash
# Reactivate COBOL JCL
cp /backup/BATCHRUN.JCL /prod/jcl/BATCHRUN.JCL

# Restore COBOL programs if modified
cp /backup/cobol/*.cbl /prod/cobol/

# Recompile if necessary
./compile-cobol-batch.sh
```

#### Step 3: Database Rollback (30 minutes)
```sql
-- If database schema was modified, restore from backup
pg_restore -d customer_processing /backup/customer_processing_pre_migration.dump

-- Or rollback specific transactions
BEGIN;
DELETE FROM payment_log WHERE timestamp > '2026-03-06 06:00:00';
ROLLBACK;  -- Use COMMIT if verification passes
```

#### Step 4: Data Reconciliation (45 minutes)
```bash
# Compare data before/after rollback
./reconcile-data.sh

# Regenerate any missing reports
./regenerate-reports.sh --from 2026-03-06
```

#### Step 5: Verification (30 minutes)
1. Run COBOL batch with test data
2. Verify output matches expected format
3. Check all downstream systems receiving data
4. UAT verification

**Total Rollback Time:** ~2 hours

---

## Monitoring & Observability

### Key Metrics to Monitor

#### 1. Batch Job Metrics

| Metric | Source | Alert Threshold |
|---|---|---|
| Job execution time | Spring Batch | > 120% baseline |
| Records read count | Spring Batch | Deviation > 5% |
| Records processed count | Spring Batch | Deviation > 5% |
| Error/skip count | Spring Batch | > 10 per run |
| Job failure rate | Spring Batch | > 0% |

#### 2. Application Metrics

| Metric | Source | Alert Threshold |
|---|---|---|
| JVM heap usage | Spring Boot Actuator | > 80% |
| GC pause time | JVM | > 1 second |
| Thread pool saturation | Micrometer | > 90% |
| Database connection pool | HikariCP | > 90% |

#### 3. Business Metrics

| Metric | Custom | Alert Threshold |
|---|---|---|
| Account activations | Service counter | Deviation > 10% |
| Payments processed | Service counter | Deviation > 10% |
| Payment failures | Service counter | > 5% |
| COMP-3 precision errors | Validator | > 0 |

### Logging Strategy

#### Log Levels
```yaml
logging:
  level:
    com.lbg.legacy: INFO
    com.lbg.legacy.service: DEBUG    # Detailed service logging
    org.springframework.batch: INFO
    org.springframework.jdbc: WARN
```

#### Structured Logging (JSON format)
```json
{
  "timestamp": "2026-03-06T03:45:12.123Z",
  "level": "INFO",
  "service": "batch-runner-app",
  "class": "CustomerProcessingService",
  "method": "processCustomer",
  "customerId": "12345678",
  "action": "account-activated",
  "duration_ms": 45,
  "success": true
}
```

### Alerting Rules

**Slack/Email Alerts:**
- Job failure (immediate)
- Performance degradation > 20% (15-minute delay)
- Error rate > 5% (10-minute delay)
- COMP-3 precision errors (immediate)

**PagerDuty Alerts:**
- Critical job failure (can't recover)
- Database connection loss
- Data corruption detected

### Dashboards

#### Grafana Dashboard: Customer Processing Batch

**Panel 1: Job Execution Overview**
- Job status (SUCCESS/FAILED)
- Execution duration (line chart)
- Records processed (gauge)

**Panel 2: Performance Comparison**
- Java vs. COBOL execution time
- Throughput (records/second)

**Panel 3: Error Tracking**
- Skip count per run
- Error rate by type
- GOTO-related control flow errors

**Panel 4: Resource Utilization**
- JVM heap usage
- Database connections
- Thread pool usage

---

## Post-Migration Activities

### Week 1-4: Hypercare Period

**Daily Activities:**
- Morning check: Review previous night's batch execution
- Compare output reports (Java vs. COBOL baseline)
- Monitor error logs
- Check performance metrics
- Daily stand-up with migration team

**Weekly Activities:**
- Performance trend analysis
- Incident review
- Fine-tuning (chunk size, connection pool, etc.)

### Month 2-3: Optimization

**Focus Areas:**
- Performance tuning (chunk size, parallel steps)
- Database index optimization
- Reduce log noise
- Automate monitoring alerts

### Month 4+: Decommission COBOL

**Prerequisites:**
- 90+ days of stable Java batch execution
- Zero critical incidents
- UAT approval for decommissioning

**Decommissioning Steps:**
1. Archive COBOL source code
2. Document business knowledge
3. Remove COBOL JCL from scheduler
4. Decommission mainframe resources
5. Update disaster recovery procedures

---

## Summary

### Migration Timeline

| Phase | Duration | Key Deliverables |
|---|---|---|
| **Development** | 2 weeks | All code complete, tests passing |
| **QA Testing** | 2 weeks | UAT approval, regression complete |
| **Staging** | 1 week | Production-ready validation |
| **Production (Parallel)** | 1 week | Shadow comparison 100% |
| **Production (Cutover)** | 1 day | Go-live |
| **Stabilization** | 4 weeks | Daily monitoring |

**Total Time:** ~10 weeks from start to stable production

### Success Criteria Summary

✅ **Functional:**
- 100% output match with COBOL baseline
- All business rules preserved
- GOTO logic correctly eliminated

✅ **Performance:**
- Execution time within 5% of COBOL
- Throughput >= 100 records/second

✅ **Quality:**
- Test coverage > 90%
- Zero critical bugs in production
- COMP-3 precision 100% accurate

✅ **Operational:**
- Successful rollback procedure validated
- Monitoring and alerting operational
- Team trained and confident

---

## Contact & Support

**Migration Team:**
- Migration Lead: [Name]
- Java Architect: [Name]
- COBOL SME: [Name]
- QA Lead: [Name]
- DBA: [Name]

**Escalation Path:**
1. Migration team Slack channel: `#cobol-migration`
2. Email: `cobol-migration@lbg.com`
3. PagerDuty: `cobol-migration-oncall`

**Documentation:**
- Migration Blueprints: `/docs/migration-blueprints/`
- Runbooks: `/docs/runbooks/`
- Architecture Diagrams: `/docs/architecture/`

---

**Document Version:** 1.0  
**Last Updated:** 2026-03-02  
**Next Review:** 2026-04-01
