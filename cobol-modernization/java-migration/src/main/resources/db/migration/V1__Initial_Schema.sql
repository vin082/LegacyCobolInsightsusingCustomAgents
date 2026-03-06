-- Database schema for COBOL migration
-- Replaces VSAM files with PostgreSQL tables

-- Accounts table (replaces ACCOUNT-FILE)
-- Source: ACCOUNT-RECORD.cpy
CREATE TABLE IF NOT EXISTS accounts (
    account_id      BIGINT PRIMARY KEY,
    customer_id     BIGINT NOT NULL,
    account_type    VARCHAR(3) NOT NULL CHECK (account_type IN ('CUR', 'SAV', 'LON')),
    status          CHAR(1) NOT NULL CHECK (status IN ('A', 'I', 'C')),
    balance         NUMERIC(13,2) NOT NULL DEFAULT 0.00,  -- PIC S9(11)V99 COMP-3
    credit_limit    NUMERIC(11,2),                        -- PIC S9(9)V99 COMP-3
    open_date       DATE,
    version         BIGINT NOT NULL DEFAULT 0,            -- Optimistic locking
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for ACCOUNT-FILE (replaces VSAM indexed file keys)
CREATE INDEX IF NOT EXISTS idx_account_customer ON accounts(customer_id);
CREATE INDEX IF NOT EXISTS idx_account_status ON accounts(status);
CREATE INDEX IF NOT EXISTS idx_account_type ON accounts(account_type);

-- Comments
COMMENT ON TABLE accounts IS 'Replaces COBOL ACCOUNT-FILE (INDEXED, DYNAMIC access)';
COMMENT ON COLUMN accounts.account_id IS 'ACCT-ID PIC 9(10) - Primary key';
COMMENT ON COLUMN accounts.customer_id IS 'ACCT-CUST-ID PIC 9(8) - Foreign key to customers';
COMMENT ON COLUMN accounts.account_type IS 'ACCT-TYPE PIC X(3) - CUR/SAV/LON';
COMMENT ON COLUMN accounts.status IS 'ACCT-STATUS PIC X - A/I/C';
COMMENT ON COLUMN accounts.balance IS 'ACCT-BALANCE PIC S9(11)V99 COMP-3 - CRITICAL: Use BigDecimal';
COMMENT ON COLUMN accounts.credit_limit IS 'ACCT-LIMIT PIC S9(9)V99 COMP-3 - CRITICAL: Use BigDecimal';
COMMENT ON COLUMN accounts.open_date IS 'ACCT-OPEN-DATE PIC 9(8) - Format YYYYMMDD';

-- Customers table (replaces CUSTOMER-FILE)
-- Source: CUSTOMER-RECORD.cpy
CREATE TABLE IF NOT EXISTS customers (
    customer_id     BIGINT PRIMARY KEY,
    customer_name   VARCHAR(40) NOT NULL,
    status          CHAR(1) NOT NULL CHECK (status IN ('A', 'I', 'C')),
    balance         NUMERIC(11,2) NOT NULL DEFAULT 0.00,  -- PIC S9(9)V99
    open_date       DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_customer_status ON customers(status);
CREATE INDEX IF NOT EXISTS idx_customer_name ON customers(customer_name);

COMMENT ON TABLE customers IS 'Replaces COBOL CUSTOMER-FILE (SEQUENTIAL)';
COMMENT ON COLUMN customers.customer_id IS 'CUST-ID PIC 9(8)';
COMMENT ON COLUMN customers.customer_name IS 'CUST-NAME PIC X(40)';
COMMENT ON COLUMN customers.status IS 'CUST-STATUS PIC X - A/I/C';

-- Payments table (replaces PAYMENT-LOG)
-- Source: PAYMENT-RECORD.cpy
CREATE TABLE IF NOT EXISTS payments (
    transaction_id  BIGINT PRIMARY KEY,
    customer_id     BIGINT NOT NULL,
    account_id      BIGINT,
    amount          NUMERIC(11,2) NOT NULL,  -- PIC S9(9)V99 COMP-3
    payment_type    VARCHAR(10) NOT NULL CHECK (payment_type IN ('REGULAR', 'REFUND', 'REVERSAL')),
    status          VARCHAR(10) NOT NULL CHECK (status IN ('APPROVED', 'PENDING', 'REVERSED', 'REJECTED')),
    timestamp       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payment_customer ON payments(customer_id);
CREATE INDEX IF NOT EXISTS idx_payment_account ON payments(account_id);
CREATE INDEX IF NOT EXISTS idx_payment_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payment_timestamp ON payments(timestamp);

COMMENT ON TABLE payments IS 'Replaces COBOL PAYMENT-LOG (SEQUENTIAL)';
COMMENT ON COLUMN payments.amount IS 'PAY-AMOUNT PIC S9(9)V99 COMP-3 - CRITICAL: Use BigDecimal';

-- Foreign key constraints
ALTER TABLE accounts ADD CONSTRAINT fk_account_customer 
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
    
ALTER TABLE payments ADD CONSTRAINT fk_payment_customer 
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
    
ALTER TABLE payments ADD CONSTRAINT fk_payment_account 
    FOREIGN KEY (account_id) REFERENCES accounts(account_id);

-- Audit trigger for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_accounts_updated_at BEFORE UPDATE ON accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
