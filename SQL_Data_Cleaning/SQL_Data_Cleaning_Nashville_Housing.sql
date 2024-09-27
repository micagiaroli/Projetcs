-- Cleaning Data in SQL Queries

SELECT *
FROM NashvilleHousing

-----------------------------------------------------------------------------------------------

-- Standarize Data Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE; 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM NashvilleHousing;

-----------------------------------------------------------------------------------------------

-- Populate Property Address data (with info from the same ParcelID)

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-----------------------------------------------------------------------------------------------

--Breaking out PropertyAddress into Individual Columns (Address, City)

SELECT PropertyAddress
FROM NashvilleHousing;

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255); 

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255); 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


-----------------------------------------------------------------------------------------------

--Breaking out OwnerAddress into Individual Columns (Address, City, State)

SELECT OwnerAddress
FROM NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255); 

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);


-----------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

-----------------------------------------------------------------------------------------------

-- Remove Duplicates (Normally we don't delete data)
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM NashvilleHousing)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;

-- Checking for removed duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM NashvilleHousing)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1;


-----------------------------------------------------------------------------------------------

-- Delete Unused Columns (Normally we don't delete raw data)

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;

SELECT * 
FROM NashvilleHousing;
