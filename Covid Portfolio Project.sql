select *
from PortfolioProject..CovidDeaths$
order by 3,4

select *
from PortfolioProject..CovidVaccinations$
order by 3,4

--Select Data

select Location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

--Relationship between total cases and Total deaths
select Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as PctDeathRate
from PortfolioProject..CovidDeaths$
order by 1,2


select Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as PctDeathRate
from PortfolioProject..CovidDeaths$
where continent is not null
and location like '%Nigeria%'
order by 1,2


--Relationship between Total Cases and Population Size
select Location,date, total_cases,population,(total_cases/population)*100 as PctInfectionRate
from PortfolioProject..CovidDeaths$
where continent is not null
and location like '%Nigeria%'
order by 1,2


--Countries with highest infection rates, relative to population
select Location, MAX(total_cases)as HighestInfectionCount,population,MAX((total_cases/population))*100 as PctInfectionRate
from PortfolioProject..CovidDeaths$
where continent is not null
and location like '%Nigeria%'
Group by location, population
order by 1,2

select Location, MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as PctInfectionRate
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Nigeria%'
Group by location, population
order by 4 desc


--Highest Deaths by Country
select Location, MAX(cast(total_deaths as int)) as HighestMortality
from PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%Nigeria%'
Group by location
order by 2 desc

--Sorting Data by Continent

--select continent, MAX(cast(total_deaths as int)) as HighestContinentMortality
--from PortfolioProject..CovidDeaths$
--where continent is not null
--Group by continent
--order by 2 desc
--this is how it should look, but the data doesn't fit

select location, MAX(cast(total_deaths as int)) as HighestContinentMortality
from PortfolioProject..CovidDeaths$
where continent is null
Group by location
order by 2 desc


--GLOBAL NUMBERS
select date, SUM(new_cases) as InfectionCount, SUM(CAST(new_deaths as int)) as DeathCount, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DailyDeathRate
from PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2 

select SUM(new_cases) as InfectionCount, SUM(CAST(new_deaths as int)) as DeathCount, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DailyDeathRate
from PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
order by 1,2 



-- Joining the Vaccination and Death sheets

select * 
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
order by 1,2 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as LiveVaccinatedCount
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- create temp table

DROP table if exists #TotalPctVaccinated
create table #TotalPctVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
LiveVaccinatedCount numeric
)
insert into #TotalPctVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)as LiveVaccinatedCount --(LiveVaccinatedCount/population)*100
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

select *, (LiveVaccinatedCount/population)*100
from #TotalPctVaccinated


--VISUALIZING

CREATE VIEW TotalPctVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS LiveVaccinatedCount 
--,(LiveVaccinatedCount/population)*100
FROM PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$ dea 
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3



Select *
from TotalPctVaccinated