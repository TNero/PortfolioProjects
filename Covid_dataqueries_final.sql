/* 
This project focuses on the exploration of the coronavirus virus (Covid_19) data set obtained
from Ourworldindata https://ourworldindata.org/covid-deaths.
The date ranges from 2020-02-24 to 2023-02-06

Skills used : Sorting, Filtering, Aggregate Functions, converting Data types, Joins, Temp Table, Windows functions creating views
*/ 


SELECT *
FROM Portfolioproject.dbo.CovidDeaths$
WHERE continent is not null
Order by location,date


/*
Exploring Total Cases vs Total Deaths 
i.e., the possibility of dying if a person gets infected with Covid in Canada 
*/

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolioproject.dbo.CovidDeaths$
WHERE location like '%Canada%' and continent is not null
Order by location,date

/* 
Exploring Total Cases vs Population
Shows what percentage of population contracted covid in Canada in descending order
*/

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM Portfolioproject.dbo.CovidDeaths$
WHERE location like '%Canada%'
Order by location,date desc


-- Exploring Countries with Highest Infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM Portfolioproject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY Location, population
Order by 4 DESC

-- Countries with Highest Death Count per Population

SELECT location, population, MAX(CAST(total_deaths as int)) as TotalDeathCount, MAX((total_deaths/population))*100 AS DeathPercentage
FROM Portfolioproject..CovidDeaths$
WHERE continent is not null
GROUP BY Location , population
Order by TotalDeathCount DESC


--Exploring from a Continent point of view

--Continents with the highest death count

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Portfolioproject..CovidDeaths$
WHERE continent is not null
GROUP BY continent 
Order by TotalDeathCount DESC


--Combining both tables (Joins) for exploration

--Global Numbers  

SELECT SUM(new_cases) as total_cases, SUM(CONVERT(int, new_deaths )) as total_deaths, MAX(CONVERT(bigint, total_vaccinations )) as total_vaccinations, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths$ dea
JOIN Portfolioproject..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null

-- Looking at Total Population vs Vaccinations
-- Shows the Percentage of the Population that has received at least one dose of Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING ) AS RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths$ dea
JOIN Portfolioproject..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- Using Temp Table to Perform Calculation on Partition By in Previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING ) AS RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths$ dea
JOIN Portfolioproject..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null


SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPercentage
FROM #PercentPopulationVaccinated


-- Creating View to store data for later use
USE Portfolioproject
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING ) AS RollingPeopleVaccinated
FROM Portfolioproject..CovidDeaths$ dea
JOIN Portfolioproject..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
GO


USE Portfolioproject
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW VacvsGDP AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_cases, dea.new_deaths, vac.new_vaccinations
, vac.gdp_per_capita
FROM Portfolioproject..CovidDeaths$ dea
JOIN Portfolioproject..CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
)

GO