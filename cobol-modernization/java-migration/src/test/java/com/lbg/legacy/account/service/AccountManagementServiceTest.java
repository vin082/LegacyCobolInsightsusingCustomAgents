package com.lbg.legacy.account.service;

import com.lbg.legacy.account.repository.AccountRepository;
import com.lbg.legacy.model.Account;
import com.lbg.legacy.model.CustomerRecord;
import com.lbg.legacy.model.PaymentRequest;
import com.lbg.legacy.payment.service.PaymentHandlerService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Unit tests for AccountManagementService
 * Tests the Java implementation against COBOL ACCOUNT-MGR behavior
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("AccountManagementService - COBOL ACCOUNT-MGR Migration Tests")
class AccountManagementServiceTest {
    
    @Mock
    private AccountRepository accountRepository;
    
    @Mock
    private PaymentHandlerService paymentHandlerService;
    
    @InjectMocks
    private AccountManagementService service;
    
    private CustomerRecord activeCustomer;
    private Account testAccount;
    
    @BeforeEach
    void setUp() {
        // Setup test customer (CUSTOMER-RECORD)
        activeCustomer = new CustomerRecord();
        activeCustomer.setCustomerId(12345678L);
        activeCustomer.setCustomerName("John Smith");
        activeCustomer.setStatus(CustomerRecord.CustomerStatus.ACTIVE);
        activeCustomer.setBalance(new BigDecimal("1000.00"));
        activeCustomer.setOpenDate(LocalDate.of(2020, 1, 1));
        
        // Setup test account (ACCOUNT-RECORD)
        testAccount = new Account();
        testAccount.setAccountId(1234567890L);
        testAccount.setCustomerId(12345678L);
        testAccount.setAccountType(Account.AccountType.CURRENT);
        testAccount.setStatus(Account.AccountStatus.INACTIVE);
        testAccount.setBalance(new BigDecimal("1500.50"));
        testAccount.setCreditLimit(new BigDecimal("5000.00"));
        testAccount.setOpenDate(LocalDate.of(2020, 1, 1));
    }
    
    @Test
    @DisplayName("Should activate account when customer status is ACTIVE (3100-ACTIVATE-ACCOUNT)")
    void shouldActivateAccountWhenCustomerIsActive() {
        // Given - COBOL setup equivalent
        when(accountRepository.findByCustomerId(activeCustomer.getCustomerId()))
            .thenReturn(Optional.of(testAccount));
        when(paymentHandlerService.processPayment(any())).thenReturn(0);
        
        // When - PERFORM 0000-MAIN
        int returnCode = service.processCustomerAccount(activeCustomer);
        
        // Then - Verify COBOL behavior
        assertThat(returnCode).isEqualTo(AccountManagementService.SUCCESS);
        assertThat(testAccount.getStatus()).isEqualTo(Account.AccountStatus.ACTIVE);
        
        // Verify REWRITE ACCOUNT-REC
        verify(accountRepository).save(testAccount);
        
        // Verify CALL 'PAYMENT-HANDLER' was made
        verify(paymentHandlerService).processPayment(any(PaymentRequest.class));
    }
    
    @Test
    @DisplayName("Should deactivate account when customer status is INACTIVE (3200-DEACTIVATE-ACCOUNT)")
    void shouldDeactivateAccountWhenCustomerIsInactive() {
        // Given
        activeCustomer.setStatus(CustomerRecord.CustomerStatus.INACTIVE);
        testAccount.setStatus(Account.AccountStatus.ACTIVE);
        
        when(accountRepository.findByCustomerId(activeCustomer.getCustomerId()))
            .thenReturn(Optional.of(testAccount));
        
        // When - PERFORM 3200-DEACTIVATE-ACCOUNT
        int returnCode = service.processCustomerAccount(activeCustomer);
        
        // Then
        assertThat(returnCode).isEqualTo(AccountManagementService.SUCCESS);
        assertThat(testAccount.getStatus()).isEqualTo(Account.AccountStatus.INACTIVE);
        verify(accountRepository).save(testAccount);
        
        // Payment should NOT be processed for inactive accounts
        verify(paymentHandlerService, never()).processPayment(any());
    }
    
    @Test
    @DisplayName("Should close account and zero balance when customer status is CLOSED (3300-CLOSE-ACCOUNT)")
    void shouldCloseAccountAndZeroBalanceWhenCustomerIsClosed() {
        // Given
        activeCustomer.setStatus(CustomerRecord.CustomerStatus.CLOSED);
        testAccount.setStatus(Account.AccountStatus.ACTIVE);
        testAccount.setBalance(new BigDecimal("999.99"));
        
        when(accountRepository.findByCustomerId(activeCustomer.getCustomerId()))
            .thenReturn(Optional.of(testAccount));
        
        // When - PERFORM 3300-CLOSE-ACCOUNT
        int returnCode = service.processCustomerAccount(activeCustomer);
        
        // Then - MOVE 'C' TO ACCT-STATUS, MOVE ZEROES TO ACCT-BALANCE
        assertThat(returnCode).isEqualTo(AccountManagementService.SUCCESS);
        assertThat(testAccount.getStatus()).isEqualTo(Account.AccountStatus.CLOSED);
        assertThat(testAccount.getBalance()).isEqualByComparingTo(BigDecimal.ZERO);
        verify(accountRepository).save(testAccount);
        
        // Payment should NOT be processed for closed accounts
        verify(paymentHandlerService, never()).processPayment(any());
    }
    
    @Test
    @DisplayName("Should return error code 4 when account not found (8000-HANDLE-MISSING-ACCOUNT)")
    void shouldHandleMissingAccount() {
        // Given - READ ... INVALID KEY
        when(accountRepository.findByCustomerId(activeCustomer.getCustomerId()))
            .thenReturn(Optional.empty());
        
        // When - PERFORM 8000-HANDLE-MISSING-ACCOUNT
        int returnCode = service.processCustomerAccount(activeCustomer);
        
        // Then - MOVE 4 TO WS-RETURN-CODE
        assertThat(returnCode).isEqualTo(AccountManagementService.ACCOUNT_NOT_FOUND);
        
        // No updates should be attempted
        verify(accountRepository, never()).save(any());
        verify(paymentHandlerService, never()).processPayment(any());
    }
    
    @Test
    @DisplayName("Should build correct payment request (4000-PROCESS-PAYMENT)")
    void shouldBuildCorrectPaymentRequest() {
        // Given
        testAccount.setStatus(Account.AccountStatus.ACTIVE);
        testAccount.setBalance(new BigDecimal("2500.75"));
        
        when(accountRepository.findByCustomerId(activeCustomer.getCustomerId()))
            .thenReturn(Optional.of(testAccount));
        when(paymentHandlerService.processPayment(any())).thenReturn(0);
        
        // When
        service.processCustomerAccount(activeCustomer);
        
        // Then - Capture and verify WS-PAYMENT-REQUEST
        ArgumentCaptor<PaymentRequest> captor = ArgumentCaptor.forClass(PaymentRequest.class);
        verify(paymentHandlerService).processPayment(captor.capture());
        
        PaymentRequest request = captor.getValue();
        assertThat(request.getCustomerId()).isEqualTo(testAccount.getCustomerId());
        assertThat(request.getAccountId()).isEqualTo(testAccount.getAccountId());
        assertThat(request.getAmount()).isEqualByComparingTo(testAccount.getBalance());
        assertThat(request.getType()).isEqualTo(PaymentRequest.PaymentType.REGULAR);
        assertThat(request.getStatus()).isEqualTo(PaymentRequest.PaymentStatus.PENDING);
    }
    
    @Test
    @DisplayName("Should not process payment when balance is zero")
    void shouldNotProcessPaymentWhenBalanceIsZero() {
        // Given
        testAccount.setStatus(Account.AccountStatus.ACTIVE);
        testAccount.setBalance(BigDecimal.ZERO);
        
        when(accountRepository.findByCustomerId(activeCustomer.getCustomerId()))
            .thenReturn(Optional.of(testAccount));
        
        // When
        int returnCode = service.processCustomerAccount(activeCustomer);
        
        // Then - Business rule: no payment for zero balance
        assertThat(returnCode).isEqualTo(AccountManagementService.SUCCESS);
        verify(paymentHandlerService, never()).processPayment(any());
    }
    
    @Test
    @DisplayName("Should handle payment handler failure")
    void shouldHandlePaymentHandlerFailure() {
        // Given
        testAccount.setStatus(Account.AccountStatus.ACTIVE);
        
        when(accountRepository.findByCustomerId(activeCustomer.getCustomerId()))
            .thenReturn(Optional.of(testAccount));
        when(paymentHandlerService.processPayment(any())).thenReturn(99); // Error code
        
        // When
        int returnCode = service.processCustomerAccount(activeCustomer);
        
        // Then - IF WS-RETURN-CODE NOT = ZERO
        assertThat(returnCode).isNotEqualTo(AccountManagementService.SUCCESS);
        assertThat(returnCode).isEqualTo(99);
    }
    
    @Test
    @DisplayName("COMP-3 BigDecimal precision test")
    void shouldHandleComp3PrecisionCorrectly() {
        // Given - Test COMP-3 PIC S9(11)V99 precision
        BigDecimal balance = new BigDecimal("99999999999.99");
        testAccount.setBalance(balance);
        testAccount.setStatus(Account.AccountStatus.ACTIVE);
        
        when(accountRepository.findByCustomerId(activeCustomer.getCustomerId()))
            .thenReturn(Optional.of(testAccount));
        when(paymentHandlerService.processPayment(any())).thenReturn(0);
        
        // When
        service.processCustomerAccount(activeCustomer);
        
        // Then - Verify no precision loss
        ArgumentCaptor<PaymentRequest> captor = ArgumentCaptor.forClass(PaymentRequest.class);
        verify(paymentHandlerService).processPayment(captor.capture());
        
        PaymentRequest request = captor.getValue();
        assertThat(request.getAmount())
            .isEqualByComparingTo(balance)
            .hasScale(2); // COMP-3 PIC V99 = 2 decimal places
    }
}
