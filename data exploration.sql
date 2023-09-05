/*
Covid 19 Data Exploration 

skilled used: Joins, CTE's, Temp Tables, Windows Functions, Aggreagate Functions, Creating Views, Converting Data Types

*/
select*
from CovidDeaths$
where continent is not null
order by 3,4

select*
from CovidVaccinations$
order by 3,4

select location, date, total_cases,	new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

--Total Cases vs Total Deaths
--Shows percentage of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by location, date, total_cases, total_deaths
order by 1

--Total Cases vs Population
--Shows waht percentage of population got covid

select location, date, total_cases, population, continent,  (total_cases/population)*100 as Infectedpop
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by location, date, total_cases, population, continent
order by 1,2


--Countries with Hightest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as Infectedpop
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by location, population
order by 4 desc

--Showing Countries with Highest Death Count
select location, sum(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null 
group by location
order by 2 desc


--Highest death count by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by continent
order by 2 desc


--Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from CovidDeaths$
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from CovidDeaths$ dea join CovidVaccinations$ vacc on 
dea.location = vacc.location 
and dea.date = vacc.date
where dea.continent is not null 
order by 2,3



--CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from CovidDeaths$ dea join CovidVaccinations$ vacc on 
dea.location = vacc.location 
and dea.date = vacc.date
where dea.continent is not null 
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from PopvsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from CovidDeaths$ dea join CovidVaccinations$ vacc on 
dea.location = vacc.location 
and dea.date = vacc.date
--where dea.continent is not null 
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from #PercentPopulationVaccinated


--creating view for view to store data for later 

Create View PercentPopulationVaccinated as 
 select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from CovidDeaths$ dea join CovidVaccinations$ vacc on 
dea.location = vacc.location 
and dea.date = vacc.date
where dea.continent is not null 
--order by 2,3

select*
from PercentPopulationVaccinated