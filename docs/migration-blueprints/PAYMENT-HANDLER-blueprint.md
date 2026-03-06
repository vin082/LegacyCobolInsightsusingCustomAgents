# Migration Blueprint: PAYMENT-HANDLER → PaymentHandlerService

## Program Summary
- **Complexity:** MEDIUM (118 lines)
- **Author:** S.PATEL (1992-11-03)
- **Paragraphs:** 10
- **External calls:** None (leaf program)
- **Copybooks:** 1 (PAYMENT-RECORD)
- **Type:** Service/Transaction Processor
- **Risk Flags:** ⚠️ **CRITICAL: Contains GOTO statements**

## Purpose
Processes payment transactions and routes to appropriate handler based on payment type (REGULAR, REFUND, REVERSAL). Current implementation uses legacy GOTO for early exit, flagged for mandatory refactoring.

## Recommended Java Architecture

### Architecture Type: Spring Service
**Package:** `com.lbg.legacy.payment.service`  
**Main Class:** `PaymentHandlerService`  
**Type:** `@Service` (transactional business logic)

### Domain Model (from PAYMENT-RECORD)
```java
package com.lbg.legacy.model;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class PaymentRequest {
    private Long transactionId;        // PAY-TRANS-ID PIC 9(12)
    private Long customerId;           // PAY-CUST-ID PIC 9(8)
    private Long accountId;            // PAY-ACCT-ID PIC 9(10)
    private BigDecimal amount;         // PAY-AMOUNT S9(9)V99 COMP-3
    private PaymentType type;          // PAY-TYPE PIC X(10)
    private PaymentStatus status;      // PAY-STATUS PIC X(10)
    private LocalDateTime timestamp;   // PAY-TIMESTAMP PIC X(26)
    
    public enum PaymentType {
        REGULAR("REGULAR   "),
        REFUND("REFUND    "),
        REVERSAL("REVERSAL  ");
        
        private final String code;
        
        PaymentType(String code) {
            this.code = code;
        }
        
        public static PaymentType fromCode(String code) {
            for (PaymentType type : values()) {
                if (type.code.equals(code)) return type;
            }
            throw new IllegalArgumentException("Unknown payment type: " + code);
        }
    }
    
    public enum PaymentStatus {
        APPROVED("APPROVED  "),
        PENDING("PENDING   "),
        REVERSED("REVERSED  "),
        REJECTED("REJECTED  ");
        
        private final String code;
        
        PaymentStatus(String code) {
            this.code = code;
        }
        
        public String getCode() {
            return code;
        }
    }
}
```

## CRITICAL: GOTO Elimination Strategy

### Original COBOL Pattern Analysis

The `0000-MAIN` paragraph contains a GOTO statement that jumps to `9000-EXIT`:

```cobol
0000-MAIN.
    PERFORM 1000-OPEN-LOG
    PERFORM 2000-VALIDATE-PAYMENT
    
    IF WS-INVALID-PAYMENT
        MOVE 999 TO LS-RETURN-CODE
        GO TO 9000-EXIT           ← CRITICAL: Early exit GOTO
    END-IF
    
    EVALUATE PAY-TYPE
        WHEN PAY-REGULAR
            PERFORM 3000-PROCESS-REGULAR
        WHEN PAY-REFUND
            PERFORM 3100-PROCESS-REFUND
        WHEN PAY-REVERSAL
            PERFORM 3200-PROCESS-REVERSAL
    END-EVALUATE
    
    PERFORM 4000-LOG-TRANSACTION
    .
9000-EXIT.
    PERFORM 9000-CLOSE-LOG
    EXIT PROGRAM.
```

### Anti-Pattern Explanation
The GOTO jumps to `9000-EXIT` to skip processing when validation fails. This creates:
- **Non-linear control flow** (hard to follow)
- **Hidden state** (execution path unclear)
- **Testing complexity** (difficult to mock/test paths)

### Migration Approach: Three Patterns

## Pattern 1: Guard Clauses (RECOMMENDED)

### Java Implementation - Early Return Pattern
```java
package com.lbg.legacy.payment.service;

import com.lbg.legacy.model.PaymentRequest;
import com.lbg.legacy.payment.repository.PaymentLogRepository;
import com.lbg.legacy.payment.validator.PaymentValidator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentHandlerService {
    
    private final PaymentValidator paymentValidator;
    private final PaymentLogRepository paymentLogRepository;
    
    /**
     * Replaces COBOL 0000-MAIN paragraph with GOTO eliminated.
     * Uses guard clause pattern for early validation failure.
     * 
     * @param paymentRequest the payment to process (LS-PAYMENT-REQUEST)
     * @return return code (0 = success, 999 = validation failure)
     */
    @Transactional
    public int processPayment(PaymentRequest paymentRequest) {
        // Replaces: PERFORM 1000-OPEN-LOG (handled by Spring transaction)
        log.info("Processing payment transaction: {}", paymentRequest.getTransactionId());
        
        // Replaces: PERFORM 2000-VALIDATE-PAYMENT
        // Guard clause eliminates GOTO - early return on validation failure
        if (!paymentValidator.isValid(paymentRequest)) {
            log.error("Payment validation failed: {}", paymentRequest.getTransactionId());
            return 999;  // Replaces: GO TO 9000-EXIT with MOVE 999 TO LS-RETURN-CODE
        }
        
        // Replaces: EVALUATE PAY-TYPE
        switch (paymentRequest.getType()) {
            case REGULAR:
                processRegularPayment(paymentRequest);   // 3000-PROCESS-REGULAR
                break;
            case REFUND:
                processRefundPayment(paymentRequest);    // 3100-PROCESS-REFUND
                break;
            case REVERSAL:
                processReversalPayment(paymentRequest);  // 3200-PROCESS-REVERSAL
                break;
        }
        
        // Replaces: PERFORM 4000-LOG-TRANSACTION
        logTransaction(paymentRequest);
        
        // Replaces: 9000-EXIT (close handled by Spring transaction commit)
        return 0;  // Success
    }
    
    // Replaces: 2000-VALIDATE-PAYMENT paragraph
    // Extracted to PaymentValidator for separation of concerns
    
    // Replaces: 3000-PROCESS-REGULAR
    private void processRegularPayment(PaymentRequest payment) {
        log.debug("Processing regular payment: {}", payment.getTransactionId());
        updatePaymentStatus(payment, PaymentRequest.PaymentStatus.APPROVED);
    }
    
    // Replaces: 3100-PROCESS-REFUND
    private void processRefundPayment(PaymentRequest payment) {
        log.debug("Processing refund payment: {}", payment.getTransactionId());
        // Negate amount for refund
        payment.setAmount(payment.getAmount().negate());
        updatePaymentStatus(payment, PaymentRequest.PaymentStatus.APPROVED);
    }
    
    // Replaces: 3200-PROCESS-REVERSAL
    private void processReversalPayment(PaymentRequest payment) {
        log.debug("Processing reversal payment: {}", payment.getTransactionId());
        updatePaymentStatus(payment, PaymentRequest.PaymentStatus.REVERSED);
    }
    
    // Replaces: 3900-UPDATE-PAYMENT-STATUS
    private void updatePaymentStatus(PaymentRequest payment, 
                                     PaymentRequest.PaymentStatus status) {
        payment.setStatus(status);
        payment.setTimestamp(LocalDateTime.now());
    }
    
    // Replaces: 4000-LOG-TRANSACTION
    private void logTransaction(PaymentRequest payment) {
        paymentLogRepository.save(payment);
        log.info("Logged payment transaction: {} with status: {}", 
            payment.getTransactionId(), payment.getStatus());
    }
}
```

### Validator Extraction (Replaces 2000-VALIDATE-PAYMENT)
```java
package com.lbg.legacy.payment.validator;

import com.lbg.legacy.model.PaymentRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Slf4j
@Component
public class PaymentValidator {
    
    /**
     * Replaces: 2000-VALIDATE-PAYMENT paragraph
     * Sets WS-VALIDATION-RESULT based on multiple checks
     */
    public boolean isValid(PaymentRequest payment) {
        // Check for null payment
        if (payment == null) {
            log.error("Payment request is null");
            return false;
        }
        
        // Validate transaction ID exists
        if (payment.getTransactionId() == null || payment.getTransactionId() == 0) {
            log.error("Invalid transaction ID");
            return false;
        }
        
        // Validate amount is positive (except for refunds handled separately)
        if (payment.getAmount() == null || payment.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            log.error("Invalid payment amount: {}", payment.getAmount());
            return false;
        }
        
        // Validate payment type
        if (payment.getType() == null) {
            log.error("Payment type is null");
            return false;
        }
        
        // Validate customer and account IDs
        if (payment.getCustomerId() == null || payment.getAccountId() == null) {
            log.error("Missing customer or account ID");
            return false;
        }
        
        log.debug("Payment validation passed: {}", payment.getTransactionId());
        return true;
    }
}
```

## Pattern 2: State Machine Pattern (Alternative for Complex Logic)

For more complex GOTO patterns, use State Machine:

```java
package com.lbg.legacy.payment.service;

import com.lbg.legacy.model.PaymentRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class PaymentStateMachineService {
    
    private enum ProcessingState {
        INITIALIZE,
        VALIDATE,
        ROUTE_TO_HANDLER,
        PROCESS_PAYMENT,
        LOG_TRANSACTION,
        EXIT
    }
    
    /**
     * Alternative approach using explicit state machine
     * Use when GOTO patterns are more complex than simple early exit
     */
    public int processPaymentWithStateMachine(PaymentRequest payment) {
        ProcessingState state = ProcessingState.INITIALIZE;
        int returnCode = 0;
        
        while (state != ProcessingState.EXIT) {
            switch (state) {
                case INITIALIZE:
                    log.info("Initializing payment processing");
                    state = ProcessingState.VALIDATE;
                    break;
                    
                case VALIDATE:
                    if (!validate(payment)) {
                        returnCode = 999;
                        state = ProcessingState.EXIT;  // Replaces GOTO 9000-EXIT
                    } else {
                        state = ProcessingState.ROUTE_TO_HANDLER;
                    }
                    break;
                    
                case ROUTE_TO_HANDLER:
                    state = ProcessingState.PROCESS_PAYMENT;
                    break;
                    
                case PROCESS_PAYMENT:
                    processPaymentByType(payment);
                    state = ProcessingState.LOG_TRANSACTION;
                    break;
                    
                case LOG_TRANSACTION:
                    logTransaction(payment);
                    state = ProcessingState.EXIT;
                    break;
                    
                case EXIT:
                    // Final cleanup
                    break;
            }
        }
        
        return returnCode;
    }
    
    private boolean validate(PaymentRequest payment) {
        // Validation logic
        return true;
    }
    
    private void processPaymentByType(PaymentRequest payment) {
        // Processing logic
    }
    
    private void logTransaction(PaymentRequest payment) {
        // Logging logic
    }
}
```

## Pattern 3: Exception-Based Control Flow (NOT RECOMMENDED)

```java
// ⚠️ ANTI-PATTERN - Do not use exceptions for control flow
// Showing only for completeness

public int processPaymentWithExceptions(PaymentRequest payment) {
    try {
        validateOrThrow(payment);
        processPaymentByType(payment);
        logTransaction(payment);
        return 0;
    } catch (ValidationException e) {
        log.error("Validation failed: {}", e.getMessage());
        return 999;
    }
}
```

**Why NOT to use:** Exceptions are for exceptional conditions, not control flow. Performance overhead and code clarity suffer.

## Complete Service Layer Implementation

### Repository Interface (replaces PAYMENT-LOG file)
```java
package com.lbg.legacy.payment.repository;

import com.lbg.legacy.model.PaymentRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentLogRepository extends JpaRepository<PaymentRequest, Long> {
    List<PaymentRequest> findByCustomerId(Long customerId);
    List<PaymentRequest> findByAccountId(Long accountId);
    List<PaymentRequest> findByStatus(PaymentRequest.PaymentStatus status);
}
```

### JPA Entity (for persistence)
```java
package com.lbg.legacy.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "payment_log")
public class PaymentLogEntry {
    
    @Id
    @Column(name = "transaction_id")
    private Long transactionId;
    
    @Column(name = "customer_id", nullable = false)
    private Long customerId;
    
    @Column(name = "account_id", nullable = false)
    private Long accountId;
    
    @Column(name = "amount", precision = 11, scale = 2, nullable = false)
    private BigDecimal amount;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "payment_type", length = 10, nullable = false)
    private PaymentRequest.PaymentType type;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", length = 10, nullable = false)
    private PaymentRequest.PaymentStatus status;
    
    @Column(name = "timestamp", nullable = false)
    private LocalDateTime timestamp;
    
    @PrePersist
    protected void onCreate() {
        timestamp = LocalDateTime.now();
    }
}
```

## Data Mapping

### Working Storage Variables

| COBOL Item | Java Type | Implementation | Notes |
|---|---|---|---|
| WS-FILE-STATUS | String | Spring Data handles | File I/O managed by JPA |
| WS-TIMESTAMP | LocalDateTime | `LocalDateTime.now()` | Java 8 Date/Time API |
| WS-LOG-RECORD | PaymentLogEntry | JPA Entity | Database persistence |
| WS-VALIDATION-RESULT | boolean | Method return | `paymentValidator.isValid()` |
| WS-PROCESS-STATUS | String | Enum | `PaymentStatus` enum |

### Linkage Section

| COBOL Item | Java Type | Implementation | Notes |
|---|---|---|---|
| LS-PAYMENT-REQUEST | PaymentRequest | Method parameter | DTO object |
| LS-RETURN-CODE | int | Method return value | 0 = success, 999 = failure |

### Condition Names (88-level)

| COBOL Condition | Java Implementation | Notes |
|---|---|---|
| WS-FILE-OK VALUE "00" | Repository success | Handled by Spring Data |
| WS-VALID-PAYMENT VALUE "Y" | `validator.isValid()` | Boolean method |
| WS-INVALID-PAYMENT VALUE "N" | `!validator.isValid()` | Negated boolean |
| PAY-REGULAR | `PaymentType.REGULAR` | Enum value |
| PAY-REFUND | `PaymentType.REFUND` | Enum value |
| PAY-REVERSAL | `PaymentType.REVERSAL` | Enum value |
| PAY-APPROVED | `PaymentStatus.APPROVED` | Enum value |
| PAY-PENDING | `PaymentStatus.PENDING` | Enum value |
| PAY-REVERSED | `PaymentStatus.REVERSED` | Enum value |
| PAY-REJECTED | `PaymentStatus.REJECTED` | Enum value |

## Method Mapping

| COBOL Paragraph | Java Method | Notes |
|---|---|---|
| 0000-MAIN | `processPayment(PaymentRequest)` | Entry point with GOTO eliminated |
| 9000-EXIT | return statement | Natural method exit |
| 1000-OPEN-LOG | `@Transactional` annotation | Spring manages resources |
| 2000-VALIDATE-PAYMENT | `PaymentValidator.isValid()` | Extracted to validator |
| 3000-PROCESS-REGULAR | `processRegularPayment()` | Private method |
| 3100-PROCESS-REFUND | `processRefundPayment()` | Private method |
| 3200-PROCESS-REVERSAL | `processReversalPayment()` | Private method |
| 3900-UPDATE-PAYMENT-STATUS | `updatePaymentStatus()` | Private method |
| 4000-LOG-TRANSACTION | `logTransaction()` | Private method |
| 9000-CLOSE-LOG | Transaction commit | Spring manages cleanup |

## Risks and Mitigations

### Risk Assessment
**Overall Risk:** HIGH (due to GOTO refactoring)

| Risk | Severity | Mitigation |
|---|---|---|
| **GOTO logic misinterpretation** | CRITICAL | Comprehensive unit tests for all control flow paths |
| **Missing validation edge cases** | HIGH | Extract all 88-level conditions to explicit validator tests |
| **Transaction boundary issues** | MEDIUM | Use `@Transactional` with proper isolation level |
| **COMP-3 precision loss** | MEDIUM | Use `BigDecimal` for all currency amounts |
| **Date/time format differences** | LOW | ISO-8601 format in database |

### GOTO Elimination Testing Strategy

1. **Map all possible execution paths:**
   - Normal flow (validation passes)
   - Early exit flow (validation fails)
   - Each payment type branch

2. **Create test cases for each path:**
```java
@Test
void shouldReturnErrorCodeWhenValidationFails() {
    // Replaces: IF WS-INVALID-PAYMENT GO TO 9000-EXIT
    PaymentRequest invalidPayment = new PaymentRequest();
    invalidPayment.setAmount(BigDecimal.ZERO);  // Invalid
    
    int result = service.processPayment(invalidPayment);
    
    assertThat(result).isEqualTo(999);
    verify(paymentLogRepository, never()).save(any());
}

@Test
void shouldProcessRegularPaymentWhenValid() {
    // Replaces: Normal flow without GOTO
    PaymentRequest validPayment = createValidPayment(PaymentType.REGULAR);
    
    int result = service.processPayment(validPayment);
    
    assertThat(result).isEqualTo(0);
    verify(paymentLogRepository, times(1)).save(any());
}
```

## Testing Strategy

### 1. Unit Tests (Focus on GOTO elimination)
```java
package com.lbg.legacy.payment.service;

import com.lbg.legacy.model.PaymentRequest;
import com.lbg.legacy.payment.repository.PaymentLogRepository;
import com.lbg.legacy.payment.validator.PaymentValidator;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PaymentHandlerServiceTest {
    
    @Mock
    private PaymentValidator paymentValidator;
    
    @Mock
    private PaymentLogRepository paymentLogRepository;
    
    @InjectMocks
    private PaymentHandlerService service;
    
    // Test 1: GOTO path - validation fails
    @Test
    void shouldExitEarlyWithErrorWhenValidationFails() {
        PaymentRequest payment = new PaymentRequest();
        when(paymentValidator.isValid(payment)).thenReturn(false);
        
        int result = service.processPayment(payment);
        
        assertThat(result).isEqualTo(999);  // Error code
        verify(paymentLogRepository, never()).save(any());  // No logging on failure
    }
    
    // Test 2: Normal path - regular payment
    @Test
    void shouldProcessRegularPayment() {
        PaymentRequest payment = createValidPayment(PaymentRequest.PaymentType.REGULAR);
        when(paymentValidator.isValid(payment)).thenReturn(true);
        
        int result = service.processPayment(payment);
        
        assertThat(result).isEqualTo(0);
        assertThat(payment.getStatus()).isEqualTo(PaymentRequest.PaymentStatus.APPROVED);
        verify(paymentLogRepository, times(1)).save(payment);
    }
    
    // Test 3: Refund payment - amount negation
    @Test
    void shouldNegateAmountForRefund() {
        PaymentRequest payment = createValidPayment(PaymentRequest.PaymentType.REFUND);
        BigDecimal originalAmount = payment.getAmount();
        when(paymentValidator.isValid(payment)).thenReturn(true);
        
        service.processPayment(payment);
        
        assertThat(payment.getAmount()).isEqualTo(originalAmount.negate());
        assertThat(payment.getStatus()).isEqualTo(PaymentRequest.PaymentStatus.APPROVED);
    }
    
    // Test 4: Reversal payment
    @Test
    void shouldSetReversedStatusForReversal() {
        PaymentRequest payment = createValidPayment(PaymentRequest.PaymentType.REVERSAL);
        when(paymentValidator.isValid(payment)).thenReturn(true);
        
        service.processPayment(payment);
        
        assertThat(payment.getStatus()).isEqualTo(PaymentRequest.PaymentStatus.REVERSED);
    }
    
    private PaymentRequest createValidPayment(PaymentRequest.PaymentType type) {
        PaymentRequest payment = new PaymentRequest();
        payment.setTransactionId(123456789012L);
        payment.setCustomerId(12345678L);
        payment.setAccountId(1234567890L);
        payment.setAmount(new BigDecimal("100.50"));
        payment.setType(type);
        return payment;
    }
}
```

### 2. Integration Tests
```java
@SpringBootTest
@Transactional
class PaymentHandlerServiceIntegrationTest {
    
    @Autowired
    private PaymentHandlerService service;
    
    @Autowired
    private PaymentLogRepository repository;
    
    @Test
    void shouldPersistPaymentLog() {
        PaymentRequest payment = createValidPayment();
        
        int result = service.processPayment(payment);
        
        assertThat(result).isEqualTo(0);
        assertThat(repository.findById(payment.getTransactionId())).isPresent();
    }
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
| Domain model creation | 0.5 days | POJOs and enums |
| GOTO analysis & strategy | 1 day | **CRITICAL** - map all paths |
| Service implementation | 1.5 days | Include validator extraction |
| Repository setup | 0.5 days | Spring Data JPA |
| Unit tests (GOTO paths) | 2 days | **CRITICAL** - all control flows |
| Integration tests | 1 day | Database persistence |
| Code review & validation | 0.5 days | Verify GOTO elimination |
| Documentation | 0.5 days | JavaDoc |
| **Total** | **7.5 days** | ~1.5 weeks |

## Migration Sequence

1. **Phase 1: Analysis** (Day 1)
   - Map all GOTO execution paths
   - Document current behavior
   - Create test scenarios

2. **Phase 2: Model & Validator** (Day 2)
   - Create domain models
   - Extract validation logic
   - Unit test validator

3. **Phase 3: Service Implementation** (Days 3-4)
   - Implement guard clause pattern
   - Remove GOTO with early returns
   - Unit test all paths

4. **Phase 4: Persistence Layer** (Day 5)
   - Set up JPA repository
   - Replace file I/O with database
   - Integration tests

5. **Phase 5: Testing & Validation** (Days 6-7)
   - Comprehensive test suite
   - GOTO path verification
   - Performance testing

6. **Phase 6: Documentation** (Day 8)
   - Complete JavaDoc
   - GOTO elimination report
   - Deployment guide

## Next Steps

1. **Mandatory:** Peer review GOTO elimination strategy
2. Create comprehensive test data set
3. Set up code coverage targets (>90% for control flow)
4. Begin Phase 1 with detailed path analysis
5. Coordinate integration with ACCOUNT-MGR
