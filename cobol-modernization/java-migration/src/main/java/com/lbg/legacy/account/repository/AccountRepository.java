package com.lbg.legacy.account.repository;

import com.lbg.legacy.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;

/**
 * Spring Data JPA Repository for Account entity
 * Replaces: COBOL ACCOUNT-FILE (INDEXED file with DYNAMIC access)
 * Source: ACCOUNT-MGR.cbl FILE-CONTROL section
 * 
 * COBOL Definition:
 *   SELECT ACCOUNT-FILE ASSIGN TO ACCTMAST
 *     ORGANIZATION IS INDEXED
 *     ACCESS MODE IS DYNAMIC
 *     RECORD KEY IS ACCT-ID
 *     FILE STATUS IS WS-FILE-STATUS
 */
@Repository
public interface AccountRepository extends JpaRepository<Account, Long> {
    
    /**
     * Replaces: READ ACCOUNT-FILE KEY IS ACCT-CUST-ID (line 60)
     * COBOL: MOVE LS-CUST-ID TO ACCT-CUST-ID
     *        READ ACCOUNT-FILE KEY IS ACCT-CUST-ID
     *            INVALID KEY MOVE 'N' TO WS-ACCT-FOUND
     *            NOT INVALID KEY MOVE 'Y' TO WS-ACCT-FOUND
     * 
     * Dynamic access mode allows reading by alternate key (customer_id)
     * Optional handles INVALID KEY condition (empty = not found)
     */
    Optional<Account> findByCustomerId(Long customerId);
    
    /**
     * Additional query for finding accounts by status
     * Useful for batch processing and reporting
     */
    List<Account> findByStatus(Account.AccountStatus status);
    
    /**
     * Find accounts by customer and status
     * Composite query for more specific lookups
     */
    Optional<Account> findByCustomerIdAndStatus(Long customerId, Account.AccountStatus status);
    
    /**
     * Pessimistic locking for REWRITE operations
     * Replaces: VSAM record locking during REWRITE
     * COBOL: REWRITE ACCOUNT-REC
     * 
     * Prevents concurrent modification issues by locking the row
     * Use this when you need to read-modify-write atomically
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT a FROM Account a WHERE a.accountId = :accountId")
    Optional<Account> findByAccountIdForUpdate(@Param("accountId") Long accountId);
    
    /**
     * Count accounts by status
     * Useful for reporting and validation
     */
    long countByStatus(Account.AccountStatus status);
    
    /**
     * Check if an account exists for a customer
     * Lightweight existence check without loading full entity
     * Replaces: READ ... NOT INVALID KEY check
     */
    boolean existsByCustomerId(Long customerId);
}
