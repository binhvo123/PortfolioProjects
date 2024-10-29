--Initial Data Check 

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
ORDER BY 3,4

--Select data we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2
 
-- Looking at total cases vs. total deaths in USA

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1,2

--Looking at percentage of US population infected by Covid

Select Location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states'
ORDER BY 1,2

--Looking at countries with highest infection rates

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY InfectionRate DESC

--Looking at countries with highest death count

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
GROUP BY Location
Order BY TotalDeathCount DESC

--Looking at continents with highest total death count

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS null
GROUP BY Location
Order BY TotalDeathCount DESC

--Looking at Global Cases, Deaths and Death Rates

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at all data from the vaccination table

SELECT * 
FROM PortfolioProject..CovidVaccinations

--Looking at total population vs. total vaccinations by country

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount, 
	(RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER by 2,3

--CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac
WHERE Location LIKE '%states%'

--TEMP TABLE

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
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATE VIEW FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER by 2,3
