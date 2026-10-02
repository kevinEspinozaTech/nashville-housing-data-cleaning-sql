/*

Cleaning Data in SQL Queries

*/


Select *
From NatshvilleHousing 

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDate, CONVERT(Date,SaleDate) 
From NatshvilleHousing 


Update NatshvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NatshvilleHousing 
Add SaleDateCom date;
GO


Update NatshvilleHousing 
SET SaleDateCom = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NatshvilleHousing 
--Where PropertyAddress is null
order by ParcelID




Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NatshvilleHousing  a
JOIN NatshvilleHousing  b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NatshvilleHousing  a
JOIN NatshvilleHousing  b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From NatshvilleHousing 
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From NatshvilleHousing 


ALTER TABLE NatshvilleHousing 
Add PropertySplitAddress Nvarchar(255);
GO

Update NatshvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NatshvilleHousing 
Add PropertySplitCity Nvarchar(255);
GO

Update NatshvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From NatshvilleHousing 





Select OwnerAddress
From NatshvilleHousing 


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NatshvilleHousing 



ALTER TABLE NatshvilleHousing 
Add OwnerSplitAddress Nvarchar(255);
GO

Update NatshvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NatshvilleHousing 
Add OwnerSplitCity Nvarchar(255);
GO

Update NatshvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NatshvilleHousing 
Add OwnerSplitState Nvarchar(255);
GO

Update NatshvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From NatshvilleHousing 



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NatshvilleHousing 
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NatshvilleHousing 


Update NatshvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

;WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NatshvilleHousing 
)
select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


;WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NatshvilleHousing 
)
delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

;WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NatshvilleHousing 
)
select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From NatshvilleHousing 


ALTER TABLE NatshvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
