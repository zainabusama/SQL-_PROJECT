SELECT*
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4
--SELECT*
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4
SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%state%' and  continent IS NOT NULL
ORDER BY 1,2

--loking at total cases VS total deaths
--showing the likehppd of dying if you contract covid in your country
SELECT location,date,total_cases,new_cases,population,(total_cases/population*100) as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%state%' and  continent IS NOT NULL
ORDER BY 1,2
--Looking AT countries with highest infection rate compared to population

SELECT location,population,Max(total_cases) as HighestInfectionCount,MAX((total_cases/population*100)) as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY Location,Population
ORDER BY PercentagePopulationInfected desc

--showing countries with highest death count per population


SELECT location,MAX(cast(total_deaths as int)) as TotalDeath
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeath desc
--break things down by continent


SELECT continent,MAX(cast(total_deaths as int)) as TotalDeath
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath desc


-- globa numbrers

SELECT date,SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int )) as TotalDeaths,SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%state%'
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2

--not grouped by dates

SELECT SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int )) as TotalDeaths,SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%state%'
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2
--getting vaccination table
SELECT*
FROM PortfolioProject..CovidVaccination

--looking at total population VS vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations))OVER(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--,MAX(RollingPeopleVaccinated)/dea.population
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location
and  dea.date=vac.date
WHERE dea.continent IS NOT NULL
order by 1,2,3
--using CTE
WITH PopVSVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations))OVER(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--,MAX(RollingPeopleVaccinated)/dea.population
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location
and  dea.date=vac.date
WHERE dea.continent IS NOT NULL
--order by 1,2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopVSVac 


--using Temp table
DROP Table if exists  #PerecentPopulationVaccinated
CREATE TABLE #PerecentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(225),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PerecentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations))OVER(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--,MAX(RollingPeopleVaccinated)/dea.population
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location
and  dea.date=vac.date
--WHERE dea.continent IS NOT NULL
--order by 1,2,3
SELECT*,( RollingPeopleVaccinated/Population)*100
FROM #PerecentPopulationVaccinated


--creating view to stire data for later visualization

Create View  PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations))OVER(partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--,MAX(RollingPeopleVaccinated)/dea.population
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location
and  dea.date=vac.date
WHERE dea.continent IS NOT NULL
--order by 1,2,3
SELECT*
FROM PercentPopulationVaccinated
