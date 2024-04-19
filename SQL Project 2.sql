/*

cleaning Sata in SQL Queries

*/

select *
from PortfolioProject..NashvelliHousing



----------------------------------------------------------------------------------------------------------------
-- Standardize Data Format
--Standardize Data Format
select SaleDateConverted, cast(saledate as date)
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDate=cast(saledate as date)

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted Date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted=cast(saledate as date)



----------------------------------------------------------------------------------------------------------------
-- Populate Property address date
select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID 
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID=b.ParcelID 
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null



----------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from PortfolioProject..NashvilleHousing


select 
substring(PropertyAddress,1,charindex(',', PropertyAddress)-1) Address
, substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) Address
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress=substring(PropertyAddress,1,charindex(',', PropertyAddress)-1) 

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity=substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing

select 
parsename(replace(OwnerAddress,',','.'), 1) 
, parsename(replace(OwnerAddress,',','.'), 2) 
, parsename(replace(OwnerAddress,',','.'), 3) 
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'), 3) 

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity=parsename(replace(OwnerAddress,',','.'), 2) 

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitState=parsename(replace(OwnerAddress,',','.'), 1) 

select *
from PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------------------------------
-- change y and n to yes and no in "Sold as vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant='Y' then 'Yes'
	   when SoldAsVacant='N' then 'NO'
	   else SoldAsVacant
	   end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
	   when SoldAsVacant='N' then 'NO'
	   else SoldAsVacant
	   end


----------------------------------------------------------------------------------------------------------------
-- Remove Duplicattes
with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID) row_num
from PortfolioProject..NashvilleHousing
)
-- Do before running select
--delete
--from RowNumCTE
--where row_num>1
select *
from RowNumCTE
where row_num>1
order by PropertyAddress

----------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns
select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress 

alter table PortfolioProject..NashvilleHousing
drop column SaleDate 



