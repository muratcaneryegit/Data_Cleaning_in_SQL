SELECT *
FROM Nashville

SELECT SaleDate,CAST(SaleDate AS Date)
FROM Nashville

ALTER TABLE Nashville
ADD SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted=CAST(SaleDate AS Date)


SELECT *
FROM Nashville


SELECT PropertyAddress
FROM Nashville


--Populating Property Adress Data

SELECT PropertyAddress
FROM Nashville
WHERE PropertyAddress IS NULL

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,COALESCE(a.PropertyAddress,b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.ParcelID=b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress=COALESCE(a.PropertyAddress,b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.ParcelID=b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking Out The Address Into Individual Columns(Address,City,State)

--PropertyAddress Column
SELECT PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM Nashville

ALTER TABLE Nashville
ADD PropertySplitAddress NVARCHAR(255)

UPDATE Nashville
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville
ADD PropertySplitCity NVARCHAR(255)

UPDATE Nashville
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 

--- OwnerAddress Column

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashville

ALTER TABLE Nashville
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE Nashville
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville
ADD OwnerSplitCity NVARCHAR(255)

UPDATE Nashville
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville
ADD OwnerSplitState NVARCHAR(255)

UPDATE Nashville
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

---Changing Y and N To Yes and No in SoldasVacant column

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No' ELSE SoldAsVacant END
FROM Nashville

UPDATE Nashville
SET SoldAsVacant=CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No' ELSE SoldAsVacant END
FROM Nashville

--Removing Duplicates
WITH RowNumCTE AS(
SELECT *,ROW_NUMBER() OVER(PARTITION BY
ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) AS Row_Num
FROM Nashville)

DELETE
FROM RowNumCTE
WHERE Row_Num>1

---Deleting Unused Columns

ALTER TABLE Nashville
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress

