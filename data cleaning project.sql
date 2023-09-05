/*

cleaning nashville housing data

*/

select*
from NashvilleHousing$

-----------------------------------------------------

--Standardize Data Format

select SaleDateConverted, convert(date,saledate)
from NashvilleHousing$

ALTER TABLE NashvilleHousing$
Add SaleDateConverted Date;

Update NashvilleHousing$
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------
--Populate Property Address data

select*
from NashvilleHousing$
--where PropertyAddress is not null
order by ParcelID

--order by ParcelID

select tab1.ParcelID, tab1.PropertyAddress, tab2.ParcelID, tab2.PropertyAddress, isnull(tab1.PropertyAddress,tab2.PropertyAddress)
from NashvilleHousing$ tab1 join NashvilleHousing$ tab2
on tab1.ParcelID = tab2.ParcelID and
tab1.[UniqueID ] <> tab2.[UniqueID ]
where tab1.PropertyAddress is null 

update tab1
set PropertyAddress = isnull(tab1.PropertyAddress,tab2.PropertyAddress)
from NashvilleHousing$ tab1 join NashvilleHousing$ tab2
on tab1.ParcelID = tab2.ParcelID and
tab1.[UniqueID ] <> tab2.[UniqueID ]
where tab1.PropertyAddress is null 




-------------------------------------------------------------------------------------------------


--Breaking out Address into Individual Colums (Address, City, State)

select PropertyAddress
from NashvilleHousing$
--where PropertyAddress is not null
--order by ParcelID

select SUBSTRING(propertyAddress, 1, CHARINDEX(',',propertyaddress)-1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',',propertyaddress)+1, Len(propertyaddress)) as Address
from NashvilleHousing$



ALTER TABLE NashvilleHousing$
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',',propertyaddress)-1)


ALTER TABLE NashvilleHousing$
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing$
SET PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',',propertyaddress)+1, Len(propertyaddress))


select*
From NashvilleHousing$


--select OwnerAddress
--from NashvilleHousing$

select
PARSENAME(replace(owneraddress, ',' , '.') , 3),
PARSENAME(replace(owneraddress, ',' , '.') , 2),
PARSENAME(replace(owneraddress, ',' , '.') , 1)
from nashvillehousing$

ALTER TABLE NashvilleHousing$
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(replace(owneraddress, ',' , '.') , 3)

ALTER TABLE NashvilleHousing$
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitCity = PARSENAME(replace(owneraddress, ',' , '.') , 2)

ALTER TABLE NashvilleHousing$
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitState = PARSENAME(replace(owneraddress, ',' , '.') , 1)

----------------------------------------------------------------------------------------------------------------------------------
--changing Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant),Count(SoldAsVacant)
from NashvilleHousing$
group by SoldAsVacant
order by 2

select Soldasvacant,
case when Soldasvacant = 'Y' then 'Yes'
	when Soldasvacant = 'N' then 'No'
	else SoldAsVacant
	end
from NashvilleHousing$

update NashvilleHousing$
set SoldAsVacant = case when Soldasvacant = 'Y' then 'Yes'
	when Soldasvacant = 'N' then 'No'
	else SoldAsVacant
	end





----------------------------------------------------------------------------------------------------------

--Removing Duplicates

with RomNumCTE as (
select*,
ROW_NUMBER()over(
Partition by parcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID
) row_num


from NashvilleHousing$
--order by ParcelID
)
select*
from RomNumCTE
where row_num > 1
order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

select*
from NashvilleHousing$

Alter Table NashvilleHousing$
drop column OwnerAddress, Taxdistrict, PropertyAddress, SaleDate



