/*

Cleaning Data in SQL Queries

How to clean data
Step 1: Remove duplicate or irrelevant observations
Step 2: Fix structural errors
Step 3: Filter unwanted outliers
Step 4: Handle missing data
Step 5: Validate and QA

*/

Select *
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out timestamp into date and time

Select timestamp
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

Select timestamp, convert(date, timestamp) as [Date], convert(varchar(8), convert(time, timestamp)) as [Time]
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

ALTER TABLE DataScienceAndSTEMSalaries
Add DATE Date

ALTER TABLE DataScienceAndSTEMSalaries
Add TIME varchar(8)

Update DataScienceAndSTEMSalaries
SET DATE = convert(date, timestamp)

Update DataScienceAndSTEMSalaries
SET TIME = convert(varchar(8), convert(time, timestamp))

Select timestamp, DATE, TIME
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

---------------------------------------------------------------------------------------------------------------------------

-- Breaking out Location into Individual Columns (City, State, Country) and populate data into column Country

Select *
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

SELECT
SUBSTRING(location, 1, CHARINDEX(',', location) -1 ) as City
, SUBSTRING(location, CHARINDEX(',', location) + 1 , LEN(location)) as Address
From DataScienceAndSTEMSalaries

ALTER TABLE DataScienceAndSTEMSalaries
Add CITY nvarchar(255);

ALTER TABLE DataScienceAndSTEMSalaries
Add STATE nvarchar(255);

ALTER TABLE DataScienceAndSTEMSalaries
Add COUNTRY nvarchar(255);

Update DataScienceAndSTEMSalaries
SET CITY = SUBSTRING(location, 1, CHARINDEX(',', location) -1 ) 

Update DataScienceAndSTEMSalaries
SET STATE = SUBSTRING(location, CHARINDEX(',', location) + 2 , 2)

Update DataScienceAndSTEMSalaries
SET COUNTRY = SUBSTRING(location, CHARINDEX(',', location) + 6 , LEN(location))

Select location, CITY, STATE, COUNTRY
From DataScienceAndSTEMSalaries
Where COUNTRY = ' '

Update DataScienceAndSTEMSalaries
SET COUNTRY = 'United States'
Where COUNTRY = ' '

Select location, CITY, STATE, COUNTRY
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

-----------------------------------------------------------------------------------------------------------------------------

-- Change data type

Select totalyearlycompensation, basesalary, stockgrantvalue, bonus
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

Update DataScienceAndSTEMSalaries
SET totalyearlycompensation = CAST(totalyearlycompensation AS int)

Update DataScienceAndSTEMSalaries
SET basesalary = CAST(basesalary AS int)

Update DataScienceAndSTEMSalaries
SET stockgrantvalue = CAST(stockgrantvalue AS int)

Update DataScienceAndSTEMSalaries
SET bonus = CAST(bonus AS int)

-----------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns

Select tag, otherdetails, cityid, dmaid, rowNumber, Masters_Degree, Bachelors_Degree, Doctorate_Degree, Highschool, 
Some_College, Race_Asian, Race_White, Race_Two_Or_More, Race_Black, Race_Hispanic
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

ALTER TABLE DataScienceAndSTEMSalaries
DROP COLUMN tag, otherdetails, cityid, dmaid, rowNumber, Masters_Degree, Bachelors_Degree, Doctorate_Degree, Highschool, 
Some_College, Race_Asian, Race_White, Race_Two_Or_More, Race_Black, Race_Hispanic

Select *
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

-----------------------------------------------------------------------------------------------------------------------------

-- Find and update mistakes

SELECT gender, COUNT(gender)
FROM DataScienceAndSTEMSalaries
GROUP BY gender

SELECT *
FROM DataScienceAndSTEMSalaries
Where gender = 'Title: Senior Software Engineer'

Update DataScienceAndSTEMSalaries
SET gender = 'NA'
Where gender = 'Title: Senior Software Engineer'

-----------------------------------------------------------------------------------------------------------------------------

-- Find and remove duplicates (You can think of CTE as a subquery, it doesn't have a temp table underneath. So, if you run delete statement against your CTE you will delete rows from the table.)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY timestamp,
				 company,
				 level,
				 title,
				 totalyearlycompensation,
				 location,
				 yearsofexperience,
				 yearsatcompany,
				 basesalary,
				 stockgrantvalue,
				 bonus,
				 gender,
				 Race,
				 Education
				 ORDER BY
					timestamp
					) row_num

From DataScienceAndSTEMSalaries)

Select *
From RowNumCTE
Where row_num > 1
Order by timestamp

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY timestamp,
				 company,
				 level,
				 title,
				 totalyearlycompensation,
				 location,
				 yearsofexperience,
				 yearsatcompany,
				 basesalary,
				 stockgrantvalue,
				 bonus,
				 gender,
				 Race,
				 Education
				 ORDER BY
					timestamp
					) row_num

From DataScienceAndSTEMSalaries)

DELETE
From RowNumCTE
Where row_num > 1

Select *
From PortfolioProject.dbo.DataScienceAndSTEMSalaries

----------------------------------------------------------------------------------------------------------------------------------------------


