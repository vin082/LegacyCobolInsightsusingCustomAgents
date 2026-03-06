# Migration Blueprint: ACCOUNT-MGR → AccountManagementService

## Program Summary
- **Complexity:** MEDIUM (115 lines)
- **Author:** M.JONES (1989-07-22)
- **Paragraphs:** 10
- **External calls:** 1 (PAYMENT-HANDLER)
- **Copybooks:** 3 (CUSTOMER-RECORD, ACCOUNT-RECORD, PAYMENT-RECORD)
- **Type:** Business Logic Service
- **Risk Flags:** Contains COMP-3 fields, 88-level conditions, indexed file I/O

## Purpose
Core business logic for account management. Validates customers, updates account status (activate/deactivate/close), and processes payments. Acts as coordinator between CUSTOMER-PROC and PAYMENT-HANDLER.

## Recommended Java Architecture

### Architecture Type: Spring Service
**Package:** `com.lbg.legacy.account.service`  
**Main Class:** `AccountManagementService`  
**Type:** `@Service` (transactional coordinator)

## Domain Models

### Account Record (from ACCOUNT-RECORD copybook)
```java
package com.lbg.legacy.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Entity
@Table(name = "accounts")
public class Account {
    
    @Id
    @Column(name = "account_id")
    private Long accountId;              // ACCT-ID PIC 9(10)
    
    @Column(name = "customer_id", nullable = false)
    private Long customerId;             // ACCT-CUST-ID PIC 9(8)
    
    @Enumerated(EnumType.STRING)
    @Column(name = "account_type", length = 3, nullable = false)
    private AccountType accountType;     // ACCT-TYPE PIC X(3)
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 1, nullable = false)
    private AccountStatus status;        // ACCT-STATUS PIC X
    
    // COMP-3 fields → BigDecimal (critical for financial accuracy)
    @Column(name = "balance", precision = 13, scale = 2, nullable = false)
    private BigDecimal balance;          // ACCT-BALANCE S9(11)V99 COMP-3
    
    @Column(name = "credit_limit", precision = 11, scale = 2)
    private BigDecimal creditLimit;      // ACCT-LIMIT S9(9)V99 COMP-3
    
    @Column(name = "open_date")
    private LocalDate openDate;          // ACCT-OPEN-DATE 9(8)
    
    @Version
    @Column(name = "version")
    private Long version;  // Optimistic locking for concurrent updates
    
    // 88-level conditions → Enum
    public enum AccountType {
        CURRENT("CUR"),
        SAVINGS("SAV"),
        LOAN("LON");
        
        private final String code;
        
        AccountType(String code) {
            this.code = code;
        }
        
        public static AccountType fromCode(String code) {
            for (AccountType type : values()) {
                if (type.code.equals(code)) return type;
            }
            throw new IllegalArgumentException("Unknown account type: " + code);
        }
    }
    
    // 88-level conditions → Enum
    public enum AccountStatus {
        ACTIVE('A'),
        INACTIVE('I'),
        CLOSED('C');
        
        private final char code;
        
        AccountStatus(char code) {
            this.code = code;
        }
        
        public static AccountStatus fromCode(char code) {
            for (AccountStatus status : values()) {
                if (status.code == code) return status;
            }
            throw new IllegalArgumentException("Unknown account status: " + code);
        }
    }
}
```

### Customer Record (shared with CUSTOMER-PROC)
```java
package com.lbg.legacy.model;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class CustomerRecord {
    private Long customerId;           // CUST-ID PIC 9(8)
    private String customerName;        // CUST-NAME PIC X(40)
    private CustomerStatus status;      // CUST-STATUS PIC X
    private BigDecimal balance;         // CUST-BALANCE S9(9)V99
    private LocalDate openDate;         // CUST-OPEN-DATE 9(8)
    
    public enum CustomerStatus {
        ACTIVE('A'),
        INACTIVE('I'),
        CLOSED('C');
        
        private final char code;
        
        CustomerStatus(char code) {
            this.code = code;
        }
        
        public static CustomerStatus fromCode(char code) {
            for (CustomerStatus status : values()) {
                if (status.code == code) return status;
            }
            throw new IllegalArgumentException("Unknown status: " + code);
        }
    }
}
```

## Service Layer Implementation

### Main Service (replaces ACCOUNT-MGR program)
```java
package com.lbg.legacy.account.service;

import com.lbg.legacy.account.repository.AccountRepository;
import com.lbg.legacy.model.Account;
import com.lbg.legacy.model.CustomerRecord;
import com.lbg.legacy.model.PaymentRequest;
import com.lbg.legacy.payment.service.PaymentHandlerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AccountManagementService {
    
    private final AccountRepository accountRepository;
    private final PaymentHandlerService paymentHandlerService;
    private final AccountValidator accountValidator;
    
    /**
     * Main entry point - replaces COBOL 0000-MAIN paragraph
     * Called from CustomerProcessingService (CUSTOMER-PROC)
     * 
     * @param customerRecord customer data from calling program
     * @return return code (0 = success, non-zero = error)
     */
    @Transactional
    public int processCustomerAccount(CustomerRecord customerRecord) {
        try {
            // Replaces: PERFORM 1000-OPEN-FILES (managed by Spring transaction)
            log.info("Processing account for customer: {}", customerRecord.getCustomerId());
            
            // Replaces: PERFORM 2000-VALIDATE-CUSTOMER
            Optional<Account> accountOpt = validateAndFindAccount(customerRecord);
            
            // Replaces: IF WS-ACCOUNT-FOUND
            if (accountOpt.isEmpty()) {
                // Replaces: PERFORM 8000-HANDLE-MISSING-ACCOUNT
                return handleMissingAccount(customerRecord);
            }
            
            Account account = accountOpt.get();
            
            // Replaces: PERFORM 3000-UPDATE-ACCOUNT
            updateAccountBasedOnCustomerStatus(account, customerRecord);
            
            // Replaces: PERFORM 4000-PROCESS-PAYMENT (conditional)
            if (shouldProcessPayment(account)) {
                processPaymentForAccount(account);
            }
            
            // Replaces: PERFORM 9000-CLOSE-FILES (managed by Spring transaction commit)
            return 0;  // Success
            
        } catch (Exception e) {
            log.error("Error processing customer account: {}", e.getMessage(), e);
            throw e;  // Rollback transaction
        }
    }
    
    /**
     * Replaces: 2000-VALIDATE-CUSTOMER paragraph
     * READ ACCOUNT-FILE with key from customer record
     */
    private Optional<Account> validateAndFindAccount(CustomerRecord customer) {
        log.debug("Validating customer and retrieving account: {}", customer.getCustomerId());
        
        // Replaces: READ ACCOUNT-FILE KEY IS ACCT-ID (indexed file read)
        Optional<Account> account = accountRepository.findByCustomerId(customer.getCustomerId());
        
        if (account.isPresent()) {
            log.debug("Account found: {}", account.get().getAccountId());
            // Replaces: SET WS-ACCOUNT-FOUND TO TRUE (88-level condition)
        } else {
            log.warn("Account not found for customer: {}", customer.getCustomerId());
            // Replaces: WS-FILE-NOTFND condition (88-level)
        }
        
        return account;
    }
    
    /**
     * Replaces: 3000-UPDATE-ACCOUNT paragraph
     * Routes to sub-paragraphs based on customer status
     */
    private void updateAccountBasedOnCustomerStatus(Account account, CustomerRecord customer) {
        // Replaces: EVALUATE TRUE with 88-level conditions
        switch (customer.getStatus()) {
            case ACTIVE:
                // Replaces: PERFORM 3100-ACTIVATE-ACCOUNT
                activateAccount(account);
                break;
            case INACTIVE:
                // Replaces: PERFORM 3200-DEACTIVATE-ACCOUNT
                deactivateAccount(account);
                break;
            case CLOSED:
                // Replaces: PERFORM 3300-CLOSE-ACCOUNT
                closeAccount(account);
                break;
        }
    }
    
    /**
     * Replaces: 3100-ACTIVATE-ACCOUNT paragraph
     * MOVE 'A' TO ACCT-STATUS
     * REWRITE ACCOUNT-REC
     */
    private void activateAccount(Account account) {
        log.info("Activating account: {}", account.getAccountId());
        account.setStatus(Account.AccountStatus.ACTIVE);
        accountRepository.save(account);  // Replaces REWRITE
        log.debug("Account activated successfully");
    }
    
    /**
     * Replaces: 3200-DEACTIVATE-ACCOUNT paragraph
     * MOVE 'I' TO ACCT-STATUS
     * REWRITE ACCOUNT-REC
     */
    private void deactivateAccount(Account account) {
        log.info("Deactivating account: {}", account.getAccountId());
        account.setStatus(Account.AccountStatus.INACTIVE);
        accountRepository.save(account);  // Replaces REWRITE
        log.debug("Account deactivated successfully");
    }
    
    /**
     * Replaces: 3300-CLOSE-ACCOUNT paragraph
     * MOVE 'C' TO ACCT-STATUS
     * MOVE ZERO TO ACCT-BALANCE
     * REWRITE ACCOUNT-REC
     */
    private void closeAccount(Account account) {
        log.info("Closing account: {}", account.getAccountId());
        account.setStatus(Account.AccountStatus.CLOSED);
        account.setBalance(java.math.BigDecimal.ZERO);
        accountRepository.save(account);  // Replaces REWRITE
        log.debug("Account closed successfully");
    }
    
    /**
     * Business rule: only process payments for active accounts
     */
    private boolean shouldProcessPayment(Account account) {
        return account.getStatus() == Account.AccountStatus.ACTIVE;
    }
    
    /**
     * Replaces: 4000-PROCESS-PAYMENT paragraph
     * Builds WS-PAYMENT-REQUEST and calls PAYMENT-HANDLER
     */
    private void processPaymentForAccount(Account account) {
        log.debug("Processing payment for account: {}", account.getAccountId());
        
        // Replaces: Build WS-PAYMENT-REQUEST working storage structure
        PaymentRequest paymentRequest = buildPaymentRequest(account);
        
        // Replaces: CALL 'PAYMENT-HANDLER' USING WS-PAYMENT-REQUEST, WS-RETURN-CODE
        int returnCode = paymentHandlerService.processPayment(paymentRequest);
        
        if (returnCode != 0) {
            log.error("Payment processing failed with return code: {}", returnCode);
            // Replaces: PERFORM 8000-HANDLE-MISSING-ACCOUNT (error handling)
            throw new PaymentProcessingException("Payment handler returned error: " + returnCode);
        }
        
        log.debug("Payment processed successfully");
    }
    
    /**
     * Builds payment request from account data
     * Replaces working storage field population in COBOL
     */
    private PaymentRequest buildPaymentRequest(Account account) {
        PaymentRequest request = new PaymentRequest();
        request.setCustomerId(account.getCustomerId());
        request.setAccountId(account.getAccountId());
        request.setAmount(account.getBalance());
        request.setType(PaymentRequest.PaymentType.REGULAR);
        request.setStatus(PaymentRequest.PaymentStatus.PENDING);
        return request;
    }
    
    /**
     * Replaces: 8000-HANDLE-MISSING-ACCOUNT paragraph
     * Error handling for when account is not found
     */
    private int handleMissingAccount(CustomerRecord customer) {
        log.error("Account not found for customer: {}", customer.getCustomerId());
        // In COBOL, this would display an error message
        // In Java, we can throw an exception or return error code
        return 404;  // Not found error code
    }
}
```

### Repository Interface (replaces ACCOUNT-FILE indexed file)
```java
package com.lbg.legacy.account.repository;

import com.lbg.legacy.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;

@Repository
public interface AccountRepository extends JpaRepository<Account, Long> {
    
    /**
     * Replaces: READ ACCOUNT-FILE KEY IS ACCT-CUST-ID
     * Dynamic access mode → findBy query with optional result
     */
    Optional<Account> findByCustomerId(Long customerId);
    
    /**
     * Replaces: Indexed file access with alternate key
     */
    List<Account> findByStatus(Account.AccountStatus status);
    
    /**
     * Pessimistic locking for REWRITE operations
     * Prevents concurrent modification issues
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<Account> findByAccountIdForUpdate(Long accountId);
}
```

### Custom Exception
```java
package com.lbg.legacy.account.exception;

public class PaymentProcessingException extends RuntimeException {
    public PaymentProcessingException(String message) {
        super(message);
    }
}
```

## Data Mapping

### Working Storage Variables

| COBOL Item | Java Type | Implementation | Notes |
|---|---|---|---|
| WS-FILE-STATUS | String | Exception handling | Spring Data manages file status |
| WS-RETURN-CODE | int | Method return value | 0 = success |
| WS-ACCT-FOUND | boolean | `Optional<Account>` | `isPresent()` replaces 88-level |
| WS-PAYMENT-REQUEST | PaymentRequest | DTO object | Built in `buildPaymentRequest()` |

### Linkage Section

| COBOL Item | Java Type | Implementation | Notes |
|---|---|---|---|
| LS-CUSTOMER-REC | CustomerRecord | Method parameter | Passed from CUSTOMER-PROC |

### Condition Names (88-level conversions)

| COBOL Condition | Java Implementation | Notes |
|---|---|---|
| WS-FILE-OK VALUE "00" | No exception thrown | Spring Data exception handling |
| WS-FILE-EOF VALUE "10" | `Optional.empty()` | Empty optional for not found |
| WS-FILE-NOTFND VALUE "23" | `Optional.empty()` | Same as EOF in this context |
| WS-ACCOUNT-FOUND VALUE "Y" | `accountOpt.isPresent()` | Boolean check |
| ACCT-CURRENT VALUE "CUR" | `AccountType.CURRENT` | Enum value |
| ACCT-SAVINGS VALUE "SAV" | `AccountType.SAVINGS` | Enum value |
| ACCT-LOAN VALUE "LON" | `AccountType.LOAN` | Enum value |
| ACCT-ACTIVE VALUE "A" | `AccountStatus.ACTIVE` | Enum value |
| ACCT-INACTIVE VALUE "I" | `AccountStatus.INACTIVE` | Enum value |
| ACCT-CLOSED VALUE "C" | `AccountStatus.CLOSED` | Enum value |

## Method Mapping

| COBOL Paragraph | Java Method | Notes |
|---|---|---|
| 0000-MAIN | `processCustomerAccount()` | Entry point |
| 1000-OPEN-FILES | `@Transactional` annotation | Spring manages |
| 2000-VALIDATE-CUSTOMER | `validateAndFindAccount()` | Returns Optional |
| 3000-UPDATE-ACCOUNT | `updateAccountBasedOnCustomerStatus()` | Routes to sub-methods |
| 3100-ACTIVATE-ACCOUNT | `activateAccount()` | Private method |
| 3200-DEACTIVATE-ACCOUNT | `deactivateAccount()` | Private method |
| 3300-CLOSE-ACCOUNT | `closeAccount()` | Private method |
| 4000-PROCESS-PAYMENT | `processPaymentForAccount()` | Calls PaymentHandlerService |
| 8000-HANDLE-MISSING-ACCOUNT | `handleMissingAccount()` | Error handling |
| 9000-CLOSE-FILES | Transaction commit | Spring manages |

## Critical COMP-3 Handling

### COMP-3 (Packed Decimal) Migration Strategy

**COBOL:**
```cobol
05  ACCT-BALANCE        PIC S9(11)V99 COMP-3.
05  ACCT-LIMIT          PIC S9(9)V99 COMP-3.
```

**Java:**
```java
// ✅ CORRECT: Use BigDecimal for financial precision
@Column(name = "balance", precision = 13, scale = 2)
private BigDecimal balance;  // 11 digits + 2 decimal places

@Column(name = "credit_limit", precision = 11, scale = 2)
private BigDecimal creditLimit;  // 9 digits + 2 decimal places
```

**⚠️ CRITICAL:** Never use `double` or `float` for monetary values!

### COMP-3 Precision Mapping

| COBOL | Digits | Decimals | Java BigDecimal Precision | Java BigDecimal Scale |
|---|---|---|---|---|
| S9(11)V99 COMP-3 | 11 | 2 | 13 | 2 |
| S9(9)V99 COMP-3 | 9 | 2 | 11 | 2 |

### Database Schema (PostgreSQL)
```sql
CREATE TABLE accounts (
    account_id      BIGINT PRIMARY KEY,
    customer_id     BIGINT NOT NULL,
    account_type    VARCHAR(3) NOT NULL,
    status          CHAR(1) NOT NULL,
    balance         NUMERIC(13,2) NOT NULL,  -- S9(11)V99 COMP-3
    credit_limit    NUMERIC(11,2),           -- S9(9)V99 COMP-3
    open_date       DATE,
    version         BIGINT,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE INDEX idx_account_customer ON accounts(customer_id);
CREATE INDEX idx_account_status ON accounts(status);
```

## Risks and Mitigations

### Risk Assessment
**Overall Risk:** MEDIUM-HIGH

| Risk | Severity | Mitigation |
|---|---|---|
| **COMP-3 precision loss** | CRITICAL | Use BigDecimal; extensive financial calculation tests |
| **Indexed file locking** | HIGH | Implement optimistic/pessimistic locking in JPA |
| **88-level logic errors** | MEDIUM | Map all conditions to enums; comprehensive unit tests |
| **Transaction boundaries** | MEDIUM | Use `@Transactional` with proper isolation |
| **Concurrent updates** | HIGH | Use `@Version` for optimistic locking |

## Testing Strategy

### 1. Unit Tests
```java
package com.lbg.legacy.account.service;

import com.lbg.legacy.account.repository.AccountRepository;
import com.lbg.legacy.model.Account;
import com.lbg.legacy.model.CustomerRecord;
import com.lbg.legacy.payment.service.PaymentHandlerService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AccountManagementServiceTest {
    
    @Mock
    private AccountRepository accountRepository;
    
    @Mock
    private PaymentHandlerService paymentHandlerService;
    
    @InjectMocks
    private AccountManagementService service;
    
    @Test
    void shouldActivateAccountWhenCustomerIsActive() {
        // Given
        CustomerRecord customer = createActiveCustomer();
        Account account = createInactiveAccount();
        when(accountRepository.findByCustomerId(customer.getCustomerId()))
            .thenReturn(Optional.of(account));
        
        // When
        int result = service.processCustomerAccount(customer);
        
        // Then
        assertThat(result).isEqualTo(0);
        assertThat(account.getStatus()).isEqualTo(Account.AccountStatus.ACTIVE);
        verify(accountRepository, times(1)).save(account);
    }
    
    @Test
    void shouldCloseAccountAndZeroBalanceWhenCustomerIsClosed() {
        // Given
        CustomerRecord customer = createClosedCustomer();
        Account account = createActiveAccount();
        account.setBalance(new BigDecimal("1000.50"));
        when(accountRepository.findByCustomerId(customer.getCustomerId()))
            .thenReturn(Optional.of(account));
        
        // When
        service.processCustomerAccount(customer);
        
        // Then
        assertThat(account.getStatus()).isEqualTo(Account.AccountStatus.CLOSED);
        assertThat(account.getBalance()).isEqualByComparingTo(BigDecimal.ZERO);
    }
    
    @Test
    void shouldReturnErrorWhenAccountNotFound() {
        // Given
        CustomerRecord customer = createActiveCustomer();
        when(accountRepository.findByCustomerId(customer.getCustomerId()))
            .thenReturn(Optional.empty());
        
        // When
        int result = service.processCustomerAccount(customer);
        
        // Then
        assertThat(result).isEqualTo(404);
        verify(paymentHandlerService, never()).processPayment(any());
    }
    
    @Test
    void shouldProcessPaymentForActiveAccount() {
        // Given
        CustomerRecord customer = createActiveCustomer();
        Account account = createActiveAccount();
        when(accountRepository.findByCustomerId(customer.getCustomerId()))
            .thenReturn(Optional.of(account));
        when(paymentHandlerService.processPayment(any())).thenReturn(0);
        
        // When
        service.processCustomerAccount(customer);
        
        // Then
        verify(paymentHandlerService, times(1)).processPayment(any());
    }
    
    // Test helpers...
}
```

### 2. COMP-3 Precision Tests
```java
@Test
void shouldMaintainPrecisionForCOMP3Fields() {
    // Test: S9(11)V99 COMP-3 precision
    BigDecimal balance = new BigDecimal("99999999999.99");
    Account account = new Account();
    account.setBalance(balance);
    
    Account saved = accountRepository.save(account);
    Account retrieved = accountRepository.findById(saved.getAccountId()).get();
    
    assertThat(retrieved.getBalance())
        .isEqualByComparingTo(balance);  // Exact precision match
}
```

## Dependencies

### Maven Dependencies (pom.xml)
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
    </dependency>
</dependencies>
```

## Estimated Effort

| Activity | Effort | Notes |
|---|---|---|
| Domain models with COMP-3 | 1 day | Critical - BigDecimal mapping |
| Repository setup | 0.5 days | Spring Data JPA |
| Service implementation | 2 days | Main business logic |
| COMP-3 testing | 1 day | Financial precision validation |
| Integration with PAYMENT-HANDLER | 1 day | Service composition |
| Unit tests | 2 days | All paragraphs and 88-levels |
| Integration tests | 1.5 days | Database and transactions |
| Documentation | 0.5 days | JavaDoc |
| **Total** | **9.5 days** | ~2 weeks |

## Migration Sequence

1. **Phase 1: Model Setup** (Days 1-2)
   - Create Account entity with COMP-3 → BigDecimal
   - Set up enums for 88-level conditions
   - Database schema creation

2. **Phase 2: Repository** (Day 3)
   - Implement AccountRepository
   - Add custom queries
   - Test indexed file replacement

3. **Phase 3: Service Logic** (Days 4-5)
   - Implement main service methods
   - Map all paragraphs to methods
   - Handle 88-level conditions

4. **Phase 4: Integration** (Day 6)
   - Wire up PaymentHandlerService
   - Test call chain
   - Validate return codes

5. **Phase 5: Testing** (Days 7-8)
   - Unit tests for all methods
   - COMP-3 precision tests
   - Integration tests

6. **Phase 6: Documentation** (Day 9-10)
   - Complete JavaDoc
   - Deployment guide
   - Runbook

## Next Steps

1. Review COMP-3 migration strategy with DBA
2. Create database schema
3. Set up test data with financial precision requirements
4. Begin Phase 1 implementation
5. Coordinate with CUSTOMER-PROC and PAYMENT-HANDLER teams
