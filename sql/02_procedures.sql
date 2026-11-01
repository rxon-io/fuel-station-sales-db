-- Stored procedures (DKU coursework, 2022)
-- Comments translated to English; @fuel_name changed to nvarchar to match the table.

-- sqlcmd starts with QUOTED_IDENTIFIER OFF (SSMS turns it ON); the persisted
-- computed column Note.summ requires ON, also inside procedures that write to Note.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE course;
GO

-- pr_Fuel: insert / update / delete a fuel grade
-- @choice: 1 = insert, 2 = update, 3 = delete
-- @num:    id of the row to update or delete
CREATE PROCEDURE pr_Fuel
    @id          tinyint OUTPUT,
    @fuel_name   nvarchar(10),
    @cost        int,
    @err         int OUTPUT,
    @err_message varchar(100) OUTPUT,
    @choice      tinyint,
    @num         tinyint
AS
IF @choice = 1 -- insert
BEGIN TRY
    DECLARE @actual date
    SELECT @actual = getdate()
    INSERT INTO Fuel (fuel_name, cost, actual)
    VALUES (@fuel_name, @cost, @actual)
    SELECT @id = @@IDENTITY
END TRY
BEGIN CATCH
    SELECT @err = error_number(), @err_message = error_message()
END CATCH

IF @choice = 2 -- update
BEGIN TRY
    UPDATE Fuel
    SET fuel_name = @fuel_name, cost = @cost, actual = getdate()
    WHERE id_fuel = @num
END TRY
BEGIN CATCH
    SELECT @err = error_number(), @err_message = error_message()
END CATCH

IF @choice = 3 -- delete
BEGIN TRY
    DELETE FROM Fuel
    WHERE id_fuel = @num
END TRY
BEGIN CATCH
    SELECT @err = error_number(), @err_message = error_message()
END CATCH
GO

-- pr_Note: record a sale. The current price is copied from Fuel into the sale,
-- so the total of a past sale does not change when the price changes later.
CREATE PROCEDURE pr_Note
    @id          tinyint OUTPUT,
    @fk_fuel     tinyint,
    @liters      smallint,
    @err         int OUTPUT,
    @err_message varchar(100) OUTPUT,
    @choice      tinyint,
    @num         tinyint
AS
BEGIN TRY
    DECLARE @liter_cost int
    SELECT @liter_cost = cost FROM Fuel
    WHERE id_fuel = @fk_fuel

    DECLARE @pay_time datetime
    SET @pay_time = getdate()

    INSERT INTO Note (fk_fuel, liters, liter_cost, pay_time)
    VALUES (@fk_fuel, @liters, @liter_cost, @pay_time)
    SELECT @id = @@IDENTITY
END TRY
BEGIN CATCH
    SELECT @err = error_number(), @err_message = error_message()
END CATCH
GO
