-- Cleaning Data using SQL Queries

-- Displaying all columns

select * from NashvilleHousing

-- The SaleDate column has unnecessary timestamp that needs to be removed.

select SaleDate from NashvilleHousing

-- Convert SaleDate into Date type

alter table NashvilleHousing
alter column SaleDate Date;

-- Update SaleDate

update NashvilleHousing set SaleDate = CONVERT(Date, SaleDate)

select SaleDate from NashvilleHousing

-- Next column to clean is Property Address

select PropertyAddress from NashvilleHousing where PropertyAddress is null

-- PropertyAddress column has some null values in it. We need to populate this with some values. 

select ParcelID, PropertyAddress from NashvilleHousing

/*

If you look into the corresponding Parcel IDs of a Property Address, we can see that similar Parcel IDs also have the
similar Property Addresses. We can now use this knowledge to populate the column.

*/

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a join NashvilleHousing b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- We will use the ISNULL function to populate the PropertyAddress.

Update a set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select PropertyAddress from NashvilleHousing where PropertyAddress is null

-- With all the null values filled, we now want to breakdown PropertyAddress into its individual parts

select PropertyAddress from NashvilleHousing

/* 

We can split this column by using PARSENAME function, but the function only works if the column is delimited by
periods. Therefore, we need to replace the commas with periods.

*/

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing set PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',','.'),1)
update NashvilleHousing set PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',','.'),2)

select PropertyAddress, PropertySplitCity, PropertySplitAddress from NashvilleHousing

-- We will now do the same to OwnerAddress

select OwnerAddress from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
update NashvilleHousing set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
update NashvilleHousing set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

select OwnerSplitState, OwnerSplitAddress, OwnerSplitCity from NashvilleHousing

-- Next column to clean is SoldAsVacant.

select SoldAsVacant, COUNT(SoldAsVacant) from NashvilleHousing group by SoldAsVacant

-- As we can see, the values are not uniform. So, we have to change the values Y and N to Yes or No.

update NashvilleHousing set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' when SoldAsVacant = 'N' then 'No' 
else SoldAsVacant end

select distinct(SoldAsVacant) from NashvilleHousing

-- Now, we will need to remove some duplicate rows. 

With RowNumCTE as(select *, ROW_NUMBER() Over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, 
LegalReference order by UniqueID) row_num from NashvilleHousing)

delete from RowNumCTE where row_num > 1 -- If row_num is greater than 1, then it is a duplicate.

With RowNumCTE as(select *, ROW_NUMBER() Over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, 
LegalReference order by UniqueID) row_num from NashvilleHousing)

select * from RowNumCTE where row_num > 1 

-- Now, the data is cleaned.
