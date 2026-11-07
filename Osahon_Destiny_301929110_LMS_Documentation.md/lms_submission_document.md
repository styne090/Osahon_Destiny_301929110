# Continuous Assessment Report: Advanced Database Systems Portfolio

**Course Code:** MIT 8103

**Course Title:** Advanced Database Systems

**Student Name:** Destiny Osahon

**Student ID:** 301929110

**Degree Program:** Master of Information Technology

**Academic Session:** 2026/2027 Academic Session — First Semester

**GitHub Repository Link:** `https://github.com/DestinyOsahon/Osahon_Destiny_301929110`

## 1. Case Study Selection and Business Context

For this portfolio assessment, **SwiftPay Financial Services** was chosen as the operational case study. SwiftPay is a cloud-native fintech platform designed to facilitate low-latency peer-to-peer (P2P) transfers, digital wallet management, multi-currency transactions, and merchant payment processing.

### Operational Requirements:

* **Primary Database Users:** Retail customers, merchants, system administrators, and fraud auditors.

* **Core Data Managed:** User identification (KYC), account balances, transaction ledgers, activity logs, and settlement summaries.

* **Critical System Drivers:** Zero tolerance for double-spending, strictly enforced ACID transaction processing, low-latency transaction querying, and horizontal scalability for regional growth.

## 2. Technical Summary of Portfolio Modules

### Portfolio 1: Database Design & Modelling

The baseline schema was built around five core entity types: `Customers`, `Accounts`, `Merchants`, `Transactions`, and `AuditLogs`.

```
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    kyc_status VARCHAR(20) CHECK (kyc_status IN ('Pending', 'Verified', 'Rejected')) DEFAULT 'Pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Accounts (
    account_number VARCHAR(20) PRIMARY KEY,
    customer_id INT NOT NULL,
    account_type VARCHAR(20) CHECK (account_type IN ('Savings', 'Current', 'Wallet')) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD' NOT NULL,
    balance DECIMAL(18, 4) CHECK (balance >= 0.0000) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Active', 'Frozen', 'Closed')) DEFAULT 'Active',
    opened_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Customer_Account FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE Transactions (
    transaction_id VARCHAR(36) PRIMARY KEY,
    source_account VARCHAR(20) NULL,
    destination_account VARCHAR(20) NOT NULL,
    amount DECIMAL(18, 4) CHECK (amount > 0) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    transaction_type VARCHAR(20) CHECK (transaction_type IN ('Transfer', 'Deposit', 'Withdrawal', 'Payment')) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Pending', 'Completed', 'Failed', 'Reversed')) DEFAULT 'Pending',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Source_Account FOREIGN KEY (source_account) REFERENCES Accounts(account_number),
    CONSTRAINT FK_Dest_Account FOREIGN KEY (destination_account) REFERENCES Accounts(account_number)
);

```

#### Normalisation Justification:

* **1NF:** Ensured all attributes contain atomic values and every table possesses a primary key.

* **2NF:** Removed partial key dependencies; non-key columns strictly depend on the entire primary key.

* **3NF:** Eliminated transitive dependencies by separating customer demographic data from account balances.

### Portfolio 2: Query Processing & Optimisation

To process large volumes of transaction records efficiently, targeted SQL queries and indexing strategies were designed.

#### Optimised Windowed Query (Running Balance Generation):

```
SELECT 
    transaction_id,
    timestamp,
    transaction_type,
    amount,
    currency,
    status,
    SUM(CASE WHEN destination_account = 'ACC123456789' THEN amount ELSE -amount END) 
        OVER (PARTITION BY source_account ORDER BY timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_balance
FROM Transactions
WHERE source_account = 'ACC123456789' OR destination_account = 'ACC123456789'
ORDER BY timestamp DESC;

```

#### Indexing Strategy & Performance Tuning:

Initial execution plans indicated high-cost sequential scans on the `Transactions` table when filtering by timestamp and status. Creating a composite covering index resolved this bottleneck:

```
CREATE NONCLUSTERED INDEX IX_Transactions_Timestamp_Status 
ON Transactions (timestamp, status) 
INCLUDE (source_account, destination_account, amount, currency);

```

**Result:** Execution plan converted from full table scan to an index seek, drastically reducing disk I/O and query execution duration.

### Portfolio 3: Transactions & Concurrency

Financial transfers require absolute atomicity. A T-SQL stored procedure was implemented using explicit transactions and update locking to prevent race conditions during concurrent user access.

```
CREATE PROCEDURE ExecuteP2PTransfer
    @SourceAccount VARCHAR(20),
    @DestAccount VARCHAR(20),
    @TransferAmount DECIMAL(18, 4),
    @Currency VARCHAR(3),
    @TransactionID VARCHAR(36)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @CurrentBalance DECIMAL(18, 4);
        
        -- Acquire explicit update lock to eliminate race conditions
        SELECT @CurrentBalance = balance 
        FROM Accounts WITH (UPDLOCK, HOLDLOCK) 
        WHERE account_number = @SourceAccount;

        IF @CurrentBalance < @TransferAmount
            RAISERROR('Insufficient funds.', 16, 1);

        UPDATE Accounts SET balance = balance - @TransferAmount WHERE account_number = @SourceAccount;
        UPDATE Accounts SET balance = balance + @TransferAmount WHERE account_number = @DestAccount;

        INSERT INTO Transactions (transaction_id, source_account, destination_account, amount, currency, transaction_type, status)
        VALUES (@TransactionID, @SourceAccount, @DestAccount, @TransferAmount, @Currency, 'Transfer', 'Completed');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        INSERT INTO Transactions (transaction_id, source_account, destination_account, amount, currency, transaction_type, status)
        VALUES (@TransactionID, @SourceAccount, @DestAccount, @TransferAmount, @Currency, 'Transfer', 'Failed');
        THROW;
    END CATCH
END;

```

### Portfolio 4: NoSQL and Advanced Data Models

To store unstructured user security activity and device telemetry without straining relational tables, MongoDB document modeling was introduced (**Polyglot Persistence**).

#### Sample Document Structure (`user_activity_logs`):

```
{
  "_id": "65f4a12c8e3b2a1a2b3c4d5e",
  "customer_id": 10492,
  "device_info": { "device_id": "DEV_IOS_98234", "os": "iOS 18.2" },
  "session_metadata": { "ip_address": "192.168.1.45", "login_timestamp": "2026-11-07T08:30:00Z" },
  "activity_events": [
    { "event_id": "EVT_7722", "action": "INITIATE_TRANSFER", "amount": 150.00 }
  ]
}

```

### Portfolio 5: Distributed and Cloud Database Exercise

To support regional growth across global nodes:

* **Sharding Strategy:** Hash partitioning on **`customer_id`** ensures all accounts and transactions associated with a given customer reside on the same logical shard, eliminating cross-shard join costs.

* **CAP Theorem Application:** SwiftPay adheres to **CP (Consistency and Partition Tolerance)** for real-money transfers to prevent double spending. Non-critical analytical streams use **AP (Eventual Consistency)** to maintain high availability.

## 3. Individual Technical Reflection

Designing and implementing the database framework for SwiftPay provided practical insight into the complexities of modern database architecture. Key lessons include:

1. **Trade-offs of Indexing:** While covering indexes eliminate lookup overhead during analytical queries, excessive indexing impairs write speed during peak transaction processing. Balancing index selection requires clear workload profiling.

2. **Concurrency Hazards:** Enforcing default transaction isolation levels is often insufficient for financial systems. Utilizing explicit pessimistic locking (`UPDLOCK`, `HOLDLOCK`) is essential to prevent race conditions during simultaneous user withdrawals.

3. **Polyglot Architecture:** Relational engines excel at strict consistency ledger management, whereas document databases excel at high-throughput telemetry ingestion. Combining both strategies leverages the unique strengths of each engine.

## 4. AI Use Declaration

* **AI Tool Used:** Gemini (Google)

* **Purpose of Tool Use:** Brainstorming database design choices, refining schema definitions, reviewing stored procedure syntax, and structuring portfolio documentation.

* **Verification & Understanding:** All generated SQL scripts, MongoDB queries, normalisation logic, and distributed strategies were manually evaluated, tested for execution validity, and verified against core database theory by the student.

## 5. References

1. Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database System Concepts* (7th ed.). McGraw-Hill Education.

2. Elmasri, R., & Navathe, S. B. (2015). *Fundamentals of Database Systems* (7th ed.). Pearson.

3. Kleppmann, M. (2017). *Designing Data-Intensive Applications*. O'Reilly Media.