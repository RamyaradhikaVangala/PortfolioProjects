/* Data Cleaning using SQL Queries  */  
SELECT * FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]

-- Standardizing Date format
SELECT SaleDate 
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]

SELECT SaleDate, CONVERT(Date, SaleDate) UpdatedDate
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]

Update [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Set SaleDate = CONVERT(Date, SaleDate) -- Not updated with "update"
--hence trying with ALTER

ALTER Table [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Add SaleDateConverted Date 
Update [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Set SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address data
SELECT PropertyAddress 
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]

SELECT * 
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]
--where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing] a
Join [SQLPortfolioProject1].[dbo].[NashvilleHousing] b
 on a.ParcelID = b. ParcelID
 AND a.[UniqueID ] <> b. [UniqueID ]
 where a.PropertyAddress is null

 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress)
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing] a
Join [SQLPortfolioProject1].[dbo].[NashvilleHousing] b
 on a.ParcelID = b. ParcelID
 AND a.[UniqueID ] <> b. [UniqueID ]
 where a.PropertyAddress is null

 Update a
 Set 
PropertyAddress = ISNULL(a.PropertyAddress,  b.PropertyAddress)
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing] a
Join [SQLPortfolioProject1].[dbo].[NashvilleHousing] b
 on a.ParcelID = b. ParcelID
 AND a.[UniqueID ] <> b. [UniqueID ]
 where a.PropertyAddress is null

 -- Breaking out Address into Individual Columns (Address, City, State)

 /* Splitting PropertyAddress using Substring*/
SELECT PropertyAddress 
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress)) as Address
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]

ALTER Table [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Add PropertySplitAddress Nvarchar(255) 
Update [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Add PropertySplitCity Nvarchar(255);

Update [SQLPortfolioProject1].[dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From [SQLPortfolioProject1].[dbo].[NashvilleHousing]

/* Splitting OwnerAddress using Parsename*/

Select OwnerAddress
From [SQLPortfolioProject1].[dbo].[NashvilleHousing]

Select
PARSENAME(Replace(OwnerAddress, ',', '.' ) ,3),
PARSENAME(Replace(OwnerAddress, ',', '.' ) ,2),
PARSENAME(Replace(OwnerAddress, ',', '.' ) ,1)
From [SQLPortfolioProject1].[dbo].[NashvilleHousing]

ALTER Table [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(255) 
Update [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.' ) ,3)

ALTER Table [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Add OwnerSplitCity Nvarchar(255) 
Update [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.' ) ,2)

ALTER Table [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Add OwnerSplitState Nvarchar(255) 
Update [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.' ) ,1)

Select *
From [SQLPortfolioProject1].[dbo].[NashvilleHousing]


/* trying substrings for owneraddress to split the address */

SELECT OwnerAddress 
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]


SELECT
    SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1) AS StreetAddress,
    LTRIM(RTRIM(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 1))) AS City,
    RTRIM(LTRIM(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) + 1, LEN(OwnerAddress)))) AS State
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]



-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]

Update [SQLPortfolioProject1].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2


-- Remove Duplicates
With RowNumCTE AS (
SELECT *,
        ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
		ORDER BY
		  UniqueID
		  ) row_num
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]
--order by ParcelID
)
Select *
FROM RowNumCTE
Where row_num>1
Order by PropertyAddress

/* Delete Unused Columns */
Select *
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]

Alter Table [SQLPortfolioProject1].[dbo].[NashvilleHousing]
DROP column PropertyAddress, OwnerAddress, TaxDistrict

Alter Table [SQLPortfolioProject1].[dbo].[NashvilleHousing]
DROP column SaleDate

Select *
FROM [SQLPortfolioProject1].[dbo].[NashvilleHousing]
