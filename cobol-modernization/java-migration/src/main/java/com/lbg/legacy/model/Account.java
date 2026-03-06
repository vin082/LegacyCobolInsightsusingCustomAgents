package com.lbg.legacy.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * JPA Entity mapping from COBOL ACCOUNT-RECORD copybook
 * Replaces: ACCOUNT-FILE (INDEXED file with ACCT-ID as key)
 * Source: ACCOUNT-RECORD.cpy
 */
@Data
@Entity
@Table(name = "accounts", indexes = {
    @Index(name = "idx_account_customer", columnList = "customer_id"),
    @Index(name = "idx_account_status", columnList = "status")
})
public class Account {
    
    /**
     * COBOL: 05 ACCT-ID PIC 9(10)
     * Primary key - 10 digit account identifier
     */
    @Id
    @Column(name = "account_id", nullable = false)
    private Long accountId;
    
    /**
     * COBOL: 05 ACCT-CUST-ID PIC 9(8)
     * Foreign key to customer - used for indexed file lookups
     * Corresponds to CUST-ID in CUSTOMER-RECORD
     */
    @Column(name = "customer_id", nullable = false)
    private Long customerId;
    
    /**
     * COBOL: 05 ACCT-TYPE PIC X(3)
     * Account type: CUR (Current), SAV (Savings), LON (Loan)
     * 88-level conditions mapped to enum
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "account_type", length = 3, nullable = false)
    private AccountType accountType;
    
    /**
     * COBOL: 05 ACCT-STATUS PIC X
     * Account status: A (Active), I (Inactive), C (Closed)
     * 88-level conditions mapped to enum
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "status", length = 1, nullable = false)
    private AccountStatus status;
    
    /**
     * COBOL: 05 ACCT-BALANCE PIC S9(11)V99 COMP-3
     * CRITICAL: COMP-3 packed decimal → BigDecimal (NOT double/float!)
     * Precision: 13 (11 integer + 2 decimal)
     * Scale: 2 (decimal places)
     * Range: -99,999,999,999.99 to +99,999,999,999.99
     */
    @Column(name = "balance", precision = 13, scale = 2, nullable = false)
    private BigDecimal balance;
    
    /**
     * COBOL: 05 ACCT-LIMIT PIC S9(9)V99 COMP-3
     * CRITICAL: COMP-3 packed decimal → BigDecimal
     * Precision: 11 (9 integer + 2 decimal)
     * Scale: 2 (decimal places)
     */
    @Column(name = "credit_limit", precision = 11, scale = 2)
    private BigDecimal creditLimit;
    
    /**
     * COBOL: 05 ACCT-OPEN-DATE PIC 9(8)
     * Format: YYYYMMDD → LocalDate
     */
    @Column(name = "open_date")
    private LocalDate openDate;
    
    /**
     * Optimistic locking for concurrent update protection
     * Replaces VSAM file locking mechanisms
     */
    @Version
    @Column(name = "version")
    private Long version;
    
    /**
     * COBOL 88-level conditions for ACCT-TYPE
     * 88 ACCT-CURRENT VALUE 'CUR'
     * 88 ACCT-SAVINGS VALUE 'SAV'
     * 88 ACCT-LOAN    VALUE 'LON'
     */
    public enum AccountType {
        CURRENT("CUR"),
        SAVINGS("SAV"),
        LOAN("LON");
        
        private final String code;
        
        AccountType(String code) {
            this.code = code;
        }
        
        public String getCode() {
            return code;
        }
        
        public static AccountType fromCode(String code) {
            for (AccountType type : values()) {
                if (type.code.equals(code.trim())) {
                    return type;
                }
            }
            throw new IllegalArgumentException("Unknown account type: " + code);
        }
    }
    
    /**
     * COBOL 88-level conditions for ACCT-STATUS
     * 88 ACCT-ACTIVE   VALUE 'A'
     * 88 ACCT-INACTIVE VALUE 'I'
     * 88 ACCT-CLOSED   VALUE 'C'
     */
    public enum AccountStatus {
        ACTIVE('A'),
        INACTIVE('I'),
        CLOSED('C');
        
        private final char code;
        
        AccountStatus(char code) {
            this.code = code;
        }
        
        public char getCode() {
            return code;
        }
        
        public static AccountStatus fromCode(char code) {
            for (AccountStatus status : values()) {
                if (status.code == code) {
                    return status;
                }
            }
            throw new IllegalArgumentException("Unknown account status: " + code);
        }
    }
}
