-- Select top 100
select * from nashville_housing
limit 100

-- change data type of SaleDate from varchar to date 

select "SaleDate", "SaleDate"::Date
from nashville_housing

alter table nashville_housing 
alter column "SaleDate" type Date USING ("SaleDate"::date)

select "SaleDate" from nashville_housing 

-- Find Nulls in the property addresses column
select "PropertyAddress" 
from nashville_housing  
where "PropertyAddress" = ''

select * 
from nashville_housing 
where "PropertyAddress" = ''

select * 
from nashville_housing nh 
order by "ParcelID"

-- Use parcelIDs fill in the null addresses

select nh1."ParcelID", nh1."PropertyAddress", nh2."ParcelID", nh2."PropertyAddress", 
coalesce(nullif(nh1."PropertyAddress", ''), nh2."PropertyAddress")
from nashville_housing nh1
join nashville_housing nh2
on nh1."ParcelID" = nh2."ParcelID"
and nh1."UniqueID " != nh2."UniqueID " 
where nh1."PropertyAddress" = ''

update nashville_housing as nh1
set "PropertyAddress" = coalesce(nullif(nh1."PropertyAddress", ''), nh2."PropertyAddress")
from nashville_housing nh2
where nh1."ParcelID" = nh2."ParcelID"
	and nh1."UniqueID " != nh2."UniqueID " 
	and nh1."PropertyAddress" = ''
	
-- Seperating the property and owner addresses into seperate columns for street, city, state

select nh."PropertyAddress" 
	from nashville_housing nh 
	
select 
substring("PropertyAddress", 1, strpos("PropertyAddress", ',')-1) as Street,
substring("PropertyAddress", strpos("PropertyAddress", ',') +1, length("PropertyAddress")) as City
from nashville_housing nh 

alter table nashville_housing 
add PropertyStreet text

update nashville_housing 
set PropertyStreet = substring("PropertyAddress", 1, strpos("PropertyAddress", ',')-1)

alter table nashville_housing 
add PropertyCity text

update nashville_housing 
set PropertyCity = substring("PropertyAddress", strpos("PropertyAddress", ',') +1, length("PropertyAddress"))

select "OwnerAddress" 
from nashville_housing

-- Now lets split owner address
select 
split_part("OwnerAddress", ',', 1),
split_part("OwnerAddress", ',', 2),
split_part("OwnerAddress", ',', 3) 
from nashville_housing nh 

alter table nashville_housing 
add OwnerStreet text

update nashville_housing 
set OwnerStreet = split_part("OwnerAddress", ',', 1)

alter table nashville_housing 
add OwnerCity text

update nashville_housing 
set OwnerCity = split_part("OwnerAddress", ',', 2)

alter table nashville_housing 
add OwnerState text

update nashville_housing 
set OwnerState = split_part("OwnerAddress", ',', 3)

-- lets make the SoldAsVacant field consitent with only 2 values

select distinct "SoldAsVacant", count("SoldAsVacant")  
from nashville_housing
group by "SoldAsVacant" 
order by 2

select "SoldAsVacant", 
case when "SoldAsVacant" = 'Y' then 'Yes'
	 when "SoldAsVacant" = 'N' then 'No'
	 else "SoldAsVacant"
	 end
from nashville_housing

update nashville_housing 
set "SoldAsVacant" = case when "SoldAsVacant" = 'Y' then 'Yes'
	 when "SoldAsVacant" = 'N' then 'No'
	 else "SoldAsVacant"
	 end

-- Remove duplicates

WITH NumRowCTE AS (
SELECT "UniqueID ",
	ROW_NUMBER() OVER (
	PARTITION BY "ParcelID", 
	"PropertyAddress", 
	"SalePrice",
        "SaleDate",
        "LegalReference"  
    ORDER BY "UniqueID ") as rownum
FROM nashville_housing)
delete FROM nashville_housing nh 
using NumRowCTE nr 
where
nh."UniqueID " = nr."UniqueID "
and rownum>1;


WITH NumRowCTE AS ( -- check for remaining duplicates
SELECT "UniqueID ",
	ROW_NUMBER() OVER (
	PARTITION BY "ParcelID", 
	"PropertyAddress", 
	"SalePrice",
        "SaleDate",
        "LegalReference"  
    ORDER BY "UniqueID ") as rownum
FROM nashville_housing)
select * from NumRowCTE
where rownum >1

select *
from nashville_housing

-- Remove unsplit addresses, and unused columns
alter table nashville_housing 
drop column "OwnerAddress", 
drop column "TaxDistrict", 
drop column "PropertyAddress"

