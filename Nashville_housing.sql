#cleaning data in sql queries.

select * from nashvillehousing limit 500;


# standardise date format
select SaleDate, STR_TO_DATE(SaleDate,'%M %d,%Y') 
from nashvillehousing;

update nashvillehousing
set SaleDate = STR_TO_DATE(SaleDate, '%M %d %Y');

-- or you can also add an extra date field in the table.
ALTER table nashvillehousing
ADD SaleDateConverted date;
 
update nashvillehousing
set SaleDateConverted = STR_TO_DATE(SaleDate, '%M %d %Y');


# populate the address in PropertyAddress

-- why? beacause there can be a chance for the Owner's address to change overtime but a property's address can't change.

-- every propertyAddress. has this parcelID associated with it
select ParcelID, PropertyAddress
from nashvillehousing;

-- check for the parcelID with null property adress
select ParcelID, PropertyAddress
from nashvillehousing
where PropertyAddress is null;

-- join the two tables to see what must be in those null values
select n1.ParcelID, n1.PropertyAddress,n2.ParcelID, n2.PropertyAddress, ifnull(n1.PropertyAddress,n2.PropertyAddress)
from nashvillehousing n1 join nashvillehousing n2
on n1.ParcelID=n2.ParcelID and n1.UniqueID<>n2.UniqueID
where n1.PropertyAddress is null;

-- update the PropertyAddress based on the ParcelID.
update nashvillehousing n1
join nashvillehousing n2
on n1.ParcelID=n2.ParcelID and n1.UniqueID<>n2.UniqueID
set n1.PropertyAddress = ifnull(n1.PropertyAddress,n2.PropertyAddress)
where n1.PropertyAddress is null;

#breaking out address into multiple columns

select PropertyAddress
from nashvillehousing;

-- so we have house address and state both in one columns, divide them in two seperate columns


select substring(PropertyAddress, 1, instr(PropertyAddress,',')-1) as address, instr(PropertyAddress, ","), 
substring(PropertyAddress, instr(PropertyAddress,',')+1, length(PropertyAddress)) as state
from nashvillehousing;

-- add 2 columms in the table

alter table nashvillehousing
add property_address varchar(255);

update nashvillehousing
set property_address = substring(PropertyAddress, 1, instr(PropertyAddress,',')-1);


alter table nashvillehousing
add property_city varchar(255);

update nashvillehousing
set property_city = substring(PropertyAddress, instr(PropertyAddress,',')+1, length(PropertyAddress));

select * from nashvillehousing
where OwnerAddress = "";

select SUBSTRING_INDEX(OwnerAddress,',',1) as address, 
SUBSTRING_INDEX(OwnerAddress,',',2),
SUBSTRING_INDEX(OwnerAddress,',',3)
from nashvillehousing;

SELECT
   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1) AS owner_address,
   If(length(OwnerAddress) - length(replace(OwnerAddress, ',', ''))>1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),NULL)
           as owner_city,
   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS owner_state
FROM nashvillehousing;


-- add new columns for owner's address fields

alter table nashvillehousing
add owner_address varchar(255);

update nashvillehousing
set owner_address =SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1);


alter table nashvillehousing
add owner_city varchar(255);

update nashvillehousing
set owner_city =If(length(OwnerAddress) - length(replace(OwnerAddress, ',', ''))>1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),NULL);

alter table nashvillehousing
add owner_state varchar(255);

update nashvillehousing
set owner_state =SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);

# check the SoldAsVAcant field as make the necessary changes.

select soldAsVacant, count(*)
from nashvillehousing
group by soldAsVacant;

update nashvillehousing
set soldAsVacant ="No"
where soldAsVacant ="N";

update nashvillehousing
set soldAsVacant ="Yes"
where soldAsVacant ="Y";


#remove duplicates.
 select * from nashvillehousing limit 500;
 
 select *, row_number() over(
				 partition by
				 ParcelID, 
                 SaleDate, 
                 Saleprice, 
                 LegalReference, 
                 PropertyAddress, 
                 SaleDate
                 order by UniqueID) rownum
from nashvillehousing
order by ParcelID;

-- need to use CTE for this
with rownumCTE as (
 select *, row_number() over(
				 partition by
				 ParcelID, 
                 SaleDate, 
                 Saleprice, 
                 LegalReference, 
                 PropertyAddress, 
                 SaleDate
                 order by UniqueID) rownum
from nashvillehousing
order by ParcelID
)
select * from rownumCTE
where rownum>1;

-- delete these values now

-- never delete the values from the original table in a real life case scenario. 
delete from nashvillehousing
where uniqueID in (
with rownumCTE as (
 select *, row_number() over(
				 partition by
				 ParcelID, 
                 SaleDate, 
                 Saleprice, 
                 LegalReference, 
                 PropertyAddress, 
                 SaleDate
                 order by UniqueID) rownum
from nashvillehousing
order by ParcelID
)
select uniqueID from rownumCTE
where rownum>1);


#remove unused columns
 select * from nashvillehousing limit 500;


alter table nashvillehousing
drop column PropertyAddress, drop SaleDate, drop OwnerAddress, drop TaxDistrict;



# checking LandUse Field and amking necesary updation.

 select LandUse, count(*) from nashvillehousing group by LandUse;

update nashvillehousing
set LandUse='VACANT RESIDENTIAL LAND' 
WHERE LandUse='VACANT RES LAND' or LandUse='VACANT RESIENTIAL LAND';

 select * from nashvillehousing
 where OwnerName= ""


