-- Data-quality checks. Run before and after CleaningDataSQL.sql to compare.
SET NOCOUNT ON;
SELECT COUNT(*) AS total_rows,
       (SELECT COUNT(*) FROM sys.columns WHERE object_id = OBJECT_ID('dbo.NatshvilleHousing')) AS column_count
FROM dbo.NatshvilleHousing;

IF COL_LENGTH('dbo.NatshvilleHousing', 'PropertyAddress') IS NOT NULL
    EXEC('SELECT COUNT(*) AS null_property_address FROM dbo.NatshvilleHousing WHERE PropertyAddress IS NULL');
ELSE
    EXEC('SELECT COUNT(*) AS null_property_split_address FROM dbo.NatshvilleHousing WHERE PropertySplitAddress IS NULL');

SELECT SoldAsVacant, COUNT(*) AS n FROM dbo.NatshvilleHousing GROUP BY SoldAsVacant ORDER BY n DESC;
