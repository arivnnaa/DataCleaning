Select *
from dbo.nashvillehouse

--Standardize Date format

Select SaleDate, convert(date, saledate)
from dbo.nashvillehouse

UPDATE nashvillehouse 
SET SaleDate = convert(date, saledate)


-- Populate Property Adress data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.nashvillehouse a
JOIN dbo.nashvillehouse b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
  

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.nashvillehouse a
JOIN dbo.nashvillehouse b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
   

--Breaking out Address into individual columns (Address, City, State)

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(PropertyAddress)) as City
from dbo.nashvillehouse

ALTER TABLE dbo.nashvillehouse
Add PropertySplitAddress Nvarchar(255)

UPDATE dbo.nashvillehouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', propertyaddress) -1)

ALTER TABLE dbo.nashvillehouse
Add PropertySplitCity Nvarchar(255)

UPDATE dbo.nashvillehouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', propertyaddress) +1, LEN(PropertyAddress))

SELECT *
from dbo.nashvillehouse


--Breaking out OwnerAddress into individual columns (Address, City, State)

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as Address
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as State
from dbo.nashvillehouse

ALTER TABLE dbo.nashvillehouse
Add OwnerSplitAddress Nvarchar(255)

UPDATE dbo.nashvillehouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) 

ALTER TABLE dbo.nashvillehouse
Add OwnerSplitCity Nvarchar(255)

UPDATE dbo.nashvillehouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) 

ALTER TABLE dbo.nashvillehouse
Add OwnerSplitState Nvarchar(255)

UPDATE dbo.nashvillehouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) 

Select *
from nashvillehouse


-- Change Y and N to Yes and No in SoldAsVacant

Select distinct (SoldAsVacant)
from nashvillehouse


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from nashvillehouse

Update nashvillehouse
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove duplicates

WITH RowNumbCTE as(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
             ORDER BY UniqueID) row_num
from nashvillehouse
)
DELETE
from RowNumbCTE
where row_num > 1


--Delete unused columns

ALTER TABLE dbo.nashvillehouse
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select *
from nashvillehouse



