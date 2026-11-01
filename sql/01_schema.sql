-- Fuel station sales database (DKU coursework, 2022)
-- Microsoft SQL Server / T-SQL
--
-- Changes from the 2022 original: comments translated to English;
-- fuel_name changed from varchar to nvarchar so the Cyrillic fuel names
-- are stored correctly on any server collation. Otherwise as submitted.

-- sqlcmd starts with QUOTED_IDENTIFIER OFF (SSMS turns it ON); the persisted
-- computed column Note.summ requires ON, also inside procedures that write to Note.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE DATABASE course;
GO
USE course;
GO

CREATE TABLE Note -- sales log: one row per sale
(
    id_note    tinyint IDENTITY PRIMARY KEY NOT NULL,
    fk_fuel    tinyint NOT NULL,
    liters     smallint CHECK (liters > 0 AND liters < 300) NOT NULL,
    liter_cost int CHECK (liter_cost > 0) NOT NULL,   -- price per litre at the moment of sale, KZT
    summ       AS (liters * liter_cost) PERSISTED,     -- computed total of the sale
    pay_time   datetime NOT NULL,                      -- time of payment
    rowver     rowversion                              -- optimistic concurrency
);

CREATE TABLE Fuel -- fuel catalogue
(
    id_fuel   tinyint IDENTITY PRIMARY KEY NOT NULL,
    fuel_name nvarchar(10) NOT NULL,   -- fuel grade
    cost      int NOT NULL,            -- current price per litre, KZT
    actual    datetime NOT NULL,       -- when the current price was set
    rowver    rowversion
);

-- Relationship: many sales -> one fuel grade
ALTER TABLE Note
ADD CONSTRAINT FK_Relevance_ID FOREIGN KEY (fk_fuel) REFERENCES Fuel (id_fuel);

-- Index for look-ups by fuel name
CREATE INDEX INDEX_fuel ON Fuel (fuel_name);
GO
