/*Define the CustomerDim table, if not already created*/
CREATE TABLE CustomerDim (
    CustomerID INT,
    CustomerName VARCHAR(100),
    Address VARCHAR(100),
    EffectiveStartDate DATE,
    EffectiveEndDate DATE,
    IsCurrent BIT
);

/*Next, we'll create the trigger trg_dim */
CREATE TRIGGER trg_dim
ON CustomerDim
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @CustomerID INT, @CustomerName VARCHAR(100), @Address VARCHAR(100);

    DECLARE cur CURSOR FOR
    SELECT CustomerID, CustomerName, Address
    FROM inserted;

    OPEN cur;
    FETCH NEXT FROM cur INTO @CustomerID, @CustomerName, @Address;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM CustomerDim WHERE CustomerID = @CustomerID AND IsCurrent = 1)
        BEGIN
            UPDATE CustomerDim
            SET EffectiveEndDate = DATEADD(day, -1, CONVERT(DATE, GETDATE())), IsCurrent = 0
            WHERE CustomerID = @CustomerID AND IsCurrent = 1;

            INSERT INTO CustomerDim (CustomerID, CustomerName, Address, EffectiveStartDate, EffectiveEndDate, IsCurrent)
            VALUES (@CustomerID, @CustomerName, @Address, CONVERT(DATE, GETDATE()), '9999-12-31', 1);
        END
        ELSE
        BEGIN
            INSERT INTO CustomerDim (CustomerID, CustomerName, Address, EffectiveStartDate, EffectiveEndDate, IsCurrent)
            VALUES (@CustomerID, @CustomerName, @Address, CONVERT(DATE, GETDATE()), '9999-12-31', 1);
        END

        FETCH NEXT FROM cur INTO @CustomerID, @CustomerName, @Address;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

/*Now, let's insert the initial records */
INSERT INTO CustomerDim (CustomerID, CustomerName, Address, EffectiveStartDate, EffectiveEndDate, IsCurrent)
VALUES
    (1, 'John Doe', '123 Main St', '2023-01-01', '9999-12-31', 1),
    (2, 'Alice Johnson', '456 Elm St', '2023-01-01', '9999-12-31', 1),
    (3, 'Bob Smith', '789 Oak St', '2023-01-01', '9999-12-31', 1);

/*Finally, insert the new records to test the trigger */
INSERT INTO CustomerDim (CustomerID, CustomerName, Address)
VALUES
    (1, 'John Doe', 'Ajmer'),
    (4, 'David Richard', 'Mumbai'),
    (3, 'Bob Smith', 'Chennai'),
    (5, 'Eva Dsouza', 'Mumbai');



