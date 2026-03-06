package com.lbg.legacy.model;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Data Transfer Object mapping from COBOL PAYMENT-RECORD copybook
 * Replaces: WS-PAYMENT-REQUEST in ACCOUNT-MGR working storage
 * Source: PAYMENT-RECORD.cpy
 * 
 * Used to pass payment data to PaymentHandlerService (PAYMENT-HANDLER program)
 */
@Data
public class PaymentRequest {
    
    /**
     * COBOL: 05 PAY-TRANS-ID PIC 9(12)
     * 12-digit transaction identifier
     */
    private Long transactionId;
    
    /**
     * COBOL: 05 PAY-CUST-ID PIC 9(8)
     * Customer identifier - populated from LS-CUST-ID
     */
    private Long customerId;
    
    /**
     * COBOL: 05 PAY-ACCT-ID PIC 9(10)
     * Account identifier
     */
    private Long accountId;
    
    /**
     * COBOL: 05 PAY-AMOUNT PIC S9(9)V99 COMP-3
     * CRITICAL: COMP-3 packed decimal → BigDecimal
     * Populated from ACCT-BALANCE in 4000-PROCESS-PAYMENT
     */
    private BigDecimal amount;
    
    /**
     * COBOL: 05 PAY-TYPE PIC X(10)
     * Payment type: REGULAR, REFUND, REVERSAL
     * 88-level conditions mapped to enum
     */
    private PaymentType type;
    
    /**
     * COBOL: 05 PAY-STATUS PIC X(10)
     * Payment status: APPROVED, PENDING, REVERSED, REJECTED
     * 88-level conditions mapped to enum
     */
    private PaymentStatus status;
    
    /**
     * COBOL: 05 PAY-TIMESTAMP PIC X(26)
     * Timestamp of payment processing
     */
    private LocalDateTime timestamp;
    
    /**
     * COBOL 88-level conditions for PAY-TYPE
     * 88 PAY-REGULAR  VALUE 'REGULAR   '
     * 88 PAY-REFUND   VALUE 'REFUND    '
     * 88 PAY-REVERSAL VALUE 'REVERSAL  '
     */
    public enum PaymentType {
        REGULAR("REGULAR   "),
        REFUND("REFUND    "),
        REVERSAL("REVERSAL  ");
        
        private final String code;
        
        PaymentType(String code) {
            this.code = code;
        }
        
        public String getCode() {
            return code;
        }
        
        public static PaymentType fromCode(String code) {
            String normalized = code.trim();
            for (PaymentType type : values()) {
                if (type.code.trim().equals(normalized)) {
                    return type;
                }
            }
            throw new IllegalArgumentException("Unknown payment type: " + code);
        }
    }
    
    /**
     * COBOL 88-level conditions for PAY-STATUS
     * 88 PAY-APPROVED VALUE 'APPROVED  '
     * 88 PAY-PENDING  VALUE 'PENDING   '
     * 88 PAY-REVERSED VALUE 'REVERSED  '
     * 88 PAY-REJECTED VALUE 'REJECTED  '
     */
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
        
        public static PaymentStatus fromCode(String code) {
            String normalized = code.trim();
            for (PaymentStatus status : values()) {
                if (status.code.trim().equals(normalized)) {
                    return status;
                }
            }
            throw new IllegalArgumentException("Unknown payment status: " + code);
        }
    }
}
