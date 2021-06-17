
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
Select *
FROM Covid19Project..CovidDeaths
Where continent is not null 
ORDER BY 3, 4

Select *
FROM Covid19Project..CovidVaccinations
Where continent is not null 
ORDER BY 3, 4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM Covid19Project..CovidDeaths
ORDER BY 1, 2

--- Total Cases Vs Total Deaths in % (Death Percentage in Australia)
--- Likelihood of dying from Covid19 if you are in Australia and if you have covid19 positive

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Covid19Project..CovidDeaths
WHERE location like '%Australia%'
ORDER BY 1, 2


---- Total Cases vs Population
--- Percentage of population got Covid19 
Select location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
FROM Covid19Project..CovidDeaths
--WHERE location like '%Australia%'
ORDER BY 1, 2

----- Countries with Highest Infection rate Compare to Population
Select location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Covid19Project..CovidDeaths
--WHERE location like '%Australia%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 

-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid19Project..CovidDeaths
--Where location like '%Australia%'
Where continent is not null 
Group by location
order by TotalDeathCount desc


--- Highest Death Count by Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid19Project..CovidDeaths
--Where location like '%Australia%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS Death Percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid19Project..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Total Population vs Vaccinations

----- Join two Tables together
--Select*
--From Covid19Project..CovidDeaths dea
--Join Covid19Project..CovidVaccinations vac
--     on dea.location = vac.location
--	 and dea.date = vac.date
	 ----------

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
order by 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

----- TEMP TABLE------------
-------------------
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select*
FROM PercentPopulationVaccinated

