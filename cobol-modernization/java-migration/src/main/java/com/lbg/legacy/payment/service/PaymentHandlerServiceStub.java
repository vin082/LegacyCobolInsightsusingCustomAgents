package com.lbg.legacy.payment.service;

import com.lbg.legacy.model.PaymentRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Stub implementation of PaymentHandlerService
 * 
 * TODO: Replace with full implementation after migrating PAYMENT-HANDLER.cbl
 * 
 * This stub allows ACCOUNT-MGR to compile and run during development.
 */
@Slf4j
@Service
public class PaymentHandlerServiceStub implements PaymentHandlerService {
    
    @Override
    public int processPayment(PaymentRequest paymentRequest) {
        log.warn("STUB: PaymentHandlerService.processPayment called with request: {}", 
            paymentRequest);
        log.warn("STUB: This is a placeholder. Implement PAYMENT-HANDLER migration.");
        
        // Stub behavior: always succeed
        return 0;
    }
}
