--Continent column: NULL values = SUMs for certain criteria or continents 
--Filter out by -> WHERE continent IS NOT NULL
SELECT *
FROM PortfolioProject1..CovidDeaths
WHERE date = '2021-01-03'
ORDER BY 2


--Looking at Total Cases vs Population
--Shows the population who has contracted COVID-19
	--JOIN two datasets for the population 
	--Can clean date (time unnecessary)

SELECT dea.continent, dea.location, LEFT(CAST(dea.date AS date), 10) AS date, dea.new_cases
, SUM(dea.new_cases) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleInfected, Vac.population
--, (Rolling/population)*100 AS infection_percentage
FROM PortfolioProject1..CovidDeaths AS Dea
JOIN PortfolioProject1..CovidVaccinations AS Vac
	ON Dea.continent = Vac.continent
	AND Dea.location = Vac.location
	AND Dea.date = Vac.date
ORDER BY 1,2,3


--Create CTE to find Infection Percentage on Rolling People Infected

WITH PopvsCase (continent, location, date, new_cases, RollingInfected, population)
AS
(
SELECT dea.continent, dea.location, LEFT(CAST(dea.date AS date), 10) AS date, dea.new_cases
, SUM(dea.new_cases) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingInfected, Vac.population
--, (Rolling/population)*100 AS infection_percentage
FROM PortfolioProject1..CovidDeaths AS Dea
JOIN PortfolioProject1..CovidVaccinations AS Vac
	ON Dea.continent = Vac.continent
	AND Dea.location = Vac.location
	AND Dea.date = Vac.date
)

SELECT continent, location, date, new_cases, RollingInfected, population, (RollingInfected/population)*100 AS infection_percentage
FROM PopvsCase
ORDER BY 1,2,3


--Create VIEW 

CREATE VIEW PercentPopulationInfected AS
WITH PopvsCase (continent, location, date, new_cases, RollingInfected, population)
AS
(
SELECT dea.continent, dea.location, LEFT(CAST(dea.date AS date), 10) AS date, dea.new_cases
, SUM(dea.new_cases) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingInfected, Vac.population
--, (Rolling/population)*100 AS infection_percentage
FROM PortfolioProject1..CovidDeaths AS Dea
JOIN PortfolioProject1..CovidVaccinations AS Vac
	ON Dea.continent = Vac.continent
	AND Dea.location = Vac.location
	AND Dea.date = Vac.date
)

SELECT continent, location, date, new_cases, RollingInfected, population, (RollingInfected/population)*100 AS infection_percentage
FROM PopvsCase
--ORDER BY 1,2,3

--Review

SELECT * 
FROM PercentPopulationInfected
ORDER BY 1,2,3

