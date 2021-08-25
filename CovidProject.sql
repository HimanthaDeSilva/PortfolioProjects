select * from portfolioProject1..['owid-covid-data -deaths$'] 
where continent is not null
order by 3,4;

select * from portfolioProject1..['owid-covid-data -vaccinations$'] order by 3,4;

--SELECT DATA THAT I'M GOING TO USE

select location, date, total_cases, new_cases, total_deaths,population
from portfolioProject1..['owid-covid-data -deaths$']
order by 1,2;

-- LOOKING FOR TOTAL CASES VS TOTAL DEATHS

select location, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject1..['owid-covid-data -deaths$']
where location like '%states%'
order by 1,2;

-- LOOKING FOR TOTAL CASES VS POPULATION

select location,date,total_cases,population,(total_cases/population)*100 as DeathPercentage
from portfolioProject1..['owid-covid-data -deaths$']
where location like '%sri%'
order by 1,2;

-- LOOKING FOR HIGHEST INFECTION RATES COMPARED TO POPULATION

select location, MAX(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as  DeathPercentage
from portfolioProject1..['owid-covid-data -deaths$']
where location like '%states%'
group by location,population
order by DeathPercentage desc;

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT OR POPULATION

select location, max(cast(total_deaths as int)) as TotalDeathCount
from portfolioProject1..['owid-covid-data -deaths$']
where continent is not null 
group by location
order by TotalDeathCount desc;

-- LETS BREAK THINGS DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNTS

select location,max(cast(total_deaths as int)) as TotalDeathCount
from portfolioProject1..['owid-covid-data -deaths$']
where location is not null
group by location
order by TotalDeathCount desc;

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from portfolioProject1..['owid-covid-data -deaths$']
where continent is not null
group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

select date,total_cases,total_deaths,(total_cases/population)*100 as DeathPercentage
from portfolioProject1..['owid-covid-data -deaths$']
--where location like '%sri%'
where continent is not null
group by date
order by 1,2;

select new_cases
from portfolioProject1..['owid-covid-data -deaths$'];

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioProject1..['owid-covid-data -deaths$']
where continent is not null
group by date
order by 1,2;

select * 
from portfolioProject1..['owid-covid-data -vaccinations$']

--JOINING BOTH TABLES TOGETHER

select *
from portfolioProject1..['owid-covid-data -deaths$'] dea
join portfolioProject1..['owid-covid-data -vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date;

-- LOOKING FOR TOTAL POPULATION VS VACCINATIONS
with PopvsVac (Continent, Location, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.population, vac.new_vaccinations, 
		sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject1..['owid-covid-data -deaths$'] dea
join portfolioProject1..['owid-covid-data -vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Population numeric,
date numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject1..['owid-covid-data -deaths$'] dea
join portfolioProject1..['owid-covid-data -vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulation
from #PercentPopulationVaccinated

-- CRAETING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create view ##PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
		sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolioProject1..['owid-covid-data -deaths$'] dea
join portfolioProject1..['owid-covid-data -vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

