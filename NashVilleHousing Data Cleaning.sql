SELECT *
FROM PortfolioProject..NashVilleSheet

-- Standardize Date Format 

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashVilleSheet;

UPDATE NashVilleSheet
SET  SaleDate = CONVERT(Date,SaleDate) 

--Populate Property Address
SELECT PropertyAddress, ParcelID
FROM PortfolioProject..NashVilleSheet
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashVilleSheet a
JOIN PortfolioProject..NashVilleSheet b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashVilleSheet a
JOIN PortfolioProject..NashVilleSheet b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashVilleSheet

ALTER TABLE NashVilleSheet
Add PropertySplitAddress Nvarchar(255);

Update NashVilleSheet
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashVilleSheet
Add PropertySplitCity Nvarchar(255);

Update NashVilleSheet
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM NashVilleSheet

--ALternatively

Select OwnerAddress
From PortfolioProject..NashVilleSheet


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject..NashVilleSheet

ALTER TABLE NashVilleSheet
Add OwnerSplitAddress Nvarchar(255);

Update NashVilleSheet
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashVilleSheet
Add OwnerSplitCity Nvarchar(255);

Update NashVilleSheet
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashVilleSheet
Add OwnerSplitState Nvarchar(255);

Update NashVilleSheet
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM NashVilleSheet

-- -- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashVilleSheet
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NashVilleSheet

Update NashVilleSheet
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates

WITH RowNumCTE AS(
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

From PortfolioProject..NashVilleSheet
)


Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Delete Unused Columns
SELECT *
FROM NashVilleSheet

ALTER TABLE PortfolioProject..NashVilleSheet
DROP COLUMN Owneraddress, TaxDistrict, PropertyAddress, SaleDate,SaleDateConvert


