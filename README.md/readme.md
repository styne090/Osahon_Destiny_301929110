# MIT 8103 Advanced Database Systems Portfolio
**Student Name:** Destiny Osahon  
**Student ID:** 301929110  
**Institution:** MIVA Open University  
**Session:** 2026/2027 Academic Session — First Semester  

---

## 1. Case Study Overview
* **Organisation Name:** SwiftPay Financial Services
* **Nature of Business:** A modern digital wallet and payment processing platform facilitating instant peer-to-peer (P2P) transfers, multi-currency account management, merchant payments, and automated audit logging.
* **Target Users:** Retail & Merchant Customers, Financial Compliance Officers, System Administrators.
* **Key Database Operations:** Fund transfers, balance updates, transaction history aggregation, fraud detection telemetry, and multi-region data synchronization.

---

## 2. Repository Structure
```text
Osahon_Destiny_301929110/
├── portfolio-1-database-design/
│   └── database_schema.sql
├── portfolio-2-query-optimisation/
│   └── query_optimisation.sql
├── portfolio-3-transactions-concurrency/
│   └── transaction_concurrency.sql
├── portfolio-4-nosql/
│   └── user_activity_nosql.py
├── portfolio-5-distributed-cloud/
│   └── distributed_architecture.sql
├── Osahon_Destiny_301929110_LMS_Documentation.md
└── README.md
```

---

## 3. Summary of Portfolio Modules

### Portfolio 1: Database Design and Modelling
* Implemented a fully normalised 3NF database schema for core ledger tables (`Customers`, `Accounts`, `Merchants`, `Transactions`, `AuditLogs`).
* Established foreign key constraints, default value checks, and strict data type definitions.

### Portfolio 2: Query Processing and Optimisation
* Wrote complex analytical queries utilizing window functions (`SUM() OVER`) and multi-table joins.
* Optimized execution plans by replacing high-cost clustered index scans with non-clustered covering indexes (`IX_Transactions_Timestamp_Status`).

### Portfolio 3: Transactions and Concurrency
* Developed a transaction-safe T-SQL stored procedure (`ExecuteP2PTransfer`) demonstrating strict ACID compliance.
* Utilized explicit locking (`UPDLOCK`, `HOLDLOCK`) to prevent race conditions, dirty reads, and lost updates during concurrent operations.

### Portfolio 4: NoSQL and Advanced Data Models
* Designed a polyglot persistence architecture utilizing MongoDB for unstructured, high-velocity user activity and security telemetry logs.
* Implemented aggregation pipelines and embedded document schemas for quick fraud analysis.

### Portfolio 5: Distributed and Cloud Database Strategy
* Designed a multi-region distributed cloud database architecture utilizing hash sharding on `customer_id`.
* Evaluated CAP theorem trade-offs, electing CP (Consistency & Partition Tolerance) for financial transaction ledgers.