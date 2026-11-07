-- High-Volume Transaction Summary
SELECT 
    c.customer_id,
    c.first_name + ' ' + c.last_name AS customer_name,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_transaction_volume,
    t.currency
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
JOIN Transactions t ON a.account_number = t.source_account
WHERE t.timestamp >= DATEADD(month, -1, GETDATE())
  AND t.status = 'Completed'
GROUP BY c.customer_id, c.first_name, c.last_name, t.currency
HAVING SUM(t.amount) > 1000.00
ORDER BY total_transaction_volume DESC;

-- Indexing Optimisation
CREATE NONCLUSTERED INDEX IX_Transactions_Timestamp_Status 
ON Transactions (timestamp, status) 
INCLUDE (source_account, destination_account, amount, currency);