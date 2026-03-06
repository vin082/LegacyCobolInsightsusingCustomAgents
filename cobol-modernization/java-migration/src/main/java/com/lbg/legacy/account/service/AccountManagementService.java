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

import java.math.BigDecimal;
import java.util.Optional;

/**
 * Main service class replacing COBOL ACCOUNT-MGR program
 * Source: ACCOUNT-MGR.cbl (115 lines, written 1989-07-22 by M.JONES)
 * 
 * Purpose: Core business logic for account management
 * - Validates customers and retrieves their accounts
 * - Updates account status (activate/deactivate/close)
 * - Processes payments by calling PaymentHandlerService
 * 
 * COBOL Structure:
 *   PROGRAM-ID: ACCOUNT-MGR
 *   Called by: CUSTOMER-PROC
 *   Calls: PAYMENT-HANDLER
 *   Files: ACCOUNT-FILE (INDEXED, DYNAMIC access)
 *   Copybooks: CUSTOMER-RECORD, ACCOUNT-RECORD, PAYMENT-RECORD
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AccountManagementService {
    
    private final AccountRepository accountRepository;
    private final PaymentHandlerService paymentHandlerService;
    
    // Return codes matching COBOL WS-RETURN-CODE values
    public static final int SUCCESS = 0;
    public static final int ACCOUNT_NOT_FOUND = 4;
    public static final int FILE_OPEN_ERROR = 8;
    public static final int INVALID_STATUS = 12;
    public static final int FILE_WRITE_ERROR = 16;
    
    /**
     * Main entry point - replaces COBOL 0000-MAIN paragraph
     * COBOL: PROCEDURE DIVISION USING LS-CUSTOMER-REC
     * 
     * Called from CustomerProcessingService (CUSTOMER-PROC)
     * 
     * COBOL Flow:
     *   0000-MAIN.
     *       PERFORM 1000-OPEN-FILES
     *       PERFORM 2000-VALIDATE-CUSTOMER
     *       IF WS-ACCT-FOUND = 'Y'
     *           PERFORM 3000-UPDATE-ACCOUNT
     *           PERFORM 4000-PROCESS-PAYMENT
     *       ELSE
     *           PERFORM 8000-HANDLE-MISSING-ACCOUNT
     *       END-IF
     *       PERFORM 9000-CLOSE-FILES
     *       MOVE WS-RETURN-CODE TO RETURN-CODE
     *       GOBACK.
     * 
     * @param customerRecord customer data from calling program (LINKAGE SECTION)
     * @return return code (0 = success, non-zero = error)
     */
    @Transactional
    public int processCustomerAccount(CustomerRecord customerRecord) {
        log.info("Processing account for customer: {}", customerRecord.getCustomerId());
        
        try {
            // PERFORM 1000-OPEN-FILES
            // Spring @Transactional handles database connection/transaction
            
            // PERFORM 2000-VALIDATE-CUSTOMER
            Optional<Account> accountOpt = validateAndFindAccount(customerRecord);
            
            // IF WS-ACCT-FOUND = 'Y'
            if (accountOpt.isEmpty()) {
                // PERFORM 8000-HANDLE-MISSING-ACCOUNT
                return handleMissingAccount(customerRecord);
            }
            
            Account account = accountOpt.get();
            
            // PERFORM 3000-UPDATE-ACCOUNT
            int updateResult = updateAccountBasedOnCustomerStatus(account, customerRecord);
            if (updateResult != SUCCESS) {
                return updateResult;
            }
            
            // PERFORM 4000-PROCESS-PAYMENT (only for active accounts)
            if (shouldProcessPayment(account)) {
                int paymentResult = processPaymentForAccount(account);
                if (paymentResult != SUCCESS) {
                    return paymentResult;
                }
            }
            
            // PERFORM 9000-CLOSE-FILES
            // Spring @Transactional handles commit/rollback
            
            log.info("Successfully processed account for customer: {}", customerRecord.getCustomerId());
            return SUCCESS;
            
        } catch (Exception e) {
            log.error("Error processing customer account: {}", e.getMessage(), e);
            // Spring @Transactional will rollback on exception
            throw e;
        }
    }
    
    /**
     * Replaces: 2000-VALIDATE-CUSTOMER paragraph (lines 58-65)
     * 
     * COBOL:
     *   2000-VALIDATE-CUSTOMER.
     *       MOVE LS-CUST-ID TO ACCT-CUST-ID
     *       READ ACCOUNT-FILE KEY IS ACCT-CUST-ID
     *           INVALID KEY
     *               MOVE 'N' TO WS-ACCT-FOUND
     *           NOT INVALID KEY
     *               MOVE 'Y' TO WS-ACCT-FOUND
     *       END-READ.
     * 
     * @param customer customer record with CUST-ID to lookup
     * @return Optional containing account if found (WS-ACCT-FOUND = 'Y')
     */
    private Optional<Account> validateAndFindAccount(CustomerRecord customer) {
        log.debug("Validating customer and retrieving account: {}", customer.getCustomerId());
        
        // READ ACCOUNT-FILE KEY IS ACCT-CUST-ID
        Optional<Account> account = accountRepository.findByCustomerId(customer.getCustomerId());
        
        if (account.isPresent()) {
            log.debug("Account found: {} (status: {})", 
                account.get().getAccountId(), 
                account.get().getStatus());
            // WS-ACCT-FOUND = 'Y' (88-level condition)
        } else {
            log.warn("Account not found for customer: {} (WS-FILE-NOTFND condition)", 
                customer.getCustomerId());
            // WS-ACCT-FOUND = 'N', WS-FILE-NOTFND = true
        }
        
        return account;
    }
    
    /**
     * Replaces: 3000-UPDATE-ACCOUNT paragraph (lines 67-75)
     * 
     * COBOL:
     *   3000-UPDATE-ACCOUNT.
     *       EVALUATE LS-CUST-STATUS
     *           WHEN 'A'
     *               PERFORM 3100-ACTIVATE-ACCOUNT
     *           WHEN 'I'
     *               PERFORM 3200-DEACTIVATE-ACCOUNT
     *           WHEN 'C'
     *               PERFORM 3300-CLOSE-ACCOUNT
     *           WHEN OTHER
     *               MOVE 12 TO WS-RETURN-CODE
     *       END-EVALUATE.
     * 
     * @param account account to update
     * @param customer customer record with status
     * @return return code (0 = success, 12 = invalid status)
     */
    private int updateAccountBasedOnCustomerStatus(Account account, CustomerRecord customer) {
        log.debug("Updating account {} based on customer status: {}", 
            account.getAccountId(), customer.getStatus());
        
        // EVALUATE LS-CUST-STATUS
        switch (customer.getStatus()) {
            case ACTIVE:
                // WHEN 'A' PERFORM 3100-ACTIVATE-ACCOUNT
                return activateAccount(account);
                
            case INACTIVE:
                // WHEN 'I' PERFORM 3200-DEACTIVATE-ACCOUNT
                return deactivateAccount(account);
                
            case CLOSED:
                // WHEN 'C' PERFORM 3300-CLOSE-ACCOUNT
                return closeAccount(account);
                
            default:
                // WHEN OTHER MOVE 12 TO WS-RETURN-CODE
                log.error("Invalid customer status: {}", customer.getStatus());
                return INVALID_STATUS;
        }
    }
    
    /**
     * Replaces: 3100-ACTIVATE-ACCOUNT paragraph (lines 77-82)
     * 
     * COBOL:
     *   3100-ACTIVATE-ACCOUNT.
     *       MOVE 'A' TO ACCT-STATUS
     *       REWRITE ACCOUNT-REC
     *       IF NOT WS-FILE-OK
     *           MOVE 16 TO WS-RETURN-CODE
     *       END-IF.
     * 
     * @param account account to activate
     * @return return code (0 = success, 16 = write error)
     */
    private int activateAccount(Account account) {
        log.info("Activating account: {}", account.getAccountId());
        
        try {
            // MOVE 'A' TO ACCT-STATUS
            account.setStatus(Account.AccountStatus.ACTIVE);
            
            // REWRITE ACCOUNT-REC
            accountRepository.save(account);
            
            log.debug("Account activated successfully");
            return SUCCESS;
            
        } catch (Exception e) {
            // IF NOT WS-FILE-OK
            log.error("Failed to activate account {}: {}", account.getAccountId(), e.getMessage());
            return FILE_WRITE_ERROR;
        }
    }
    
    /**
     * Replaces: 3200-DEACTIVATE-ACCOUNT paragraph (lines 84-89)
     * 
     * COBOL:
     *   3200-DEACTIVATE-ACCOUNT.
     *       MOVE 'I' TO ACCT-STATUS
     *       REWRITE ACCOUNT-REC
     *       IF NOT WS-FILE-OK
     *           MOVE 16 TO WS-RETURN-CODE
     *       END-IF.
     * 
     * @param account account to deactivate
     * @return return code (0 = success, 16 = write error)
     */
    private int deactivateAccount(Account account) {
        log.info("Deactivating account: {}", account.getAccountId());
        
        try {
            // MOVE 'I' TO ACCT-STATUS
            account.setStatus(Account.AccountStatus.INACTIVE);
            
            // REWRITE ACCOUNT-REC
            accountRepository.save(account);
            
            log.debug("Account deactivated successfully");
            return SUCCESS;
            
        } catch (Exception e) {
            // IF NOT WS-FILE-OK
            log.error("Failed to deactivate account {}: {}", account.getAccountId(), e.getMessage());
            return FILE_WRITE_ERROR;
        }
    }
    
    /**
     * Replaces: 3300-CLOSE-ACCOUNT paragraph (lines 91-97)
     * 
     * COBOL:
     *   3300-CLOSE-ACCOUNT.
     *       MOVE 'C' TO ACCT-STATUS
     *       MOVE ZEROES TO ACCT-BALANCE
     *       REWRITE ACCOUNT-REC
     *       IF NOT WS-FILE-OK
     *           MOVE 16 TO WS-RETURN-CODE
     *       END-IF.
     * 
     * @param account account to close
     * @return return code (0 = success, 16 = write error)
     */
    private int closeAccount(Account account) {
        log.info("Closing account: {}", account.getAccountId());
        
        try {
            // MOVE 'C' TO ACCT-STATUS
            account.setStatus(Account.AccountStatus.CLOSED);
            
            // MOVE ZEROES TO ACCT-BALANCE
            account.setBalance(BigDecimal.ZERO);
            
            // REWRITE ACCOUNT-REC
            accountRepository.save(account);
            
            log.debug("Account closed successfully");
            return SUCCESS;
            
        } catch (Exception e) {
            // IF NOT WS-FILE-OK
            log.error("Failed to close account {}: {}", account.getAccountId(), e.getMessage());
            return FILE_WRITE_ERROR;
        }
    }
    
    /**
     * Business rule: only process payments for active accounts
     * This logic is implied in the COBOL but not explicitly stated
     */
    private boolean shouldProcessPayment(Account account) {
        return account.getStatus() == Account.AccountStatus.ACTIVE 
            && account.getBalance().compareTo(BigDecimal.ZERO) > 0;
    }
    
    /**
     * Replaces: 4000-PROCESS-PAYMENT paragraph (lines 99-107)
     * 
     * COBOL:
     *   4000-PROCESS-PAYMENT.
     *       MOVE LS-CUST-ID    TO PAY-CUST-ID
     *       MOVE ACCT-BALANCE  TO PAY-AMOUNT
     *       MOVE 'REGULAR'     TO PAY-TYPE
     *       CALL 'PAYMENT-HANDLER' USING WS-PAYMENT-REQUEST
     *                                    WS-RETURN-CODE
     *       IF WS-RETURN-CODE NOT = ZERO
     *           PERFORM 8000-HANDLE-MISSING-ACCOUNT
     *       END-IF.
     * 
     * @param account account to process payment for
     * @return return code from payment handler
     */
    private int processPaymentForAccount(Account account) {
        log.debug("Processing payment for account: {}", account.getAccountId());
        
        // Build WS-PAYMENT-REQUEST working storage structure
        PaymentRequest paymentRequest = new PaymentRequest();
        paymentRequest.setCustomerId(account.getCustomerId());      // MOVE LS-CUST-ID TO PAY-CUST-ID
        paymentRequest.setAccountId(account.getAccountId());
        paymentRequest.setAmount(account.getBalance());             // MOVE ACCT-BALANCE TO PAY-AMOUNT
        paymentRequest.setType(PaymentRequest.PaymentType.REGULAR); // MOVE 'REGULAR' TO PAY-TYPE
        paymentRequest.setStatus(PaymentRequest.PaymentStatus.PENDING);
        
        // CALL 'PAYMENT-HANDLER' USING WS-PAYMENT-REQUEST WS-RETURN-CODE
        int returnCode = paymentHandlerService.processPayment(paymentRequest);
        
        // IF WS-RETURN-CODE NOT = ZERO
        if (returnCode != SUCCESS) {
            log.error("Payment processing failed with return code: {}", returnCode);
            // PERFORM 8000-HANDLE-MISSING-ACCOUNT (error handling)
            return returnCode;
        }
        
        log.debug("Payment processed successfully");
        return SUCCESS;
    }
    
    /**
     * Replaces: 8000-HANDLE-MISSING-ACCOUNT paragraph (lines 109-110)
     * 
     * COBOL:
     *   8000-HANDLE-MISSING-ACCOUNT.
     *       MOVE 4 TO WS-RETURN-CODE.
     * 
     * @param customer customer record that was not found
     * @return return code 4 (not found)
     */
    private int handleMissingAccount(CustomerRecord customer) {
        log.error("Account not found for customer: {}", customer.getCustomerId());
        
        // MOVE 4 TO WS-RETURN-CODE
        return ACCOUNT_NOT_FOUND;
    }
}
