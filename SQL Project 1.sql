--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select data that we are using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of duying 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs populations
--show what percent of population got Covid
select location, date, total_cases, population,(total_cases/population)*100 percentpopulationinfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--looking at which country is infection rate compare to population
select location, population, max(total_cases) HighestInfectionCount,max(total_cases/population)*100 percentpopulationinfected
from PortfolioProject..CovidDeaths
group by location, population
order by percentpopulationinfected desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--lets break things down by continent
select location, max(cast(total_deaths as int)) TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


---------------------------------------------------------------------------------------------------------------------------------------------
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location , dea.Date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date=vac.date
	and dea.location=vac.location
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location , dea.Date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date=vac.date
	and dea.location=vac.location
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location , dea.Date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date=vac.date
	and dea.location=vac.location
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations
create view PercentPopulationVaccinated2 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location , dea.Date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.date=vac.date
	and dea.location=vac.location
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated2
