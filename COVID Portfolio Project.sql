SELECT *
FROM PortfolioProject..CovidDeaths1
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

-- Select Data to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths1
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of death after contacting covid

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 AS "Death Percentage"
FROM PortfolioProject..CovidDeaths1
WHERE location like '%Finland%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what % got Covid
SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS "Infected Percentage"
FROM PortfolioProject..CovidDeaths1
--WHERE location like '%Finland%'
ORDER BY 1,2;

--Countries with highest infection rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS
InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths1
GROUP BY location,population
ORDER BY InfectedPopulationPercentage DESC;

-- Showing countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_deaths AS INT)) AS TOTALDEATHCOUNT
FROM PortfolioProject..CovidDeaths1
WHERE continent IS NULL
GROUP BY location
ORDER BY TOTALDEATHCOUNT DESC;

-- Break into continent
SELECT continent, MAX(cast(Total_deaths AS INT)) AS TOTALDEATHCOUNT
FROM PortfolioProject..CovidDeaths1
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TOTALDEATHCOUNT DESC;

-- Showing continents with highest death count per population
-- Global numbers 


SELECT SUM(new_cases) AS Totalcases, SUM(cast(new_deaths as int)) as Totaldeaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths1
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- Total Population vs Vaccinations

WITH PopsvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date= vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopsvsVac
-- USE CTE

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date= vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create View for Tableau Visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths1 dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date= vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated