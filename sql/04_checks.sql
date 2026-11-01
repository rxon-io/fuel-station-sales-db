-- Checks for the design decisions described in README.
-- Run after 01-03. Everything happens inside one transaction that is rolled back
-- at the end, so the demo data stays unchanged and the script can be re-run.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO
USE course;
GO

BEGIN TRANSACTION;

DECLARE @id tinyint, @err int, @msg varchar(100);
DECLARE @summ_before int, @summ_after int, @cost_after int;

-- 1. The CHECK constraint rejects a sale of 300 litres
BEGIN TRY
    INSERT INTO Note (fk_fuel, liters, liter_cost, pay_time)
    VALUES (1, 300, 170, GETDATE());
    PRINT 'FAIL 1: a 300-litre sale was accepted';
END TRY
BEGIN CATCH
    PRINT 'PASS 1: 300-litre sale rejected (error ' + CAST(ERROR_NUMBER() AS varchar(10)) + ')';
END CATCH;

-- 2. pr_Note returns an error through its output parameters instead of failing
EXEC pr_Note @id OUTPUT, 99, 10, @err OUTPUT, @msg OUTPUT, 1, NULL;
IF @err IS NOT NULL
    PRINT 'PASS 2: pr_Note returned error ' + CAST(@err AS varchar(10)) + ': ' + @msg;
ELSE
    PRINT 'FAIL 2: pr_Note recorded a sale for a fuel grade that does not exist';

-- 3. Changing a price does not change past sales (demo sale id_note = 1, LPG)
SELECT @summ_before = summ FROM Note WHERE id_note = 1;
SELECT @err = NULL, @msg = NULL;
EXEC pr_Fuel @id OUTPUT, N'Газ', 80, @err OUTPUT, @msg OUTPUT, 2, 5;
SELECT @cost_after = cost FROM Fuel WHERE id_fuel = 5;
SELECT @summ_after = summ FROM Note WHERE id_note = 1;
IF @cost_after = 80 AND @summ_after = @summ_before
    PRINT 'PASS 3: LPG price is now 80, the past sale still totals ' + CAST(@summ_after AS varchar(10));
ELSE
    PRINT 'FAIL 3: price ' + ISNULL(CAST(@cost_after AS varchar(10)), 'NULL')
        + ', sale total before ' + ISNULL(CAST(@summ_before AS varchar(10)), 'NULL')
        + ', after ' + ISNULL(CAST(@summ_after AS varchar(10)), 'NULL');

-- 4. The total is computed by the database and cannot be written directly.
-- Dynamic SQL, because this error is raised at compile time and would otherwise
-- stop the whole batch before TRY...CATCH runs.
BEGIN TRY
    EXEC (N'UPDATE Note SET summ = 1 WHERE id_note = 1');
    PRINT 'FAIL 4: summ was overwritten';
END TRY
BEGIN CATCH
    PRINT 'PASS 4: summ cannot be written directly (error ' + CAST(ERROR_NUMBER() AS varchar(10)) + ')';
END CATCH;

IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
PRINT 'All changes rolled back.';
GO
