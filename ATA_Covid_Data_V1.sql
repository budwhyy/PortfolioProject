Select *
From ProjectPortfolio..Covid_deaths$
Where continent is not null 
order by 3,4

--Select *
--From ProjectPortfolio..Covid_Vaxx$
--order by 3,4

select Location, 
	date, 
	population,
	total_cases, 
	new_cases, 
	total_deaths
From ProjectPortfolio..Covid_deaths$
Order by 1,2






-- 1) 
-- looking at the total cases vs total deaths 
-- Shows the likelihood of dying if you contract covid in your country 
-- Location cahnged to india 

select Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage 
From ProjectPortfolio..Covid_deaths$
--Where location like '%India%'
Where continent is not null
Order by 1,2






--2)
--Looking at the total cases vs population
--shows what percentage of population got covid 

select Location, 
	date, 
	population, 
	total_cases,  
	(total_cases/population)*100 as InfectedPercentage
From ProjectPortfolio..Covid_deaths$
W--here location like '%India%'
Where continent is not null
Order by 1,2






--3)
--looking at Countries with the highest infection rate compared to population 

Select Location, 
	population, 
	MAX(total_cases) as HighestInfectioncount, 
	MAX((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolio..Covid_deaths$
--Where location like '%india%'
Where continent is not null
Group by population, location
Order by PercentPopulationInfected desc






--4)
--showing countries with highest death count per population 

Select Location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount 
From ProjectPortfolio..Covid_deaths$
--Where location like '%india%'
Where continent is not null
Group by population, location
Order by TotalDeathCount desc






--5)
--BREAK THINGS DOWN BY CONTINENT
--showing the continent with the highest death count 

Select continent, 
	MAX(cast(total_deaths as int)) as TotalDeathCount 
From ProjectPortfolio..Covid_deaths$
--Where location like '%india%'
Where continent is not null 
Group by continent
Order by TotalDeathCount desc





-- Global Numbers

select 
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
From ProjectPortfolio..Covid_deaths$
--Where location like '%India%'
Where continent is not null  
--Group by date 
Order by 1,2






-- Looking at total Population vs vaccinations 

Select DEA.continent, 
	DEA.location, 
	DEA.date, 
	DEA.population, 
	VAX.new_vaccinations,
	SUM(cast(VAX.new_vaccinations as bigint))
	OVER (Partition by DEA.location Order by DEA.location,DEA.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..Covid_deaths$ DEA
Join ProjectPortfolio..Covid_vaxx$ VAX
	On DEA.location = VAX.location
	and DEA.date = VAX.date
Where DEA.continent is not null
and DEA.location like '%india%'
Order by 2,3






-- USE CTE

With Popvsvax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select DEA.continent, 
	DEA.location, 
	DEA.date, 
	DEA.population, 
	VAX.new_vaccinations,
	SUM(cast(VAX.new_vaccinations as bigint))
	OVER (Partition by DEA.location Order by DEA.location,DEA.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..Covid_deaths$ DEA
Join ProjectPortfolio..Covid_vaxx$ VAX
	On DEA.location = VAX.location
	and DEA.date = VAX.date
Where DEA.continent is not null
--and DEA.location like '%india%'
)
Select *, (RollingPeopleVaccinated/Population)*100 
From Popvsvax


--TEMP TABLE



DROP table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select DEA.continent, 
	DEA.location, 
	DEA.date, 
	DEA.population, 
	VAX.new_vaccinations,
	SUM(cast(VAX.new_vaccinations as bigint))
	OVER (Partition by DEA.location Order by DEA.location,DEA.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..Covid_deaths$ DEA
Join ProjectPortfolio..Covid_vaxx$ VAX
	On DEA.location = VAX.location
	and DEA.date = VAX.date
--Where DEA.continent is not null
--Where DEA.location like '%india%'

Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


--Creating view to store data for later viz

	
Create view PercentPopulationVaccinated as
Select DEA.continent, 
	DEA.location, 
	DEA.date, 
	DEA.population, 
	VAX.new_vaccinations,
	SUM(cast(VAX.new_vaccinations as bigint))
	OVER (Partition by DEA.location Order by DEA.location,DEA.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..Covid_deaths$ DEA
Join ProjectPortfolio..Covid_vaxx$ VAX
	On DEA.location = VAX.location
	and DEA.date = VAX.date
Where DEA.continent is not null
--order by 2,3
--Where DEA.location like '%india%'

Select *
From PercentPopulationVaccinated