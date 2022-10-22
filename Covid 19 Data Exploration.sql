
/*

Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views

*/

Select *
From PortfolioProject.dbo.country_wise_latest
Where [Country Region] is not null
Order By 1 

--Select Data that we going to be starting with

Select [Country Region], Confirmed, [New cases], Deaths
From PortfolioProject.dbo.country_wise_latest
Where [Country Region] is not null 
order by 1,2

--Total Cases vs Total Deaths, Death Percentage By Country

Select distinct[WHO Region]
From PortfolioProject.dbo.country_wise_latest

Select [WHO Region], COUNT([Country Region]) AS CountsofCountries
From PortfolioProject.dbo.country_wise_latest
Group By [WHO Region]

Select [Country Region], Confirmed, [New cases], Deaths, 
(Cast(Deaths AS decimal)/Cast(Confirmed AS decimal))*100 as DeathPercentage
From PortfolioProject.dbo.country_wise_latest
Where [WHO Region] = 'Europe'
and [Country Region] is not null 

--Total Confirmed vs Total Deaths, Death Percentage By Region

Select [WHO Region], SUM(Convert(int,Confirmed)) AS TotalConfirmed, SUM(Convert(int,Deaths)) AS TotalDeaths,
SUM(Convert(decimal,Deaths))/SUM(Convert(decimal,Confirmed))*100 as DeathPercentage
From PortfolioProject.dbo.country_wise_latest
Group By [WHO Region]
Order By DeathPercentage DESC

Select [WHO Region], AVG(Convert(int,Confirmed)) AS AVGConfirmed, AVG(Convert(int,Deaths)) AS AVGDeaths,
AVG(Convert(decimal,Deaths))/AVG(Convert(decimal,Confirmed))*100 as DeathPercentage
From PortfolioProject.dbo.country_wise_latest
Group By [WHO Region]
Having AVG(Convert(decimal,Deaths))/AVG(Convert(decimal,Confirmed))*100 >3
Order By DeathPercentage DESC

--Join Two Tables and Populate "Population" Data

Select DISTINCT(Covid.location), Covid.Population,
Country.[Country Region]
From PortfolioProject.dbo.[owid-covid-data] AS Covid
Join PortfolioProject.dbo.country_wise_latest AS Country
ON Covid.Location = Country.[Country Region]
Order By Covid.location

CREATE TABLE Countries_Population
(
 Countries varchar(50),
 Population varchar(50),
 )

INSERT INTO Countries_Population(Countries, Population)
(Select DISTINCT(Covid.location), Covid.Population
From PortfolioProject.dbo.[owid-covid-data] AS Covid
Join PortfolioProject.dbo.country_wise_latest AS Country
ON Covid.Location = Country.[Country Region])

 Select *
 From Countries_Population
 Order By 1

 Alter Table PortfolioProject.dbo.country_wise_latest
 ADD Population varchar(50)

 UPDATE Lat
 SET Population = ISNULL(Lat.Population, Cou.Population)
 FROM PortfolioProject.dbo.country_wise_latest Lat
 JOIN PortfolioProject.dbo.Countries_Population Cou
 ON Lat.[Country Region] = Cou.Countries
 WHERE Lat.Population is null

--Total Cases vs Population

 Select [Country Region], Confirmed, Population,
 (Cast(Confirmed as decimal)/Cast(Population as decimal))*100 AS PercentPopulationInfected
 From PortfolioProject.dbo.country_wise_latest
 Where [WHO Region] = 'Africa'
 Order By PercentPopulationInfected DESC

--Total Population vs Vaccinations

Select lat.[Country Region], lat.population, vac.Date, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(Partition by lat.[Country Region] Order by lat.[Country Region]) as RollingPeopleVaccinated
From PortfolioProject.dbo.country_wise_latest lat
Join PortfolioProject.dbo.CovidVaccinations vac
On lat.[Country Region] = vac.location
Order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select lat.[WHO Region], lat.[Country Region], vac.date, lat.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by lat.[Country Region] Order by lat.[Country Region], vac.Date)
as RollingPeopleVaccinated
From PortfolioProject.dbo.country_wise_latest lat
Join PortfolioProject.dbo.CovidVaccinations vac
	On lat.[Country Region] = vac.location
where lat.[WHO Region] is not null 
)

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulation
From PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select lat.[WHO Region], lat.[Country Region], vac.date, lat.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by lat.[Country Region] Order by lat.[Country Region], vac.Date)
as RollingPeopleVaccinated
From PortfolioProject.dbo.country_wise_latest lat
Join PortfolioProject.dbo.CovidVaccinations vac
	On lat.[Country Region] = vac.location

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualizations

Create View PercentPopulationVaccinated as
Select lat.[WHO Region], lat.[Country Region], vac.date, lat.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by lat.[Country Region] Order by lat.[Country Region], vac.Date)
as RollingPeopleVaccinated
From PortfolioProject.dbo.country_wise_latest lat
Join PortfolioProject.dbo.CovidVaccinations vac
	On lat.[Country Region] = vac.location
Where lat.[WHO Region] is not null 



