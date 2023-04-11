SELECT *
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject1.dbo.CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths 
--Shows the likelihood of dying if you contract COVID-19 in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of population got COVID-19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population
--Can add 'WHERE' to see the highest infection rate amongst population groups (smaller populations may have higher infection percentage due to nature of small population-smaller government power/funding/etc.)

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE population > 1000000
GROUP BY location, population
ORDER BY InfectionPercentage DESC


--Showing Countries with Highest Death Count per Population 

SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest deah count per population 


SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers 
--By date 

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total cases, deaths, and percentage of deaths worldwide

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at total population vs Vaccinations
--Can also cast to int by using 'CONVERT(int,column name)'

SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS RollingPeopleVaccinated
,--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
	WHERE death.continent IS NOT NULL
	ORDER BY 2,3

--Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
	WHERE death.continent IS NOT NULL
	--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingVaccinationPercent
FROM PopvsVac



--TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
	WHERE death.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingVaccinationPercent
FROM #PercentPopulationVaccinated


--Creating View to store data dor later viz(s)

CREATE View PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(cast(vacc.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS death
JOIN PortfolioProject1..CovidVaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
	WHERE death.continent IS NOT NULL
	--ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated