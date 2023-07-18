select * from CovidDeath

select location, date, total_cases, new_cases, total_deaths from CovidDeath
order by 1,2

alter table CovidDeath alter column total_cases float

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeath
where location like '%india%'
order by 1,2


--Looking at total cases vs population

select location, date, total_cases, population, new_cases, (total_cases/population)*100 as PopulationPercentage
from CovidDeath
where location like '%india%'
order by 1,2

-- Countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeath
group by location, population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

select location, population, MAX(total_deaths) as HighestDeathCount
from CovidDeath 
where continent is not null
group by location, population
order by HighestDeathCount desc	


-- Showing continent with highest death count

--select location, MAX(total_deaths) as HighestDeathCount
--from CovidDeath 
--where continent is null
--group by location
--order by HighestDeathCount desc	

select continent, MAX(total_deaths) as HighestDeathCount
from CovidDeath 
where continent is not null
group by continent
order by HighestDeathCount desc	


--GLOBAL NUMBERS

select  date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeath,
(sum(new_deaths)/NULLIF(sum(new_cases),0))*100 as DeathPercentage
from CovidDeath
where continent is not null
group by date
order by 1,2


select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeath,
(sum(new_deaths)/NULLIF(sum(new_cases),0))*100 as DeathPercentage
from CovidDeath
where continent is not null
order by 1,2

-- Total population vs vaccination
alter table CovidVaccination alter column new_vaccinations float

select d.continent,d.location,d.date,d.population,v.new_vaccinations 
from CovidDeath d join CovidVaccination v on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

select sum(v.population) as TotalPopulation, sum(v.total_vaccinations) as TotalVaccination
from CovidDeath d join CovidVaccination v on d.location = v.location and d.date = v.date


select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location ) as SumVaccinations
from CovidDeath d join CovidVaccination v on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

--Rolling Count

select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as RollingVaccinations
from CovidDeath d join CovidVaccination v on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

-- Using CTE
 
with PopvsVac (continent,location,date, population,new_vaccinations,RollingVaccinations)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as RollingVaccinations
from CovidDeath d join CovidVaccination v on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
)
select *, (RollingVaccinations/population)*100
from PopvsVac

--TEMP TABLE

create table #PercentPopulationVaccinated(
Continent nvarchar(200), 
Location nvarchar(200),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingVaccinations numeric
)
insert into #PercentPopulationVaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as RollingVaccinations
from CovidDeath d join CovidVaccination v on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3


select *, (RollingVaccinations/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as RollingVaccinations
from CovidDeath d join CovidVaccination v on d.location = v.location and d.date = v.date
where d.continent is not null

select *
from PercentPopulationVaccinated