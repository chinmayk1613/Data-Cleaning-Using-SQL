select * from DataCleaningProject.dbo.HousingData


-- Q1 Make Standard Date format in another column.

select SaleDate from DataCleaningProject.dbo.HousingData

Alter table DataCleaningProject.dbo.HousingData add NewDate Date;

update DataCleaningProject.dbo.HousingData set newDate =CONVERT(Date,SaleDate)

--Q2 Fill the null PropertyAddress by checking the records which has similar data(for ex. ParcelID) but property address in null

select PropertyAddress from DataCleaningProject.dbo.HousingData where PropertyAddress is null

select * from DataCleaningProject.dbo.HousingData order by ParcelID


select HD1.ParcelID, HD1.PropertyAddress, HD2.ParcelID,HD2.PropertyAddress, ISNULL(HD1.PropertyAddress, HD2.PropertyAddress) from DataCleaningProject.dbo.HousingData HD1 
join DataCleaningProject.dbo.HousingData HD2 on HD1.ParcelID =HD2.ParcelID and HD1.[UniqueID ] <> HD2.[UniqueID ] where HD1.PropertyAddress is null;


update HD1 SET  PropertyAddress = ISNULL(HD1.PropertyAddress, HD2.PropertyAddress)
from DataCleaningProject.dbo.HousingData HD1 join DataCleaningProject.dbo.HousingData HD2 on 
HD1.ParcelID = HD2.ParcelID and HD1.[UniqueID ] <> HD2.[UniqueID ] where HD1.PropertyAddress is null;


--Q3 Split the address in seperate coulumns

select PropertyAddress from DataCleaningProject.dbo.HousingData;


select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
from DataCleaningProject.dbo.HousingData

alter table DataCleaningProject.dbo.HousingData add onlyAddress nvarchar(255)
update DataCleaningProject.dbo.HousingData set onlyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


alter table DataCleaningProject.dbo.HousingData add AddressCity nvarchar(255)
update DataCleaningProject.dbo.HousingData set AddressCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


select OwnerAddress from DataCleaningProject.dbo.HousingData;

select PARSENAME(REPLACE(OwnerAddress,',','.'),3) from DataCleaningProject.dbo.HousingData;
select PARSENAME(REPLACE(OwnerAddress,',','.'),2) from DataCleaningProject.dbo.HousingData;
select PARSENAME(REPLACE(OwnerAddress,',','.'),1) from DataCleaningProject.dbo.HousingData;


alter table DataCleaningProject.dbo.HousingData add ownerOnlyAddress nvarchar(255)
update DataCleaningProject.dbo.HousingData set ownerOnlyAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


alter table DataCleaningProject.dbo.HousingData add ownerCity nvarchar(255)
update DataCleaningProject.dbo.HousingData set ownerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


alter table DataCleaningProject.dbo.HousingData add ownerState nvarchar(255)
update DataCleaningProject.dbo.HousingData set ownerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Q4. Change Y to YES and N to NO in SoldAsVacant column

select distinct(SoldasVacant), count(SoldAsVacant) from DataCleaningProject.dbo.HousingData group by SoldAsVacant order by COUNT(SoldAsVacant)

select SoldAsVacant, case when SoldAsVacant ='Y' then 'Yes'
						  when SoldAsVacant='N' then 'No'
						  else SoldAsVacant
						  end
from DataCleaningProject.dbo.HousingData

update DataCleaningProject.dbo.HousingData set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		                                                   when SoldAsVacant ='N' then 'No'
								   else SoldAsVacant
								   end


--Q5 Remove Duplicates using CTE temp table

with RownNumberCTE as(
select *,
ROW_NUMBER() over ( PARTITION BY ParcelID, PropertyAddress,SalePrice, SaleDate,LegalReference order by UniqueID) row_num
from DataCleaningProject.dbo.HousingData) 

select * from RownNumberCTE where row_num > 1;


--Q6 Delete unused columns

select * from DataCleaningProject.dbo.HousingData;

alter table DataCleaningProject.dbo.HousingData drop column OwnerAddress, TaxDistrict, SaleDate, PropertyAddress




