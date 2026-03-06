-- Sample test data for development and testing
-- Corresponds to data that would exist in VSAM files

-- Sample customers (CUSTOMER-FILE)
INSERT INTO customers (customer_id, customer_name, status, balance, open_date) VALUES
(12345678, 'JOHN SMITH                              ', 'A', 1500.00, '2020-01-15'),
(23456789, 'JANE DOE                                ', 'A', 2500.50, '2019-06-22'),
(34567890, 'ROBERT JOHNSON                          ', 'I', 100.00, '2018-03-10'),
(45678901, 'MARY WILLIAMS                           ', 'C', 0.00, '2017-11-05'),
(56789012, 'JAMES BROWN                             ', 'A', 5000.00, '2021-02-28');

-- Sample accounts (ACCOUNT-FILE)
INSERT INTO accounts (account_id, customer_id, account_type, status, balance, credit_limit, open_date, version) VALUES
(1234567890, 12345678, 'CUR', 'A', 1500.00, 5000.00, '2020-01-15', 0),
(2345678901, 23456789, 'SAV', 'A', 2500.50, NULL, '2019-06-22', 0),
(3456789012, 34567890, 'CUR', 'I', 100.00, 1000.00, '2018-03-10', 0),
(4567890123, 45678901, 'CUR', 'C', 0.00, 0.00, '2017-11-05', 0),
(5678901234, 56789012, 'LON', 'A', 5000.00, 10000.00, '2021-02-28', 0);

-- Sample payments (PAYMENT-LOG)
INSERT INTO payments (transaction_id, customer_id, account_id, amount, payment_type, status, timestamp) VALUES
(100000000001, 12345678, 1234567890, 100.00, 'REGULAR', 'APPROVED', '2024-01-15 10:30:00'),
(100000000002, 23456789, 2345678901, 250.50, 'REGULAR', 'APPROVED', '2024-01-15 11:45:00'),
(100000000003, 12345678, 1234567890, 50.00, 'REFUND', 'PENDING', '2024-01-16 09:15:00'),
(100000000004, 56789012, 5678901234, 500.00, 'REGULAR', 'APPROVED', '2024-01-16 14:20:00');
