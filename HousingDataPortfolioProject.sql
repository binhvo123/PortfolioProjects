SELECT *
FROM PortfolioProject.dbo.HousingData

--Standardize Date Format (Remove unnecessary timestamp) 

Select SaleDate, CONVERT(Date, SaleDate) as SaleDateConverted
FROM PortfolioProject.dbo.HousingData

UPDATE PortfolioProject.dbo.HousingData
SET SaleDate = CONVERT(Date, SaleDate)

--Wouldn't Update Properly

ALTER TABLE HousingData
ADD SaleDateConverted Date

UPDATE PortfolioProject.dbo.HousingData
SET SaleDate = CONVERT(Date, SaleDate)

SELECT * 
FROM PortfolioProject.dbo.HousingData

-- Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.HousingData
WHERE PropertyAddress is null

-- Issue: Some parcelID's have a null address associated with them
-- Solution: Check to see if there are duplicate ParcelID's to see if the duplicate has an address, then map it to the missing ParcelID

--Find Null PropertyAddresses

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
	on a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--Fix Null PropertyAddresses

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.HousingData a
JOIN PortfolioProject.dbo.HousingData b
	on a.parcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-- Breaking Out Addresses into Individual Columns 

SELECT PropertyAddress
FROM PortfolioProject.dbo.HousingData

--Get rid of the comma

SELECT*
FROM PortfolioProject.dbo.HousingData

--Separate Property Address into strings before and after the comma

SELECT  
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.HousingData

--Update our table with this new information, creating two new columns 

ALTER TABLE PortfolioProject.dbo.HousingData
ADD StreetAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD CityAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET CityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Separate Property Address into strings before and after the comma (different method)

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM PortfolioProject.dbo.HousingData

ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerStreetAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerCityAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerStateAddress Nvarchar(255)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

-- Cleaned Address for use

SELECT UniqueID, ParcelId, LandUse, OwnerStreetAddress, OwnerCityAddress, OwnerStateAddress, SaleDate
FROM PortfolioProject.dbo.HousingData

-- Change Y and N to 'yes' and 'no' in 'Sold as Vacant' Field using a case statement 

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.HousingData
GROUP BY SoldAsVacant
Order By 2

-- See comparison columns with old and new data

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.HousingData

-- Now update the table with cleaned values

UPDATE PortfolioProject.dbo.HousingData
SET SoldAsVacant = 	
	CASE 
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END


-- Remove Duplicates


WITH RowNumCTE AS( 
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate, 
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject.dbo.HousingData
--ORDER BY ParcelID
)

SELECT *
FROM PortfolioProject.dbo.HousingData

DELETE 
FROM RowNumCTE
WHERE row_num > 1 

--Delete Unused Columns

SELECT * 
FROM PortfolioProject.dbo.HousingData

ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


