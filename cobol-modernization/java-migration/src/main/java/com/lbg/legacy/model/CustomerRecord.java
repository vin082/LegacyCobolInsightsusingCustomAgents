package com.lbg.legacy.model;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Data Transfer Object mapping from COBOL CUSTOMER-RECORD copybook
 * Replaces: LINKAGE SECTION LS-CUSTOMER-REC in ACCOUNT-MGR
 * Source: CUSTOMER-RECORD.cpy
 * 
 * Note: This is a DTO, not a JPA entity, as it's passed between services
 */
@Data
public class CustomerRecord {
    
    /**
     * COBOL: 05 CUST-ID PIC 9(8)
     * 8-digit customer identifier
     */
    private Long customerId;
    
    /**
     * COBOL: 05 CUST-NAME PIC X(40)
     * Customer name - remember to trim() when reading from COBOL
     */
    private String customerName;
    
    /**
     * COBOL: 05 CUST-STATUS PIC X
     * Customer status: A (Active), I (Inactive), C (Closed)
     * 88-level conditions mapped to enum
     */
    private CustomerStatus status;
    
    /**
     * COBOL: 05 CUST-BALANCE PIC S9(9)V99
     * Customer balance (not COMP-3 in this copybook)
     */
    private BigDecimal balance;
    
    /**
     * COBOL: 05 CUST-OPEN-DATE PIC 9(8)
     * Format: YYYYMMDD → LocalDate
     */
    private LocalDate openDate;
    
    /**
     * COBOL 88-level conditions for CUST-STATUS
     * 88 CUST-ACTIVE   VALUE 'A'
     * 88 CUST-INACTIVE VALUE 'I'
     * 88 CUST-CLOSED   VALUE 'C'
     */
    public enum CustomerStatus {
        ACTIVE('A'),
        INACTIVE('I'),
        CLOSED('C');
        
        private final char code;
        
        CustomerStatus(char code) {
            this.code = code;
        }
        
        public char getCode() {
            return code;
        }
        
        public static CustomerStatus fromCode(char code) {
            for (CustomerStatus status : values()) {
                if (status.code == code) {
                    return status;
                }
            }
            throw new IllegalArgumentException("Unknown customer status: " + code);
        }
    }
}
