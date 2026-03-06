package com.lbg.legacy.payment.service;

import com.lbg.legacy.model.PaymentRequest;

/**
 * Service interface for PaymentHandlerService
 * Replaces: COBOL PAYMENT-HANDLER program
 * Source: PAYMENT-HANDLER.cbl
 * 
 * This is a stub interface for the ACCOUNT-MGR migration.
 * Full implementation requires migrating PAYMENT-HANDLER.cbl
 * 
 * COBOL Interface:
 *   CALL 'PAYMENT-HANDLER' USING LS-PAYMENT-REQUEST LS-RETURN-CODE
 */
public interface PaymentHandlerService {
    
    /**
     * Process a payment request
     * 
     * Replaces: CALL 'PAYMENT-HANDLER' USING WS-PAYMENT-REQUEST WS-RETURN-CODE
     * 
     * COBOL LINKAGE SECTION parameters:
     * - LS-PAYMENT-REQUEST (PAYMENT-RECORD copybook)
     * - LS-RETURN-CODE (PIC S9(4) COMP)
     * 
     * @param paymentRequest payment to process
     * @return return code (0 = success, non-zero = error)
     */
    int processPayment(PaymentRequest paymentRequest);
}
