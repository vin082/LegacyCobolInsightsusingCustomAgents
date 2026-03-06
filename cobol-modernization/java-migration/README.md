# Java Migration - ACCOUNT-MGR

This directory contains the Java implementation of the COBOL ACCOUNT-MGR program.

## Source COBOL Program

- **Program ID**: ACCOUNT-MGR
- **Original Author**: M.JONES (1989-07-22)
- **Lines**: 115
- **Type**: Business Logic Service
- **Source File**: `sample-cobol/ACCOUNT-MGR.cbl`

## Architecture

### Spring Boot Service Pattern

The COBOL program has been converted to a Spring Boot service using:
- **@Service** for business logic (AccountManagementService)
- **@Repository** for data access (AccountRepository)
- **@Entity** for domain model (Account)
- **@Transactional** for transaction management

### Package Structure

```
com.lbg.legacy/
├── model/
│   ├── Account.java              # ACCOUNT-RECORD copybook → JPA Entity
│   ├── CustomerRecord.java       # CUSTOMER-RECORD copybook → DTO
│   └── PaymentRequest.java       # PAYMENT-RECORD copybook → DTO
├── account/
│   ├── repository/
│   │   └── AccountRepository.java   # ACCOUNT-FILE → Spring Data JPA
│   └── service/
│       └── AccountManagementService.java  # ACCOUNT-MGR program
└── payment/
    └── service/
        └── PaymentHandlerService.java     # PAYMENT-HANDLER program (stub)
```

## Key Mappings

### COBOL → Java Patterns

| COBOL Construct | Java Implementation | File |
|----------------|---------------------|------|
| ACCOUNT-RECORD copybook | JPA @Entity class | Account.java |
| ACCOUNT-FILE (INDEXED) | JpaRepository | AccountRepository.java |
| 88-level conditions | Java Enums | Account.java |
| COMP-3 decimals | BigDecimal | Account.java |
| PERFORM paragraph | private method | AccountManagementService.java |
| CALL 'PAYMENT-HANDLER' | @Autowired service | AccountManagementService.java |
| REWRITE ACCOUNT-REC | repository.save() | AccountManagementService.java |
| WS-RETURN-CODE | int return value | AccountManagementService.java |

### Return Codes

| Code | COBOL Meaning | Java Constant |
|------|--------------|---------------|
| 0 | Success | SUCCESS |
| 4 | Account not found | ACCOUNT_NOT_FOUND |
| 8 | File open error | FILE_OPEN_ERROR |
| 12 | Invalid status | INVALID_STATUS |
| 16 | File write error | FILE_WRITE_ERROR |

## Critical Data Type Mappings

### COMP-3 → BigDecimal

**COBOL:**
```cobol
05 ACCT-BALANCE PIC S9(11)V99 COMP-3.
05 ACCT-LIMIT   PIC S9(9)V99 COMP-3.
```

**Java:**
```java
@Column(name = "balance", precision = 13, scale = 2)
private BigDecimal balance;  // ⚠️ NEVER use double/float!

@Column(name = "credit_limit", precision = 11, scale = 2)
private BigDecimal creditLimit;
```

### 88-Level Conditions → Enums

**COBOL:**
```cobol
05 ACCT-STATUS       PIC X.
   88 ACCT-ACTIVE    VALUE 'A'.
   88 ACCT-INACTIVE  VALUE 'I'.
   88 ACCT-CLOSED    VALUE 'C'.
```

**Java:**
```java
public enum AccountStatus {
    ACTIVE('A'),
    INACTIVE('I'),
    CLOSED('C');
}
```

## Database Schema

```sql
CREATE TABLE accounts (
    account_id      BIGINT PRIMARY KEY,
    customer_id     BIGINT NOT NULL,
    account_type    VARCHAR(3) NOT NULL,
    status          CHAR(1) NOT NULL,
    balance         NUMERIC(13,2) NOT NULL,  -- S9(11)V99 COMP-3
    credit_limit    NUMERIC(11,2),           -- S9(9)V99 COMP-3
    open_date       DATE,
    version         BIGINT,  -- Optimistic locking
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id)
);

CREATE INDEX idx_account_customer ON accounts(customer_id);
CREATE INDEX idx_account_status ON accounts(status);
```

## Testing

### Unit Test Example

```java
@Test
void shouldActivateAccountWhenCustomerIsActive() {
    // Given
    CustomerRecord customer = new CustomerRecord();
    customer.setCustomerId(12345678L);
    customer.setStatus(CustomerStatus.ACTIVE);
    
    Account account = new Account();
    account.setAccountId(1234567890L);
    account.setCustomerId(12345678L);
    account.setStatus(AccountStatus.INACTIVE);
    
    when(accountRepository.findByCustomerId(12345678L))
        .thenReturn(Optional.of(account));
    
    // When
    int result = service.processCustomerAccount(customer);
    
    // Then
    assertThat(result).isEqualTo(0);
    assertThat(account.getStatus()).isEqualTo(AccountStatus.ACTIVE);
    verify(accountRepository).save(account);
}
```

## Dependencies

Add to `pom.xml`:

```xml
<dependencies>
    <!-- Spring Boot -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    
    <!-- Database -->
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
    </dependency>
    
    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    
    <!-- Testing -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Migration Checklist

- [x] Convert ACCOUNT-RECORD copybook to JPA Entity
- [x] Convert CUSTOMER-RECORD copybook to DTO
- [x] Convert PAYMENT-RECORD copybook to DTO
- [x] Create AccountRepository (replaces ACCOUNT-FILE)
- [x] Implement AccountManagementService (replaces ACCOUNT-MGR)
- [ ] Create PaymentHandlerService stub (PAYMENT-HANDLER migration pending)
- [ ] Write unit tests for all service methods
- [ ] Write integration tests with test database
- [ ] Test COMP-3 precision with real financial data
- [ ] Performance test indexed lookups vs VSAM
- [ ] Document any business logic changes

## Next Steps

1. **Implement PaymentHandlerService** - Migrate PAYMENT-HANDLER.cbl
2. **Write comprehensive tests** - Especially for COMP-3 calculations
3. **Set up test data** - Create sample accounts in test database
4. **Integration testing** - Test with CustomerProcessingService
5. **Performance benchmarking** - Compare with COBOL execution times

## References

- COBOL Source: [sample-cobol/ACCOUNT-MGR.cbl](../sample-cobol/ACCOUNT-MGR.cbl)
- Migration Blueprint: [docs/migration-blueprints/ACCOUNT-MGR-blueprint.md](../../docs/migration-blueprints/ACCOUNT-MGR-blueprint.md)
- Type Mappings: [.claude/skills/java-mapping/TYPE-MAPPING.md](../.claude/skills/java-mapping/TYPE-MAPPING.md)
- Pattern Mappings: [.claude/skills/java-mapping/PATTERN-MAPPING.md](../.claude/skills/java-mapping/PATTERN-MAPPING.md)
