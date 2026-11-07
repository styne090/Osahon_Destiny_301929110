-- 1. Customers Table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    kyc_status VARCHAR(20) CHECK (kyc_status IN ('Pending', 'Verified', 'Rejected')) DEFAULT 'Pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Accounts Table
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

-- 3. Transactions Table
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