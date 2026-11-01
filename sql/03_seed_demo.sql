-- Demo data (DKU coursework, 2022): five fuel grades with 2022 prices in KZT
-- and one test sale. The original script ended with DROP DATABASE after the
-- demo run; that line is left out so the database stays available.

-- sqlcmd starts with QUOTED_IDENTIFIER OFF (SSMS turns it ON); the persisted
-- computed column Note.summ requires ON, also inside procedures that write to Note.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE course;
GO

DECLARE
    @id          tinyint,
    @err         int,
    @err_message varchar(100)
BEGIN
    DECLARE @F1 varchar(5)
    EXECUTE pr_Fuel @id OUTPUT, N'АИ-92', 170, @err OUTPUT, @err_message OUTPUT, 1, NULL
    SET @F1 = @id
    IF @err IS NOT NULL AND @err_message IS NOT NULL
        SELECT @err, @err_message
    SELECT @err = NULL, @err_message = NULL

    DECLARE @F2 varchar(5)
    EXECUTE pr_Fuel @id OUTPUT, N'АИ-95', 210, @err OUTPUT, @err_message OUTPUT, 1, NULL
    SET @F2 = @id
    IF @err IS NOT NULL AND @err_message IS NOT NULL
        SELECT @err, @err_message
    SELECT @err = NULL, @err_message = NULL

    DECLARE @F3 varchar(5)
    EXECUTE pr_Fuel @id OUTPUT, N'АИ-98', 235, @err OUTPUT, @err_message OUTPUT, 1, NULL
    SET @F3 = @id
    IF @err IS NOT NULL AND @err_message IS NOT NULL
        SELECT @err, @err_message
    SELECT @err = NULL, @err_message = NULL

    DECLARE @F4 varchar(5)
    EXECUTE pr_Fuel @id OUTPUT, N'ДТ', 280, @err OUTPUT, @err_message OUTPUT, 1, NULL
    SET @F4 = @id
    IF @err IS NOT NULL AND @err_message IS NOT NULL
        SELECT @err, @err_message
    SELECT @err = NULL, @err_message = NULL

    DECLARE @F5 varchar(5)
    EXECUTE pr_Fuel @id OUTPUT, N'Газ', 70, @err OUTPUT, @err_message OUTPUT, 1, NULL
    SET @F5 = @id
    IF @err IS NOT NULL AND @err_message IS NOT NULL
        SELECT @err, @err_message
    SELECT @err = NULL, @err_message = NULL
END
BEGIN
    -- test sale: 10 litres of LPG (id_fuel = 5)
    DECLARE @N1 varchar(5)
    EXECUTE pr_Note @id OUTPUT, 5, 10, @err OUTPUT, @err_message OUTPUT, 1, NULL
    SET @N1 = @id
    IF @err IS NOT NULL AND @err_message IS NOT NULL
        SELECT @err, @err_message
    SELECT @err = NULL, @err_message = NULL
END

SELECT * FROM Fuel;
SELECT * FROM Note;
GO
