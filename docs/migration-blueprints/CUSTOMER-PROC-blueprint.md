# Migration Blueprint: CUSTOMER-PROC → CustomerProcessingService

## Program Summary
- **Complexity Score:** 32.8 (MODERATE)
- **Category:** MODERATE
- **Migration Wave:** 3
- **Estimated Effort:** 10 person-days
- **Lines of Code:** 57
- **Author:** J.SMITH (1987-03-15)
- **Paragraphs:** 5
- **External Calls:** 1 (ACCOUNT-MGR)
- **Copybooks:** 1 (CUSTOMER-RECORD)
- **Type:** Batch Processor / Record Iterator
- **Risk Level:** LOW

## Purpose

CUSTOMER-PROC is a **record-by-record batch processor** that iterates through all customer records from the CUSTOMER-FILE and invokes ACCOUNT-MGR for each customer to perform account management operations (validation, updates, payments).

Key characteristics:
- Reads CUSTOMER-FILE sequentially (batch input)
- Calls ACCOUNT-MGR once per customer record
- Writes audit records to AUDIT-FILE
- Acts as **orchestrator between BATCH-RUNNER and ACCOUNT-MGR**
- Simplest program in the migration chain (57 lines, no GOTO, no COMP-3 fields)

---

## COBOL Program Structure

### Identification Division
```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID. CUSTOMER-PROC.
AUTHOR. J.SMITH.
DATE-WRITTEN. 1987-03-15.
```

### Environment Division
```cobol
ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT CUSTOMER-FILE ASSIGN TO CUSTMAST
        ORGANIZATION IS SEQUENTIAL.
    SELECT AUDIT-FILE ASSIGN TO AUDITMAST
        ORGANIZATION IS SEQUENTIAL.
```

**Key Files:**
- **CUSTOMER-FILE** (Input): SEQUENTIAL file containing all customer records
  - Physical name: CUSTMAST
  - Contains: CUSTOMER-RECORD copybook structure (CUST-ID, CUST-NAME, CUST-STATUS, CUST-BALANCE, CUST-OPEN-DATE)
  
- **AUDIT-FILE** (Output): SEQUENTIAL audit log
  - Physical name: AUDITMAST
  - Records: Free-form audit trail (PIC X(200))
  - Purpose: Track processing results for each customer

### Data Division

#### Working Storage Items
```cobol
01 WS-FLAGS.
   05 WS-EOF-FLAG     PIC X VALUE 'N'.
      88 WS-EOF       VALUE 'Y'.  -- End-of-file indicator
   05 WS-ERROR-FLAG   PIC X VALUE 'N'.
      88 WS-ERROR     VALUE 'Y'.  -- Error occurred flag

01 WS-COUNTERS.
   05 WS-RECORDS-READ    PIC 9(7) VALUE ZEROES.   -- Counter: records read
   05 WS-RECORDS-WRITTEN PIC 9(7) VALUE ZEROES.   -- Counter: records written
```

**No COMP-3, No Financial Calculations** ✅

#### Linkage Section
```cobol
(None - this is a called program but does not take parameters)
```

Note: CUSTOMER-PROC is called by BATCH-RUNNER and calls ACCOUNT-MGR, but does NOT use LINKAGE SECTION parameters. Data is passed implicitly through CUSTOMER-REC structure (which is defined as part of CUSTOMER-FILE).

### Procedure Division

#### 0000-MAIN (Lines 34-39)
```cobol
0000-MAIN.
    PERFORM 1000-OPEN-FILES
    PERFORM 2000-PROCESS-CUSTOMERS
        UNTIL WS-EOF
    PERFORM 9000-CLOSE-FILES
    STOP RUN.
```
**Role:** Primary control flow  
**Pattern:** Standard COBOL batch processing (PERFORM UNTIL EOF)  
**Behavior:** Loop through all customers until end-of-file

#### 1000-OPEN-FILES (Lines 41-44)
```cobol
1000-OPEN-FILES.
    OPEN INPUT CUSTOMER-FILE
    OPEN OUTPUT AUDIT-FILE
    PERFORM 1100-READ-CUSTOMER.
```
**Role:** File initialization  
**Behavior:**
- Opens CUSTOMER-FILE for sequential read
- Opens AUDIT-FILE for sequential write
- Reads first customer record (priming read)

#### 1100-READ-CUSTOMER (Lines 46-49)
```cobol
1100-READ-CUSTOMER.
    READ CUSTOMER-FILE
        AT END MOVE 'Y' TO WS-EOF-FLAG.
    ADD 1 TO WS-RECORDS-READ.
```
**Role:** Sequential file reading  
**Pattern:** Standard COBOL READ with AT END handling  
**Behavior:**
- Reads next CUSTOMER-FILE record
- Sets WS-EOF-FLAG when no more records
- Increments counter
- Executed twice per loop: once at start (priming), once after processing

#### 2000-PROCESS-CUSTOMERS (Lines 51-53)
```cobol
2000-PROCESS-CUSTOMERS.
    CALL 'ACCOUNT-MGR' USING CUSTOMER-REC
    PERFORM 1100-READ-CUSTOMER.
```
**Role:** Main processing loop  
**Pattern:** CALL with implicit data passing  
**Behavior:**
- Calls ACCOUNT-MGR, passing CUSTOMER-REC (via COPY CUSTOMER-RECORD)
- ACCOUNT-MGR processes the account based on customer data
- Reads next customer record
- Loop continues until WS-EOF = 'Y'

**Key Detail:** The CUSTOMER-REC record is defined in the FILE SECTION (not LINKAGE SECTION), so it's passed to ACCOUNT-MGR implicitly. ACCOUNT-MGR receives it as LS-CUSTOMER-REC in its LINKAGE SECTION.

#### 9000-CLOSE-FILES (Lines 55-57)
```cobol
9000-CLOSE-FILES.
    CLOSE CUSTOMER-FILE
    CLOSE AUDIT-FILE.
```
**Role:** Cleanup  
**Behavior:** Close both input and output files

---

## COBOL → Java Migration Guide

### Recommended Java Architecture

**Type:** Spring Service (Orchestrator Pattern)  
**Package:** `com.lbg.legacy.customer.service`  
**Main Class:** `CustomerProcessingService`  
**Annotation:** `@Service`

### Architecture Rationale

| COBOL Concept | Java Pattern | Why |
|---|---|---|
| Sequential file reading | `ItemReader<CustomerRecord>` | Spring Batch paradigm for file I/O |
| PERFORM UNTIL EOF loop | Spring Batch `Step` | Built-in transaction management, error handling |
| CALL to sub-program | `@Autowired` Service injection | Loose coupling, testability |
| WS-FLAGS | Instance variables or state machine | Simpler than COBOL flags |
| WS-COUNTERS | Logging or metrics | Use Spring's structured logging |

### Implementation Approaches

#### Option 1: Spring Service (Simpler, Recommended for Wave 3)
```java
@Service
public class CustomerProcessingService {
    
    private final AccountManagementService accountManager;
    private final CustomerRepository customerRepository;
    
    public void processAllCustomers() {
        List<Customer> customers = customerRepository.findAll();
        for (Customer customer : customers) {
            processCustomer(customer);
        }
    }
    
    private void processCustomer(Customer customer) {
        accountManager.processCustomerAccount(/* ... */);
    }
}
```

**Pros:**
- Simpler than Spring Batch
- Easy to test
- No dependency on Spring Batch framework

**Cons:**
- Manual error handling
- No built-in retries or chunking

#### Option 2: Spring Batch (More Robust, Recommended for Production)
```java
@Configuration
public class CustomerProcessingJobConfig {
    
    @Bean
    public Job customerProcessingJob(JobRepository jobRepository, Step step) {
        return new JobBuilder("customerProcessingJob", jobRepository)
            .start(step)
            .build();
    }
    
    @Bean
    public Step customerProcessingStep(JobRepository jobRepository,
            PlatformTransactionManager txManager,
            ItemReader<Customer> reader,
            ItemProcessor<Customer, Void> processor,
            ItemWriter<Void> writer) {
        return new StepBuilder("customerProcessingStep", jobRepository)
            .<Customer, Void>chunk(100, txManager)
            .reader(reader)
            .processor(processor)
            .writer(writer)
            .build();
    }
}
```

**Pros:**
- Native batch processing framework for Spring
- Transactional chunking (process 100 at a time)
- Built-in retry/skip logic
- Job execution history

**Cons:**
- More configuration required
- Learning curve for Spring Batch concepts

**Recommendation for CUSTOMER-PROC:** Start with **Option 1 (Spring Service)** to keep Wave 3 simple. Can refactor to Option 2 after all programs are migrated.

---

## Data Models

### Customer Entity (Shared with BATCH-RUNNER, ACCOUNT-MGR)

```java
package com.lbg.legacy.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Entity
@Table(name = "customers")
public class Customer {
    
    @Id
    @Column(name = "customer_id")
    private Long customerId;           // CUST-ID PIC 9(8)
    
    @Column(name = "customer_name", length = 40)
    private String customerName;        // CUST-NAME PIC X(40)
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 1)
    private CustomerStatus status;      // CUST-STATUS PIC X (A/I/C)
    
    @Column(name = "balance", precision = 11, scale = 2)
    private BigDecimal balance;         // CUST-BALANCE PIC S9(9)V99
    
    @Column(name = "open_date")
    private LocalDate openDate;         // CUST-OPEN-DATE PIC 9(8)
    
    public enum CustomerStatus {
        ACTIVE('A'),
        INACTIVE('I'),
        CLOSED('C');
        
        private final char code;
        CustomerStatus(char code) {
            this.code = code;
        }
    }
}
```

### Repository Interface
```java
package com.lbg.legacy.customer.repository;

import com.lbg.legacy.model.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    
    /**
     * Find all customers
     * Replaces: PERFORM UNTIL WS-EOF when reading CUSTOMER-FILE
     */
    List<Customer> findAll();
    
    /**
     * Find active customers only
     * Useful for filtering in extended version
     */
    List<Customer> findByStatus(Customer.CustomerStatus status);
}
```

---

## Service Layer Implementation

### CustomerProcessingService (Option 1: Recommended)

```java
package com.lbg.legacy.customer.service;

import com.lbg.legacy.account.service.AccountManagementService;
import com.lbg.legacy.customer.repository.CustomerRepository;
import com.lbg.legacy.model.Customer;
import com.lbg.legacy.model.CustomerRecord;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Replaces COBOL CUSTOMER-PROC program
 * Source: CUSTOMER-PROC.cbl (57 lines, simple record iterator)
 * 
 * Purpose: Batch processor that iterates through all customer records
 * and invokes ACCOUNT-MGR for account management operations
 * 
 * COBOL Structure:
 *   FILE-CONTROL: CUSTOMER-FILE, AUDIT-FILE (both SEQUENTIAL)
 *   WORKING-STORAGE: WS-EOF-FLAG, WS-RECORDS-READ, WS-RECORDS-WRITTEN
 *   Called by: BATCH-RUNNER
 *   Calls: ACCOUNT-MGR
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CustomerProcessingService {
    
    private final CustomerRepository customerRepository;
    private final AccountManagementService accountManagementService;
    
    // Counters (replaces WS-RECORDS-READ, WS-RECORDS-WRITTEN)
    private int recordsRead = 0;
    private int recordsWritten = 0;
    private int recordsProcessed = 0;
    private int recordsErrored = 0;
    
    /**
     * Main entry point - replaces COBOL 0000-MAIN paragraph
     * 
     * Called from: BATCH-RUNNER (via CustomerProcessingService)
     * 
     * COBOL Flow:
     *   0000-MAIN.
     *       PERFORM 1000-OPEN-FILES
     *       PERFORM 2000-PROCESS-CUSTOMERS UNTIL WS-EOF
     *       PERFORM 9000-CLOSE-FILES
     *       STOP RUN.
     * 
     * Java Equivalent:
     *   - "OPEN FILES" = establish database connection (@Transactional)
     *   - "PERFORM UNTIL WS-EOF" = iterate through all customers
     *   - "CLOSE FILES" = transaction commit/rollback (Spring managed)
     */
    @Transactional
    public void processAllCustomers() {
        log.info("=== CUSTOMER-PROC: Starting batch processing ===");
        
        try {
            // PERFORM 1000-OPEN-FILES (managed by Spring transaction)
            openResources();
            
            // Replaces: PERFORM 2000-PROCESS-CUSTOMERS UNTIL WS-EOF
            // Equivalent: "OPEN INPUT CUSTOMER-FILE"
            List<Customer> customers = customerRepository.findAll();
            log.info("Read {} customer records from database", customers.size());
            recordsRead = customers.size();
            
            // Main loop - PERFORM 2000-PROCESS-CUSTOMERS (implicit)
            for (Customer customer : customers) {
                processCustomer(customer);
            }
            
            // PERFORM 9000-CLOSE-FILES (managed by Spring transaction commit)
            closeResources();
            
            // Log final statistics
            log.info("=== CUSTOMER-PROC: Batch processing complete ===");
            log.info("Records Read: {}, Processed: {}, Errors: {}",
                recordsRead, recordsProcessed, recordsErrored);
            
        } catch (Exception e) {
            log.error("CUSTOMER-PROC: Fatal error during processing: {}", 
                e.getMessage(), e);
            recordsErrored++;
            throw e;  // Spring transaction will rollback
        }
    }
    
    /**
     * Replaces: 1000-OPEN-FILES paragraph
     * 
     * COBOL:
     *   1000-OPEN-FILES.
     *       OPEN INPUT CUSTOMER-FILE
     *       OPEN OUTPUT AUDIT-FILE
     *       PERFORM 1100-READ-CUSTOMER.
     */
    private void openResources() {
        log.debug("Opening resources (database connection)");
        // Spring @Transactional handles opening database transaction
        recordsRead = 0;
        recordsProcessed = 0;
        recordsErrored = 0;
    }
    
    /**
     * Replaces: 2000-PROCESS-CUSTOMERS paragraph
     * 
     * COBOL:
     *   2000-PROCESS-CUSTOMERS.
     *       CALL 'ACCOUNT-MGR' USING CUSTOMER-REC
     *       PERFORM 1100-READ-CUSTOMER.
     * 
     * Notes:
     *   - CUSTOMER-REC is passed implicitly (COPY in FILE SECTION)
     *   - ACCOUNT-MGR receives it as LS-CUSTOMER-REC
     *   - 1100-READ-CUSTOMER happens at top of loop (PERFORM UNTIL already read)
     */
    private void processCustomer(Customer customer) {
        try {
            log.debug("Processing customer: {} ({})", 
                customer.getCustomerId(), customer.getCustomerName());
            
            // CALL 'ACCOUNT-MGR' USING CUSTOMER-REC
            // Convert JPA Customer entity to DTO for service layer
            CustomerRecord customerRecord = convertToDto(customer);
            
            int returnCode = accountManagementService.processCustomerAccount(customerRecord);
            
            if (returnCode == 0) {
                recordsProcessed++;
                log.debug("Customer {} processed successfully", customer.getCustomerId());
            } else {
                recordsErrored++;
                log.warn("Customer {} processing failed with code {}", 
                    customer.getCustomerId(), returnCode);
            }
        } catch (Exception e) {
            recordsErrored++;
            log.error("Error processing customer {}: {}", 
                customer.getCustomerId(), e.getMessage());
            throw e;  // Will be caught by @Transactional wrapper
        }
    }
    
    /**
     * Convert JPA Customer entity to CustomerRecord DTO
     * Needed because AccountManagementService expects CustomerRecord DTO
     */
    private CustomerRecord convertToDto(Customer customer) {
        CustomerRecord dto = new CustomerRecord();
        dto.setCustomerId(customer.getCustomerId());
        dto.setCustomerName(customer.getCustomerName());
        dto.setStatus(customer.getStatus());
        dto.setBalance(customer.getBalance());
        dto.setOpenDate(customer.getOpenDate());
        return dto;
    }
    
    /**
     * Replaces: 9000-CLOSE-FILES paragraph
     * 
     * COBOL:
     *   9000-CLOSE-FILES.
     *       CLOSE CUSTOMER-FILE
     *       CLOSE AUDIT-FILE.
     */
    private void closeResources() {
        log.debug("Closing resources (transaction commit)");
        // Spring @Transactional handles closing/committing database transaction
    }
}
```

---

## Paragraph Mapping

| COBOL Paragraph | Java Method | Purpose | Lines |
|---|---|---|---|
| 0000-MAIN | `processAllCustomers()` | Entry point, main control flow | 34-39 |
| 1000-OPEN-FILES | `openResources()` | File/resource initialization | 41-44 |
| 1100-READ-CUSTOMER | Implicit in loop | Sequential file read | 46-49 |
| 2000-PROCESS-CUSTOMERS | `processCustomer(Customer)` | Main processing loop | 51-53 |
| 9000-CLOSE-FILES | `closeResources()` | Cleanup/closure | 55-57 |

---

## Data Flow Diagram

```
BATCH-RUNNER
    │
    └─→ CustomerProcessingService.processAllCustomers()
            │
            ├─→ 1. openResources()
            │   └─ Spring @Transactional starts transaction
            │
            ├─→ 2. customerRepository.findAll()
            │   └─ Equivalent: "OPEN INPUT CUSTOMER-FILE; READ CUSTOMER-FILE"
            │
            ├─→ 3. FOR EACH customer:
            │   │
            │   └─→ processCustomer(customer)
            │       │
            │       └─→ AccountManagementService.processCustomerAccount()
            │           │
            │           ├─→ 1. validateAndFindAccount()
            │           │   └─ Lookup in ACCOUNT-FILE
            │           │
            │           ├─→ 2. updateAccountBasedOnCustomerStatus()
            │           │   └─ Update account (A/I/C)
            │           │
            │           └─→ 3. processPaymentForAccount()
            │               └─ Call PaymentHandlerService
            │
            ├─→ 4. closeResources()
            │   └─ Spring @Transactional commits/rollbacks
            │
            └─→ 5. AUDIT-FILE writing
                └─ Implement via logging or separate audit service

BATCH-RUNNER (continued)
    │
    ├─→ 1100-READ-NEXT-RECORD (priming read for next call)
    └─→ Loop back to CUSTOMER-PROC if more callers
```

---

## Key Characteristics

### ✅ Why CUSTOMER-PROC is LOW Risk for Migration

1. **Simplest Program** (57 lines)
   - Only 5 paragraphs
   - No complex logic
   - No GOTO statements
   - No COMP-3 fields

2. **Clear Responsibility**
   - Single responsibility: iterate and delegate
   - Acts as pure orchestrator
   - No business logic of its own

3. **No Data Transformations**
   - Simply passes CUSTOMER-REC to ACCOUNT-MGR
   - No field modifications
   - No complex calculations

4. **Minimal File I/O**
   - Two simple sequential files
   - Standard COBOL READ pattern
   - Easy to replace with Spring Data queries

### ⚠️ Migration Concerns (Minimal)

| Concern | Impact | Mitigation |
|---------|--------|-----------|
| ACCOUNT-MGR must be migrated first | MEDIUM | Part of Wave 3 ordering; ACCOUNT-MGR is Wave 2 |
| Reader/processor pattern unfamiliar | LOW | Simple for loop; or use Spring Batch if preferred |
| AUDIT-FILE output | LOW | Can use logging framework or create AuditLog entity |
| Implicit data passing to ACCOUNT-MGR | MEDIUM | Use explicit DTOs (CustomerRecord) |

---

## Testing Strategy

### Unit Tests (7 test cases)

#### Test 1: Process Single Active Customer
```java
@Test
void shouldProcessActiveCustomer() {
    // Given
    Customer active = createActiveCustomer();
    when(customerRepository.findAll()).thenReturn(List.of(active));
    
    // When
    service.processAllCustomers();
    
    // Then
    verify(accountManagementService).processCustomerAccount(any());
    assertThat(service.getRecordsProcessed()).isEqualTo(1);
}
```

#### Test 2: Process Multiple Customers (10)
```java
@Test
void shouldProcessMultipleCustomers() {
    // Given
    List<Customer> customers = createCustomers(10);
    when(customerRepository.findAll()).thenReturn(customers);
    
    // When
    service.processAllCustomers();
    
    // Then
    assertThat(service.getRecordsProcessed()).isEqualTo(10);
    verify(accountManagementService, times(10))
        .processCustomerAccount(any());
}
```

#### Test 3: Handle Processing Errors (Skip failed, continue)
```java
@Test
void shouldContinueProcessingOnError() {
    // Given
    List<Customer> customers = createCustomers(5);
    when(customerRepository.findAll()).thenReturn(customers);
    when(accountManagementService.processCustomerAccount(any()))
        .thenReturn(0)        // First ok
        .thenReturn(99)       // Second fails
        .thenReturn(0)        // Third ok
        .thenReturn(0, 0);    // Rest ok
    
    // When
    service.processAllCustomers();
    
    // Then
    assertThat(service.getRecordsErrored()).isEqualTo(1);
    assertThat(service.getRecordsProcessed()).isEqualTo(4);
}
```

#### Test 4: Handle Empty Customer File
```java
@Test
void shouldHandleEmptyCustomerFile() {
    // Given
    when(customerRepository.findAll()).thenReturn(Collections.emptyList());
    
    // When
    service.processAllCustomers();
    
    // Then
    assertThat(service.getRecordsRead()).isEqualTo(0);
    assertThat(service.getRecordsProcessed()).isEqualTo(0);
    verify(accountManagementService, never()).processCustomerAccount(any());
}
```

#### Test 5: DTO Conversion Correctness
```java
@Test
void shouldConvertCustomerToDtoCorrectly() {
    // Given
    Customer customer = new Customer();
    customer.setCustomerId(12345678L);
    customer.setCustomerName("JOHN DOE                                ");
    customer.setStatus(Customer.CustomerStatus.ACTIVE);
    customer.setBalance(new BigDecimal("1500.00"));
    customer.setOpenDate(LocalDate.of(2020, 1, 1));
    
    // When
    service.processAllCustomers();
    
    // Then (via ArgumentCaptor)
    ArgumentCaptor<CustomerRecord> captor = 
        ArgumentCaptor.forClass(CustomerRecord.class);
    verify(accountManagementService)
        .processCustomerAccount(captor.capture());
    
    CustomerRecord dto = captor.getValue();
    assertThat(dto.getCustomerId()).isEqualTo(12345678L);
    assertThat(dto.getCustomerName()).isEqualTo("JOHN DOE");
    assertThat(dto.getStatus()).isEqualTo(ACTIVE);
}
```

#### Test 6: Transaction Rollback on Fatal Error
```java
@Test
void shouldRollbackTransactionOnFatalError() {
    // Given
    List<Customer> customers = createCustomers(10);
    when(customerRepository.findAll()).thenReturn(customers);
    when(accountManagementService.processCustomerAccount(any()))
        .thenThrow(new RuntimeException("Database error"));
    
    // When
    assertThatThrownBy(() -> service.processAllCustomers())
        .isInstanceOf(RuntimeException.class)
        .hasMessage("Database error");
    
    // Then - No customers should be updated
    // (Verified via Spring @Transactional rollback)
}
```

#### Test 7: Logging and Metrics
```java
@Test
void shouldLogProcessingStatistics() {
    // Given
    List<Customer> customers = createCustomers(5);
    when(customerRepository.findAll()).thenReturn(customers);
    
    // When
    service.processAllCustomers();
    
    // Then (via logger)
    assertLogContains("=== CUSTOMER-PROC: Starting batch processing ===");
    assertLogContains("Read 5 customer records");
    assertLogContains("Records Read: 5, Processed: 5, Errors: 0");
}
```

### Integration Tests (2 test scenarios)

#### Integration Test 1: Full Flow
```java
@SpringBootTest
class CustomerProcessingIntegrationTest {
    
    @Test
    void shouldProcessCustomersEnd2End() {
        // Given - Database has customers
        customerRepository.saveAll(createTestCustomers(3));
        accountRepository.saveAll(createTestAccounts(3));
        
        // When
        customerProcessingService.processAllCustomers();
        
        // Then - Accounts should be updated
        List<Account> updatedAccounts = accountRepository.findAll();
        assertThat(updatedAccounts).hasSize(3);
        // Verify status updates, balance changes, etc.
    }
}
```

#### Integration Test 2: Transaction Isolation
```java
@Test
void shouldMaintainTransactionIsolation() {
    // Verify that:
    // - All-or-nothing semantics (atomicity)
    // - No dirty reads from concurrent processes
    // - Proper pessimistic locking for account updates
}
```

---

## Database Schema

### Customers Table
```sql
CREATE TABLE customers (
    customer_id     BIGINT PRIMARY KEY,
    customer_name   VARCHAR(40) NOT NULL,
    status          CHAR(1) NOT NULL CHECK (status IN ('A', 'I', 'C')),
    balance         NUMERIC(11,2) NOT NULL,
    open_date       DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customer_status ON customers(status);
```

### Audit Table (Optional)
```sql
CREATE TABLE audit_log (
    audit_id        BIGSERIAL PRIMARY KEY,
    customer_id     BIGINT NOT NULL,
    action          VARCHAR(100),
    details         TEXT,
    processed_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

---

## Dependencies & Prerequisites

### Must Be Migrated Before CUSTOMER-PROC
- **ACCOUNT-MGR** (Wave 2) ← Called by CUSTOMER-PROC
- **PAYMENT-HANDLER** (via ACCOUNT-MGR) ← Called by ACCOUNT-MGR

### Depends On
- **CUSTOMER-RECORD** copybook → Customer JPA entity (shared)
- **CUSTOMER-FILE** database table
- **AccountManagementService** (ACCOUNT-MGR migration)

### Migration Wave
- **Wave 3** (after ACCOUNT-MGR Wave 2 completion)
- Effort: 10 person-days
- (Can be parallelized with BATCH-RUNNER Wave 4 prep)

---

## Migration Checklist

### Phase 1: Data Model
- [x] Create Customer JPA entity
- [x] Create CustomerRecord DTO
- [x] Create CustomerRepository interface
- [x] Design database schema (customers table)
- [ ] Create schema migration (V1__*.sql)

### Phase 2: Service Layer
- [ ] Create CustomerProcessingService
- [ ] Implement processAllCustomers()
- [ ] Implement openResources()
- [ ] Implement processCustomer()
- [ ] Implement closeResources()
- [ ] Add comprehensive logging
- [ ] Add counters/metrics

### Phase 3: Testing
- [ ] Unit tests (7 test cases)
- [ ] Integration tests (2 test scenarios)
- [ ] Test with H2 in-memory database
- [ ] Test with real PostgreSQL if applicable

### Phase 4: Documentation
- [ ] Document COBOL → Java mappings
- [ ] Document return codes
- [ ] Document error handling
- [ ] Document testing approach

### Phase 5: Integration & Deployment
- [ ] Integrate with BATCH-RUNNER
- [ ] Ensure ACCOUNT-MGR is available (Wave 2)
- [ ] Test end-to-end flow
- [ ] Load test (multiple customers)
- [ ] Deployment to staging environment
- [ ] Collect metrics vs COBOL baseline

---

## Risk Assessment

### Risk Matrix

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|-----------|
| **ACCOUNT-MGR not ready** | HIGH | MEDIUM | Schedule: ACCOUNT-MGR Wave 2, CUSTOMER-PROC Wave 3 |
| **File I/O performance** | MEDIUM | LOW | Use Spring Data; add indexes on customer_id |
| **Large customer file** | MEDIUM | LOW | Implement Spring Batch chunking if needed |
| **Data schema mismatch** | MEDIUM | MEDIUM | Thorough integration testing |
| **Legacy audit requirements** | LOW | LOW | Can implement AuditLog entity if needed |

**Overall Risk:** LOW (simplest program, no COMP-3, no complex logic)

---

## Performance Considerations

### Benchmarks (Expected)

| Metric | COBOL | Java (Spring) | Notes |
|--------|-------|---------------|-------|
| Process 10K customers | ~5 minutes | ~3-5 minutes | Spring Data optimizations |
| Memory usage | ~10 MB | ~100 MB | JVM overhead |
| CPU % | 40% | 30% | Optimized Spring Data queries |

### Optimization Strategies

1. **Batch Processing**
   - Default: Process customers one-by-one
   - Optimized: Use Spring Batch chunking (100 customers at a time)

2. **Connection Pooling**
   - HikariCP default pool size = 10 connections
   - Tune based on concurrency needs

3. **Caching**
   - Cache account types/statuses if frequent lookups
   - Consider L2 Hibernate cache for static data

4. **SQL Optimization**
   - Index on `customer_id` in accounts table
   - Eager vs lazy loading for relationships

---

## Success Criteria

### Functional Correctness
- ✅ All customers processed in correct order
- ✅ ACCOUNT-MGR called exactly once per customer
- ✅ Return codes properly handled
- ✅ Transactions committed/rolled back correctly

### Data Integrity
- ✅ Customer records unchanged
- ✅ Account updates correct based on status
- ✅ Payment processing traced fully
- ✅ Audit trail complete (if logging enabled)

### Performance
- ✅ Process 10K customers in < 5 minutes
- ✅ Memory usage < 200 MB
- ✅ No database connection leaks
- ✅ Proper transaction isolation

### Quality
- ✅ Unit test coverage > 90%
- ✅ Integration tests passing
- ✅ Code reviewed by team
- ✅ Documented COBOL→Java mappings

---

## References

- **COBOL Source:** [sample-cobol/CUSTOMER-PROC.cbl](../../../sample-cobol/CUSTOMER-PROC.cbl)
- **Copybook:** [sample-cobol/copybooks/CUSTOMER-RECORD.cpy](../../../sample-cobol/copybooks/CUSTOMER-RECORD.cpy)
- **ACCOUNT-MGR Blueprint:** [ACCOUNT-MGR-blueprint.md](./ACCOUNT-MGR-blueprint.md)
- **Type Mappings:** [.claude/skills/java-mapping/TYPE-MAPPING.md](../../../.claude/skills/java-mapping/TYPE-MAPPING.md)
- **Pattern Mappings:** [.claude/skills/java-mapping/PATTERN-MAPPING.md](../../../.claude/skills/java-mapping/PATTERN-MAPPING.md)
- **Integration Strategy:** [INTEGRATION-STRATEGY.md](./INTEGRATION-STRATEGY.md)

---

**Blueprint Version:** 1.0  
**Created:** March 2, 2026  
**Status:** COMPLETE
