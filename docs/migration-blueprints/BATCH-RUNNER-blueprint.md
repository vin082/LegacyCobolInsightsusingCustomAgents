# Migration Blueprint: BATCH-RUNNER → Spring Batch Application

## Program Summary
- **Complexity:** LOW (123 lines)
- **Author:** D.WILSON (1995-02-14)
- **Paragraphs:** 5
- **External calls:** 1 (CUSTOMER-PROC)
- **Copybooks:** 1 (CUSTOMER-RECORD)
- **Type:** Batch Entry Point Program
- **Risk Flags:** None (no GOTO, ALTER, or REDEFINES)

## Purpose
Master batch controller that reads customer extract file and invokes CUSTOMER-PROC for each record. Produces batch run statistics report. This is the entry point for the entire customer processing workflow.

## Recommended Java Architecture

### Architecture Type: Spring Batch
**Package:** `com.lbg.legacy.batch.runner`  
**Main Class:** `BatchRunnerApplication`  
**Job Configuration:** `CustomerProcessingJobConfig`

### Core Components

#### 1. Spring Boot Application
```java
@SpringBootApplication
@EnableBatchProcessing
public class BatchRunnerApplication {
    
    public static void main(String[] args) {
        System.exit(SpringApplication.exit(
            SpringApplication.run(BatchRunnerApplication.class, args)));
    }
}
```

#### 2. Domain Model (from CUSTOMER-RECORD)
```java
package com.lbg.legacy.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Data;

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

#### 3. ItemReader (replaces BATCH-INPUT file read)
```java
package com.lbg.legacy.batch.reader;

import com.lbg.legacy.model.CustomerRecord;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.builder.FlatFileItemReaderBuilder;
import org.springframework.batch.item.file.mapping.BeanWrapperFieldSetMapper;
import org.springframework.batch.item.file.mapping.FieldSetMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.FileSystemResource;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Configuration
public class CustomerRecordReaderConfig {
    
    private static final DateTimeFormatter DATE_FORMAT = 
        DateTimeFormatter.ofPattern("yyyyMMdd");
    
    @Bean
    public FlatFileItemReader<CustomerRecord> customerRecordReader() {
        return new FlatFileItemReaderBuilder<CustomerRecord>()
            .name("customerRecordReader")
            .resource(new FileSystemResource("data/BATCHIN.dat"))
            .fixedLength()
            .columns(
                new Range(1, 8),    // CUST-ID
                new Range(9, 48),   // CUST-NAME
                new Range(49, 49),  // CUST-STATUS
                new Range(50, 60),  // CUST-BALANCE
                new Range(61, 68)   // CUST-OPEN-DATE
            )
            .names("customerId", "customerName", "status", "balance", "openDate")
            .fieldSetMapper(customerRecordFieldSetMapper())
            .build();
    }
    
    @Bean
    public FieldSetMapper<CustomerRecord> customerRecordFieldSetMapper() {
        return fieldSet -> {
            CustomerRecord record = new CustomerRecord();
            record.setCustomerId(fieldSet.readLong("customerId"));
            record.setCustomerName(fieldSet.readString("customerName").trim());
            record.setStatus(CustomerRecord.CustomerStatus.fromCode(
                fieldSet.readChar("status")));
            record.setBalance(new BigDecimal(fieldSet.readString("balance")));
            record.setOpenDate(LocalDate.parse(
                fieldSet.readString("openDate"), DATE_FORMAT));
            return record;
        };
    }
}
```

#### 4. ItemProcessor (replaces CALL to CUSTOMER-PROC)
```java
package com.lbg.legacy.batch.processor;

import com.lbg.legacy.model.CustomerRecord;
import com.lbg.legacy.service.CustomerProcessingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class CustomerRecordProcessor implements ItemProcessor<CustomerRecord, CustomerRecord> {
    
    private final CustomerProcessingService customerProcessingService;
    
    @Override
    public CustomerRecord process(CustomerRecord record) throws Exception {
        try {
            // Replaces: CALL 'CUSTOMER-PROC' USING BATCH-INPUT-REC
            customerProcessingService.processCustomer(record);
            log.debug("Successfully processed customer: {}", record.getCustomerId());
            return record;
        } catch (Exception e) {
            log.error("Error processing customer {}: {}", 
                record.getCustomerId(), e.getMessage());
            // Return null to skip this item (will be counted as skipped)
            // Or throw exception to fail the entire batch
            throw e;
        }
    }
}
```

#### 5. ItemWriter (replaces BATCH-REPORT write)
```java
package com.lbg.legacy.batch.writer;

import com.lbg.legacy.model.CustomerRecord;
import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.item.Chunk;
import org.springframework.batch.item.file.FlatFileItemWriter;
import org.springframework.batch.item.file.builder.FlatFileItemWriterBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.FileSystemResource;

@Slf4j
@Configuration
public class BatchReportWriterConfig {
    
    @Bean
    public FlatFileItemWriter<CustomerRecord> batchReportWriter() {
        return new FlatFileItemWriterBuilder<CustomerRecord>()
            .name("batchReportWriter")
            .resource(new FileSystemResource("data/BATCHRPT.txt"))
            .lineAggregator(record -> String.format(
                "Customer %08d: %s - Status: %s",
                record.getCustomerId(),
                record.getCustomerName(),
                record.getStatus()
            ))
            .headerCallback(writer -> {
                writer.write("=".repeat(80));
                writer.write("\n");
                writer.write("CUSTOMER PROCESSING BATCH REPORT");
                writer.write("\n");
                writer.write(java.time.LocalDateTime.now().toString());
                writer.write("\n");
                writer.write("=".repeat(80));
                writer.write("\n");
            })
            .footerCallback(writer -> {
                writer.write("\n");
                writer.write("=".repeat(80));
                writer.write("\n");
                writer.write("END OF REPORT");
                writer.write("\n");
            })
            .build();
    }
}
```

#### 6. Job Configuration (replaces paragraph control flow)
```java
package com.lbg.legacy.batch.config;

import com.lbg.legacy.batch.listener.JobExecutionListener;
import com.lbg.legacy.model.CustomerRecord;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.launch.support.RunIdIncrementer;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.batch.item.ItemReader;
import org.springframework.batch.item.ItemWriter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

@Configuration
@RequiredArgsConstructor
public class CustomerProcessingJobConfig {
    
    private final JobRepository jobRepository;
    private final PlatformTransactionManager transactionManager;
    private final ItemReader<CustomerRecord> customerRecordReader;
    private final ItemProcessor<CustomerRecord, CustomerRecord> customerRecordProcessor;
    private final ItemWriter<CustomerRecord> batchReportWriter;
    private final JobExecutionListener jobExecutionListener;
    
    @Bean
    public Job customerProcessingJob() {
        return new JobBuilder("customerProcessingJob", jobRepository)
            .incrementer(new RunIdIncrementer())
            .listener(jobExecutionListener)  // Replaces 1000-INITIALISE and 9000-FINALISE
            .start(processCustomersStep())
            .build();
    }
    
    @Bean
    public Step processCustomersStep() {
        return new StepBuilder("processCustomersStep", jobRepository)
            .<CustomerRecord, CustomerRecord>chunk(100, transactionManager)
            .reader(customerRecordReader)
            .processor(customerRecordProcessor)
            .writer(batchReportWriter)
            .faultTolerant()
            .skipLimit(10)  // Allow up to 10 errors before failing
            .skip(Exception.class)
            .build();
    }
}
```

#### 7. Job Execution Listener (replaces 1000-INITIALISE and 9000-FINALISE)
```java
package com.lbg.legacy.batch.listener;

import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobExecutionListener;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDateTime;

@Slf4j
@Component
public class CustomerJobExecutionListener implements JobExecutionListener {
    
    private LocalDateTime startTime;
    
    @Override
    public void beforeJob(JobExecution jobExecution) {
        // Replaces: 1000-INITIALISE
        startTime = LocalDateTime.now();
        log.info("========================================");
        log.info("Customer Processing Job Started");
        log.info("Job ID: {}", jobExecution.getJobId());
        log.info("Start Time: {}", startTime);
        log.info("========================================");
        
        // Initialize counters (replaces WS-COUNTERS initialization)
        jobExecution.getExecutionContext().putLong("totalRead", 0L);
        jobExecution.getExecutionContext().putLong("totalProcessed", 0L);
        jobExecution.getExecutionContext().putLong("totalErrors", 0L);
    }
    
    @Override
    public void afterJob(JobExecution jobExecution) {
        // Replaces: 9000-FINALISE
        LocalDateTime endTime = LocalDateTime.now();
        Duration duration = Duration.between(startTime, endTime);
        
        long readCount = jobExecution.getStepExecutions().stream()
            .mapToLong(s -> s.getReadCount())
            .sum();
        long writeCount = jobExecution.getStepExecutions().stream()
            .mapToLong(s -> s.getWriteCount())
            .sum();
        long skipCount = jobExecution.getStepExecutions().stream()
            .mapToLong(s -> s.getSkipCount())
            .sum();
        
        log.info("========================================");
        log.info("Customer Processing Job Completed");
        log.info("Job ID: {}", jobExecution.getJobId());
        log.info("Status: {}", jobExecution.getStatus());
        log.info("End Time: {}", endTime);
        log.info("Duration: {} seconds", duration.getSeconds());
        log.info("Records Read: {}", readCount);        // WS-TOTAL-READ
        log.info("Records Processed: {}", writeCount);  // WS-TOTAL-PROCESSED
        log.info("Errors Skipped: {}", skipCount);      // WS-TOTAL-ERRORS
        log.info("========================================");
    }
}
```

## Data Mapping

### Working Storage Variables

| COBOL Item | Java Type | Implementation | Notes |
|---|---|---|---|
| WS-INPUT-STATUS | String | `customerRecordReader.getExecutionContext()` | File status handled by Spring Batch |
| WS-REPORT-STATUS | String | `batchReportWriter.getExecutionContext()` | File status handled by Spring Batch |
| WS-EOF | boolean | Not needed | Spring Batch handles EOF automatically |
| WS-TOTAL-READ | long | `jobExecution.getReadCount()` | Tracked by Spring Batch metrics |
| WS-TOTAL-PROCESSED | long | `jobExecution.getWriteCount()` | Tracked by Spring Batch metrics |
| WS-TOTAL-ERRORS | long | `jobExecution.getSkipCount()` | Tracked by Spring Batch metrics |
| WS-CALL-RETURN-CODE | Integer | Exception handling | Use try-catch instead |
| WS-DATE-TIME | LocalDateTime | `LocalDateTime.now()` | Java 8 Date/Time API |

### Condition Names (88-level)

| COBOL Condition | Java Implementation | Notes |
|---|---|---|
| WS-INPUT-OK VALUE "00" | `!reader.hasError()` | Spring Batch error handling |
| WS-INPUT-EOF VALUE "10" | Not needed | Automatic in Spring Batch |
| WS-REPORT-OK VALUE "00" | `!writer.hasError()` | Spring Batch error handling |
| WS-END-OF-FILE VALUE "Y" | Not needed | Automatic in Spring Batch |

## Method Mapping

| COBOL Paragraph | Java Method/Component | Notes |
|---|---|---|
| 0000-MAIN | `CustomerProcessingJobConfig.customerProcessingJob()` | Job definition |
| 1000-INITIALISE | `JobExecutionListener.beforeJob()` | Pre-execution setup |
| 1100-READ-NEXT-RECORD | `customerRecordReader.read()` | Spring Batch ItemReader |
| 2000-PROCESS-BATCH | `processCustomersStep()` | Spring Batch Step |
| CALL 'CUSTOMER-PROC' | `customerRecordProcessor.process()` | Delegated to service |
| 9000-FINALISE | `JobExecutionListener.afterJob()` | Post-execution reporting |

## Dependencies

### Maven Dependencies (pom.xml)
```xml
<dependencies>
    <!-- Spring Boot Starter -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-batch</artifactId>
        <version>3.2.0</version>
    </dependency>
    
    <!-- Database for Batch Metadata -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
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
    <dependency>
        <groupId>org.springframework.batch</groupId>
        <artifactId>spring-batch-test</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Application Configuration (application.yml)
```yaml
spring:
  application:
    name: batch-runner
  batch:
    job:
      enabled: true
    jdbc:
      initialize-schema: always
  datasource:
    url: jdbc:h2:mem:batchdb
    driver-class-name: org.h2.Driver
    username: sa
    password:
    
batch:
  input-file: data/BATCHIN.dat
  report-file: data/BATCHRPT.txt
  chunk-size: 100
  skip-limit: 10

logging:
  level:
    com.lbg.legacy: DEBUG
    org.springframework.batch: INFO
```

## Risks and Mitigations

### Risk Assessment
**Overall Risk:** LOW

| Risk | Severity | Mitigation |
|---|---|---|
| File format mismatch | MEDIUM | Create comprehensive integration tests with sample BATCHIN files |
| Performance degradation | LOW | Use chunk-based processing; tune chunk-size (currently 100) |
| Error handling differences | MEDIUM | Implement skip/retry logic; log errors comprehensively |
| Date format conversion | LOW | Use DateTimeFormatter with exact COBOL format (yyyyMMdd) |

### No Critical Risks Identified
- No GOTO statements
- No ALTER statements
- No REDEFINES
- Simple sequential file I/O
- Clean paragraph structure

## Testing Strategy

### 1. Unit Tests
```java
package com.lbg.legacy.batch.processor;

import com.lbg.legacy.model.CustomerRecord;
import com.lbg.legacy.service.CustomerProcessingService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CustomerRecordProcessorTest {
    
    @Mock
    private CustomerProcessingService customerProcessingService;
    
    @InjectMocks
    private CustomerRecordProcessor processor;
    
    @Test
    void shouldProcessValidCustomerRecord() throws Exception {
        // Given
        CustomerRecord input = createTestCustomer();
        doNothing().when(customerProcessingService).processCustomer(input);
        
        // When
        CustomerRecord result = processor.process(input);
        
        // Then
        assertThat(result).isNotNull();
        verify(customerProcessingService, times(1)).processCustomer(input);
    }
    
    private CustomerRecord createTestCustomer() {
        CustomerRecord record = new CustomerRecord();
        record.setCustomerId(12345678L);
        record.setCustomerName("TEST CUSTOMER");
        record.setStatus(CustomerRecord.CustomerStatus.ACTIVE);
        return record;
    }
}
```

### 2. Integration Tests
```java
package com.lbg.legacy.batch;

import com.lbg.legacy.batch.config.CustomerProcessingJobConfig;
import org.junit.jupiter.api.Test;
import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.test.JobLauncherTestUtils;
import org.springframework.batch.test.context.SpringBatchTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBatchTest
@SpringBootTest
@ActiveProfiles("test")
class CustomerProcessingJobIntegrationTest {
    
    @Autowired
    private JobLauncherTestUtils jobLauncherTestUtils;
    
    @Test
    void shouldProcessBatchSuccessfully() throws Exception {
        // Given
        JobParameters jobParameters = new JobParametersBuilder()
            .addLong("time", System.currentTimeMillis())
            .toJobParameters();
        
        // When
        JobExecution jobExecution = jobLauncherTestUtils.launchJob(jobParameters);
        
        // Then
        assertThat(jobExecution.getStatus()).isEqualTo(BatchStatus.COMPLETED);
        assertThat(jobExecution.getStepExecutions())
            .hasSize(1)
            .allMatch(s -> s.getReadCount() > 0);
    }
}
```

### 3. End-to-End Testing Approach
- **Test data:** Create sample BATCHIN.dat files with known data
- **Expected output:** Validate BATCHRPT.txt matches expected format
- **Metrics validation:** Verify read/write/skip counts match COBOL behavior
- **Error scenarios:** Test with malformed records, missing files, etc.

## Estimated Effort

| Activity | Effort | Notes |
|---|---|---|
| Domain model creation | 0.5 days | Simple POJOs from copybooks |
| ItemReader implementation | 1 day | Fixed-length file parsing with field mapping |
| ItemProcessor implementation | 0.5 days | Delegate to service layer |
| ItemWriter implementation | 1 day | Report formatting and statistics |
| Job configuration | 1 day | Spring Batch job/step setup |
| Listeners and metrics | 0.5 days | Replicate COBOL counter logic |
| Unit tests | 1.5 days | Test each component |
| Integration tests | 1.5 days | End-to-end batch testing |
| Documentation | 0.5 days | JavaDoc and README |
| **Total** | **8 days** | ~1.5 weeks for one developer |

## Migration Sequence

1. **Phase 1: Model Setup** (Day 1)
   - Create CustomerRecord domain model
   - Set up Maven project structure
   - Configure Spring Boot and Spring Batch

2. **Phase 2: Reader Implementation** (Day 2)
   - Implement FlatFileItemReader
   - Create custom FieldSetMapper
   - Unit test with sample data

3. **Phase 3: Processor & Writer** (Days 3-4)
   - Implement CustomerRecordProcessor
   - Create batch report writer
   - Add listener for statistics

4. **Phase 4: Integration** (Day 5)
   - Wire up job configuration
   - Integrate with CustomerProcessingService
   - End-to-end testing

5. **Phase 5: Testing** (Days 6-7)
   - Comprehensive unit tests
   - Integration tests
   - Performance testing

6. **Phase 6: Documentation & Deployment** (Day 8)
   - Complete documentation
   - Deployment scripts
   - Runbook creation

## Deployment Considerations

### Runtime Environment
- **JDK:** Java 17+
- **Spring Boot:** 3.2.x
- **Database:** H2 (dev), PostgreSQL (prod) for batch metadata
- **Memory:** 2GB heap recommended for production

### Execution
```bash
# COBOL equivalent: JCL to run BATCH-RUNNER
java -jar batch-runner-1.0.0.jar \
  --spring.batch.job.name=customerProcessingJob \
  --batch.input-file=/data/BATCHIN.dat \
  --batch.report-file=/data/BATCHRPT.txt
```

### Monitoring
- Spring Boot Actuator endpoints
- Batch job execution metrics
- Log aggregation (ELK stack recommended)
- Alerting on job failures

## Next Steps

1. Review this blueprint with the team
2. Set up project structure and dependencies
3. Create sample test data files
4. Begin Phase 1 implementation
5. Schedule downstream integration with CUSTOMER-PROC migration
