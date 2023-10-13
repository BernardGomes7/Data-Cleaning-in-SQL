/*

Cleaning Data in SQL Queries

*/



Select * 
From [Portfolio Project1].dbo.[Nashville Housing]



--------------------------------------------------------------------------------------------------------



--Standardize date Format



Alter Table [Nashville Housing]
Add SaleDateConverted  Date;



Update [Nashville Housing]
SET SaleDateConverted = CONVERT(date , SaleDate)



Select SaleDateConverted , SaleDate
From [Portfolio Project1].dbo.[Nashville Housing]




--------------------------------------------------------------------------------------------------------



--Popullate Property Address data



Select *
From [Nashville Housing]
--Where PropertyAddress is Null
order by ParcelID



Select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, isnull (a.PropertyAddress , b.PropertyAddress)
From [Portfolio Project1].dbo.[Nashville Housing] as a 
Join [Portfolio Project1].dbo.[Nashville Housing] as b
on a.ParcelID = b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null



Update a
Set a.PropertyAddress = isnull (a.PropertyAddress , b.PropertyAddress)
From [Portfolio Project1].dbo.[Nashville Housing] as a 
Join [Portfolio Project1].dbo.[Nashville Housing] as b
on a.ParcelID = b.ParcelID
And a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------


-- Breaking out Proprty Address into Individual Columns (Address, City)


Select PropertyAddress
From [Portfolio Project1].dbo.[Nashville Housing]



Select 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1) as 'Address'
,SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as 'address'
From [Portfolio Project1].dbo.[Nashville Housing]



Alter Table [Portfolio Project1].dbo.[Nashville Housing]
Add PropertySplitAddress nvarchar(255)


Update [Portfolio Project1].dbo.[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1) 



Alter Table [Portfolio Project1].dbo.[Nashville Housing]
Add PropertySplitCity nvarchar(255)


Update [Portfolio Project1].dbo.[Nashville Housing]
SET PropertySplitcity = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))




-------------------------------------------------------------------------------------------------------



-- Breaking out OwnerAddress into Individual Columns (Address, City, State)



Select OwnerAddress
From [Portfolio Project1].dbo.[Nashville Housing]


Select 
PARSENAME(REPLACE(OwnerAddress ,',','.') ,3),
PARSENAME(REPLACE(OwnerAddress ,',','.') ,2),
PARSENAME(REPLACE(OwnerAddress ,',','.') ,1) 
From [Portfolio Project1].dbo.[Nashville Housing]



Alter Table [Portfolio Project1].dbo.[Nashville Housing]
Add OwnerSplitAddress nvarchar(255)


Update [Portfolio Project1].dbo.[Nashville Housing]
SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress ,',','.') ,3) 




Alter Table [Portfolio Project1].dbo.[Nashville Housing]
Add OwnerSplitCity nvarchar(255)


Update [Portfolio Project1].dbo.[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress ,',','.') ,2)




Alter Table [Portfolio Project1].dbo.[Nashville Housing]
Add OwnerSplitState nvarchar (255)


Update [Portfolio Project1].dbo.[Nashville Housing]
SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress ,',','.') ,1) 




Select *
From [Portfolio Project1].dbo.[Nashville Housing]



-------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count (SoldAsVacant)
From [Portfolio Project1].dbo.[Nashville Housing]
group by SoldAsVacant
Order by 2


Select SoldAsVacant
,case
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
From [Portfolio Project1].dbo.[Nashville Housing]



Update [Portfolio Project1].dbo.[Nashville Housing]
SET SoldAsVacant = case
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End



--------------------------------------------------------------------------------------------------------



--Remove Duplicates 



With RownumCTE as (
Select*,
ROW_NUMBER() over
(Partition by ParcelID ,
             PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 Order by 
			 UniqueID )
			  as rownum

From [Portfolio Project1].dbo.[Nashville Housing]
--order by ParcelID
)
Delete
From RownumCTE
Where rownum >1

-------------------------------------------------------------------------------------------------------


-- Delete Unused Columns



select *
From [Portfolio Project1].dbo.[Nashville Housing]

Alter Table [Portfolio Project1].dbo.[Nashville Housing]
Drop Column PropertyAddress, OwnerAddress, TaxDistrict