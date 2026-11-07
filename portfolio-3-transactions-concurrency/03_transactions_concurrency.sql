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
        SELECT @CurrentBalance = balance 
        FROM Accounts WITH (UPDLOCK, HOLDLOCK) 
        WHERE account_number = @SourceAccount;

        IF @CurrentBalance < @TransferAmount
        BEGIN
            RAISERROR('Insufficient funds in source account.', 16, 1);
        END

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
    END CATCH
END;