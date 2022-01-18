-- Full data set

SELECT * 
FROM portfolio_project..covid_deaths$;

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project..covid_deaths$
ORDER BY location, date;

-- Replacing NULL values in total_deaths column with 0

SELECT ISNULL(total_deaths, 0) 
FROM portfolio_project..covid_deaths$;

--select sum(total_deaths) from portfolio_project..covid_deaths$ order by location;
-- Above code shows that total_deaths column is specified as a VARCHAR 

-- Looking at Total cases vs Total Deaths per country
-- Shows likelihood of dying if you contracted covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM portfolio_project..covid_deaths$
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at total cases vs the population
-- Shows how much of the population of each country tested positive for COVID

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS Total_cases_vs_Population
FROM portfolio_project..covid_deaths$
ORDER BY 1,2;

-- What countries have the highest infection rates compared to population

SELECT location, MAX(total_cases) AS Highers_Infection_Count, MAX((total_cases/population)*100) AS Max_infection_rate  
FROM portfolio_project..covid_deaths$
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY Max_infection_rate DESC;

-- What countries have the highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) AS Highest_Death_Count, MAX((total_deaths/population)*100) AS Max_Death_rate
FROM portfolio_project..covid_deaths$
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY Max_Death_rate DESC;


-- Checking death rates by continent

SELECT continent, MAX(CAST(total_deaths as int)) AS Total_death_count, MAX((total_deaths/population)*100) AS Max_death_rates
FROM portfolio_project..covid_deaths$
WHERE continent is not null
GROUP BY continent
ORDER BY Max_death_rates DESC;



-- Global Numbers

SELECT SUM(total_cases) AS Total_cases, SUM(CAST(total_deaths as int)) AS Total_deaths, SUM(CAST(total_deaths as int))/SUM(total_cases)*100 AS Death_percentage
FROM portfolio_project..covid_deaths$
WHERE continent is not null
ORDER BY 1,2;


-- Checking covid_vaccination table

SELECT * 
FROM portfolio_project..covid_vaccinations$;

-- Joining two tables
-- Looking at Total populatoin vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM portfolio_project..covid_deaths$ dea
JOIN portfolio_project..covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- adding up new vaccinations

SELECT dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM portfolio_project..covid_deaths$ dea
JOIN portfolio_project..covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- How many ppl in each country got the vaccination

SELECT dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations   
FROM portfolio_project..covid_deaths$ dea
JOIN portfolio_project..covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
AS
(
SELECT dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations   
FROM portfolio_project..covid_deaths$ dea
JOIN portfolio_project..covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (TotalVaccinations/population)*100 AS VaccinationRate
FROM PopvsVac;

-- USING TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(155),
locatoin nvarchar(155),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations   
FROM portfolio_project..covid_deaths$ dea
JOIN portfolio_project..covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated;


-- Creating a view to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations, 
	   SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations   
FROM portfolio_project..covid_deaths$ dea
JOIN portfolio_project..covid_vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


-- Querying off of the created view

SELECT * 
FROM PercentPopulationVaccinated;