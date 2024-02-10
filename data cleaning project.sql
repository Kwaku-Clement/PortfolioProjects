select * from PortfolioProject.dbo.HousingData

--standardize date format
select saleDateConverted, CONVERT(date, SaleDate) from PortfolioProject.dbo.HousingData

update PortfolioProject.dbo.HousingData
set saleDate = CONVERT(date, SaleDate)

alter table PortfolioProject.dbo.HousingData
add saleDateConverted date;

update PortfolioProject.dbo.HousingData
set saleDateConverted = CONVERT(date, SaleDate)

--populate the property address
select a.parcelId, a.propertyaddress, b.parcelId, b.propertyAddress,
isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject.dbo.HousingData a
join PortfolioProject.dbo.HousingData b
on a.ParcelID = b.ParcelID where a.PropertyAddress is null

update a
set propertyAddress = isnull(a.propertyAddress, b.propertyAddress)
from PortfolioProject.dbo.HousingData a
join PortfolioProject.dbo.HousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]  <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns using substring and parsename
--SUBSTRING
select propertyAddress from PortfolioProject.dbo.HousingData

select SUBSTRING(propertyAddress, 1, charindex(',', propertyAddress) -1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',', propertyAddress) +1, LEN(propertyAddress)) as address
from PortfolioProject.dbo.HousingData

alter table HousingData
add splitPropertyAddress nvarchar(255)

update PortfolioProject.dbo.HousingData
set splitPropertyAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress) -1)
 
select splitPropertyAddress from PortfolioProject.dbo.HousingData

alter table HousingData
add propertyAddressCity nvarchar(255)

update PortfolioProject.dbo.HousingData
set propertyAddressCity = substring(propertyAddress, charindex(',', propertyAddress) +1, LEN(propertyAddress))

select * from PortfolioProject.dbo.HousingData

--PARSENAME
select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.HousingData


alter table PortfolioProject.dbo.HousingData
add ownerPropertyAddress nvarchar(255)

alter table PortfolioProject.dbo.HousingData
add ownerPropertyCity nvarchar(255)

alter table PortfolioProject.dbo.HousingData
add ownerPropertyState nvarchar(255)


update PortfolioProject.dbo.HousingData
set ownerPropertyAddress = PARSENAME(REPLACE(ownerAddress, ',', '.'), 3)

update PortfolioProject.dbo.HousingData
set ownerPropertyCity = PARSENAME(REPLACE(ownerAddress, ',', '.'), 2)

update PortfolioProject.dbo.HousingData
set ownerPropertyState = PARSENAME(REPLACE(ownerAddress, ',', '.'), 1)

select ownerPropertyAddress, ownerPropertyCity, ownerPropertyState
from PortfolioProject.dbo.HousingData
where ownerPropertyAddress is not null

select * from PortfolioProject.dbo.HousingData

--change Y and N in soldAsVacant field

select distinct(soldAsVacant), count(soldAsVacant) 
from PortfolioProject.dbo.HousingData
group by soldAsVacant
order by 2

select SoldAsVacant,
case when soldAsVacant = 'Y' then 'Yes'
	 when soldAsVacant = 'N' then 'No'
	 else soldAsVacant
	 end
from PortfolioProject.dbo.HousingData

update PortfolioProject.dbo.HousingData
set SoldAsVacant = 
case when soldAsVacant = 'Y' then 'Yes'
	 when soldAsVacant = 'N' then 'No'
	 else soldAsVacant
	 end

--Remove duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() over(
PARTITION BY parcelId,
			 propertyAddress,
			 salePrice,
			 saleDate,
			 legalReference
			 order by UniqueId) row_num
from PortfolioProject.dbo.HousingData
) 
select * from RowNumCTE where row_num > 1

with RowNumCTE as(
select *,
ROW_NUMBER() over(
PARTITION BY parcelId,
			 propertyAddress,
			 salePrice,
			 saleDate,
			 legalReference
			 order by UniqueId) row_num
from PortfolioProject.dbo.HousingData
) 
delete from RowNumCTE where row_num > 1

--delete unused columns
alter table PortfolioProject.dbo.HousingData
drop column ownerAddress, propertyAddress, taxDistrict, saleDate

select * from PortfolioProject.dbo.HousingData
