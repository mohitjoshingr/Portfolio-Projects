SELECT *
FROM [Portfolio Projects]..Nashville
----------------------------------------------------------------------------------------------------
/* Standardize Date Format */
SELECT SaleDate,CONVERT(date,saleDate)
FROM Nashville

----UPDATE Nashville
----SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE Nashville
Add SaleDateConverted date;

update Nashville
set SaleDateConverted = CONVERT(date,saleDate)

select SaleDateConverted
from Nashville


----------------------------------------------------------------------------------------------------
/* Populating PropertyAddress data */

select a.ParcelID,a.PropertyAddress,isnull(a.propertyAddress,b.PropertyAddress)
from [Portfolio Projects]..Nashville a
join [Portfolio Projects]..Nashville b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyAddress = isnull(a.propertyAddress,b.propertyAddress)
from [Portfolio Projects]..Nashville a
join [Portfolio Projects]..Nashville b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

----------------------------------------------------------------------------------------------
--/* Breaking down Address into individual colomn (Address, City, State) */
select PropertyAddress,SUBSTRING(propertyAddress,1,charindex(',',PropertyAddress)-1) as address ,SUBSTRING(propertyAddress,charindex(',',propertyAddress)+1, len(propertyaddress)) as city
from [Portfolio Projects]..Nashville
order by 3

Alter table [portfolio projects]..nashville
add PropertySplitAddress nvarchar(255)

update [Portfolio Projects]..Nashville
set PropertySplitAddress = SUBSTRING(propertyAddress,1,charindex(',',PropertyAddress)-1)
-----------

Alter table [portfolio projects]..nashville
add PropertySplitCity nvarchar(255)

update [Portfolio Projects]..Nashville
set PropertySplitCity = SUBSTRING(propertyAddress,charindex(',',propertyAddress)+1, len(propertyaddress))

-------
select n.PropertySplitAddress, n.PropertySplitCity
from [Portfolio Projects]..Nashville n


select Nashville.PropertyAddress,Nashville.OwnerAddress
from [Portfolio Projects]..Nashville
where Nashville.OwnerAddress is null
-----------------------------------------------------------------------------------------------------------------------------
/* Breaking down Owner Address into individual colomns */

select OwnerAddress,SUBSTRING(OwnerAddress,1,charindex(',',OwnerAddress)-1) as address ,SUBSTRING(OwnerAddress,charindex(',',OwnerAddress)+1, len(OwnerAddress)) as city
from [Portfolio Projects]..Nashville
--order by 3
where ownerAddress is not null

Alter table [portfolio projects]..nashville
add OwnerSplitAddress nvarchar(255)

update [Portfolio Projects]..Nashville
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

----------
Alter table [portfolio projects]..nashville
add OwnerSplitCity nvarchar(255)

update [Portfolio Projects]..Nashville
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

------------
Alter table [portfolio projects]..nashville
add OwnerSplitState nvarchar(255)

update [portfolio projects]..nashville
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


select n.OwnerSplitAddress, n.OwnerSplitCity
from [Portfolio Projects]..Nashville n

update a
set a.OwnerAddress = null
from [Portfolio Projects]..Nashville a
where a.OwnerAddress = a.PropertyAddress
---------------------------------------------------------------------------------------------------------------------------------------------
        

update [Portfolio Projects]..Nashville
set SoldAsVacant = case 
when SoldAsVacant = 'N' then 'NO'
when SoldAsVacant = 'Y' then 'Yes'
else SoldAsVacant
end
from [Portfolio Projects]..Nashville


select distinct(SoldAsVacant), count(soldasvacant)
from [Portfolio Projects]..Nashville
group by SoldAsVacant;


-------------------------------------------------------------------------------------------------------------------------------------------
/* Removing Duplicates */
with Duplicates as (
select *,ROW_NUMBER() over (partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by uniqueid) rownum
from [Portfolio Projects]..Nashville n
--order by ParcelID
)
--select *
--from Duplicates
--where rownum > 1
--order by propertyAddress

DELETE
from Duplicates
where rownum > 1


-------------------------------------------------------------------------------
/* Deleting unused colomns */
select *
from [Portfolio Projects]..Nashville

alter table [Portfolio Projects]..Nashville
drop column ownerAddress,taxdistrict,propertyaddress

alter table [Portfolio Projects]..Nashville
drop column saledate