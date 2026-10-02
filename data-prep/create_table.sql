-- Creates a working database and the NatshvilleHousing table (name spelled as in the script).
-- Column types mirror what the SQL Server Import Wizard creates from the Excel file.
IF DB_ID('NashvillePortfolio') IS NULL CREATE DATABASE NashvillePortfolio;
GO
USE NashvillePortfolio;
GO
DROP TABLE IF EXISTS dbo.NatshvilleHousing;
CREATE TABLE dbo.NatshvilleHousing (
    [UniqueID ] float, ParcelID nvarchar(255), LandUse nvarchar(255), PropertyAddress nvarchar(255),
    SaleDate datetime, SalePrice float, LegalReference nvarchar(255), SoldAsVacant nvarchar(255),
    OwnerName nvarchar(255), OwnerAddress nvarchar(255), Acreage float, TaxDistrict nvarchar(255),
    LandValue float, BuildingValue float, TotalValue float, YearBuilt float,
    Bedrooms float, FullBath float, HalfBath float);
GO
