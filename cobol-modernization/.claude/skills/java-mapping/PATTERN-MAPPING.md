# COBOL to Java Structural Pattern Mappings

## Program Structure Mappings

### COBOL Batch Program → Spring Batch Job

```cobol
PROCEDURE DIVISION.
0000-MAIN.
    OPEN INPUT INPUT-FILE
    OPEN OUTPUT OUTPUT-FILE
    PERFORM UNTIL WS-EOF
        READ INPUT-FILE AT END MOVE 'Y' TO WS-EOF
        NOT AT END PERFORM PROCESS-RECORD
    END-READ
    END-PERFORM
    CLOSE INPUT-FILE OUTPUT-FILE
    STOP RUN.

PROCESS-RECORD.
    [business logic]
    WRITE OUTPUT-RECORD.
```

```java
@Configuration
public class BatchJobConfig {

    @Bean
    public Job customerProcessingJob(JobRepository jobRepository, Step step) {
        return new JobBuilder("customerProcessingJob", jobRepository)
            .start(step)
            .build();
    }

    @Bean
    public Step customerProcessingStep(JobRepository jobRepository,
            PlatformTransactionManager txManager,
            ItemReader<CustomerRecord> reader,
            ItemProcessor<CustomerRecord, OutputRecord> processor,
            ItemWriter<OutputRecord> writer) {
        return new StepBuilder("customerProcessingStep", jobRepository)
            .<CustomerRecord, OutputRecord>chunk(100, txManager)
            .reader(reader)
            .processor(processor)
            .writer(writer)
            .build();
    }
}
```

---

### COBOL Subroutine → Spring @Service

```cobol
LINKAGE SECTION.
01 LS-INPUT-RECORD.
   05 LS-CUST-ID     PIC 9(8).
01 LS-OUTPUT-RECORD.
   05 LS-RESULT-CODE PIC S9(4).
   05 LS-RESULT-MSG  PIC X(80).

PROCEDURE DIVISION USING LS-INPUT-RECORD LS-OUTPUT-RECORD.
```

```java
@Service
public class CustomerValidationService {

    public ValidationResult validate(long custId) {
        // was PROCEDURE DIVISION logic
        return new ValidationResult(resultCode, resultMessage);
    }

    public record ValidationResult(int resultCode, String resultMessage) {}
}
```

---

### COBOL CALL Chain → Spring Dependency Injection

```cobol
CALL 'ACCOUNT-MGR' USING CUSTOMER-REC WS-ACCOUNT-DATA WS-RETURN-CODE
CALL 'PAYMENT-HANDLER' USING WS-PAYMENT-REQUEST WS-RETURN-CODE
```

```java
@Service
public class CustomerProcessingService {

    private final AccountManagerService accountManager;
    private final PaymentHandlerService paymentHandler;

    // Constructor injection (Spring auto-wires)
    public CustomerProcessingService(AccountManagerService accountManager,
                                     PaymentHandlerService paymentHandler) {
        this.accountManager = accountManager;
        this.paymentHandler = paymentHandler;
    }

    public void processCustomer(CustomerRecord customer) {
        AccountData account = accountManager.getAccount(customer);
        paymentHandler.processPayment(buildPaymentRequest(customer, account));
    }
}
```

---

## Control Flow Pattern Mappings

### PERFORM VARYING → Java for loop

```cobol
PERFORM PROCESS-ENTRY
    VARYING WS-IDX FROM 1 BY 1
    UNTIL WS-IDX > WS-MAX-ENTRIES
```

```java
for (int idx = 1; idx <= maxEntries; idx++) {
    processEntry(idx);
}
```

---

### PERFORM UNTIL → Java while loop

```cobol
PERFORM READ-AND-PROCESS UNTIL WS-EOF = 'Y'
```

```java
while (!isEof) {
    readAndProcess();
}
```

---

### EVALUATE (complex) → Strategy Pattern

When EVALUATE selects between complex, different behaviors:

```cobol
EVALUATE WS-TRANSACTION-TYPE
    WHEN 'D' PERFORM DEBIT-HANDLER
    WHEN 'C' PERFORM CREDIT-HANDLER
    WHEN 'T' PERFORM TRANSFER-HANDLER
    WHEN OTHER PERFORM UNKNOWN-TYPE-ERROR
END-EVALUATE
```

```java
// Strategy interface
interface TransactionHandler {
    void handle(TransactionRecord transaction);
}

// Strategy map
Map<String, TransactionHandler> handlers = Map.of(
    "D", debitHandler,
    "C", creditHandler,
    "T", transferHandler
);

TransactionHandler handler = handlers.getOrDefault(
    transaction.type(),
    unknownTypeErrorHandler
);
handler.handle(transaction);
```

---

### GOTO (Simple) → Extracted Method with Early Return

```cobol
1000-VALIDATE.
    IF LS-CUST-ID = ZEROES
        MOVE 8 TO LS-RETURN-CODE
        GO TO 1000-EXIT
    END-IF
    IF LS-CUST-NAME = SPACES
        MOVE 12 TO LS-RETURN-CODE
        GO TO 1000-EXIT
    END-IF
    MOVE 0 TO LS-RETURN-CODE.
1000-EXIT.
    EXIT.
```

```java
private int validate(long custId, String custName) {
    if (custId == 0) return 8;
    if (custName == null || custName.isBlank()) return 12;
    return 0;
}
```

---

### PERFORM THRU → Sequential method calls

```cobol
PERFORM 2000-PROCESS THRU 2900-PROCESS-END
```

Where the range includes 2000, 2100, 2200 ... 2900:

```java
private void process() {
    process2000();
    process2100();
    process2200();
    // ... through
    process2900();
}
```

---

## Data Access Pattern Mappings

### Sequential File Read → Spring Batch FlatFileItemReader

```cobol
SELECT INPUT-FILE ASSIGN TO INPUTDAT
    ORGANIZATION IS SEQUENTIAL.
```

```java
@Bean
public FlatFileItemReader<CustomerRecord> reader() {
    return new FlatFileItemReaderBuilder<CustomerRecord>()
        .name("customerItemReader")
        .resource(new ClassPathResource("input/INPUTDAT.txt"))
        .delimited()
        .names("custId", "custName", "balance")
        .fieldSetMapper(new BeanWrapperFieldSetMapper<>() {{
            setTargetType(CustomerRecord.class);
        }})
        .build();
}
```

### VSAM KSDS (Keyed) → Spring Data JPA Repository

```cobol
SELECT CUSTOMER-FILE ASSIGN TO CUSTMAST
    ORGANIZATION IS INDEXED
    ACCESS MODE IS DYNAMIC
    RECORD KEY IS CUST-ID.
```

```java
@Entity
@Table(name = "CUSTOMER")
public class Customer {
    @Id
    private Long custId;
    private String custName;
    private BigDecimal balance;
}

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    List<Customer> findByCustNameContaining(String name);
    List<Customer> findByBalanceGreaterThan(BigDecimal amount);
}
```

### READ KEY → repository.findById()

```cobol
MOVE '12345678' TO CUST-KEY
READ CUSTOMER-FILE KEY IS CUST-KEY
    INVALID KEY PERFORM KEY-NOT-FOUND
    NOT INVALID KEY PERFORM PROCESS-CUSTOMER
END-READ
```

```java
Optional<Customer> customer = customerRepository.findById(12345678L);
if (customer.isEmpty()) {
    handleKeyNotFound();
} else {
    processCustomer(customer.get());
}
```

---

## Error Handling Mappings

### FILE STATUS checks → Exception handling

```cobol
READ CUSTOMER-FILE
    AT END MOVE 'Y' TO WS-EOF
END-READ
IF WS-FILE-STATUS NOT = '00'
    PERFORM ERROR-HANDLER
END-IF
```

```java
try {
    Customer customer = reader.read();
    if (customer == null) {
        // EOF
        isEof = true;
    }
} catch (FlatFileParseException e) {
    handleFileError(e);
}
```

### CALL ON EXCEPTION → try-catch

```cobol
CALL 'EXTPROG' USING WS-DATA
    ON EXCEPTION PERFORM CALL-FAILED
    NOT ON EXCEPTION PERFORM CALL-SUCCEEDED
END-CALL
```

```java
try {
    ExternalResult result = externalService.process(data);
    callSucceeded(result);
} catch (ServiceException e) {
    callFailed(e);
}
```
