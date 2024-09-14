select *
from ProjectPortfolio..CovidDeaths$
where continent is not null
order by 3,4


select Location, date, total_cases, total_deaths, population
from ProjectPortfolio..CovidDeaths$
where continent is not null
order by 1,2

--show likelyhood if you contract the virus in the country

select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
order by 1,2

--shows what percentage of population got covid
select Location, date, total_cases,(total_cases/population)*100 as PercentagePopulationInfected
from ProjectPortfolio..CovidDeaths$
where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population
select Location, Population, Max(total_cases) as HighestInfectioncount, Max((total_cases/population))*100 as PercentagePopulationInfected
from ProjectPortfolio..CovidDeaths$
where continent is not null
group by Location, population
order by PercentagePopulationInfected desc


--showing Countries with the Highest Death Count Per Population
select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths$
where continent is not null
group by Location
order by TotalDeathCount desc



--LET'S BREAK THINGS DOWN BY CONTINENT
select Location, MAX( cast(Total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc



--showing the continents with the highest death count


select continent, MAX( cast(Total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast
 (new_deaths as int))/ SUM(New_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
order by 1,2



--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac. date
 where dea.continent is not null
 order by 2,3


 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.Location, 
dea. date) as RollingPeopleVacinated

From ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac. date
 where dea.continent is not null
 order by 1, 2,3

 --USE CTE

  With PopvsVac(Continent, Location, date, Population, New_vaccinations, RollingPopVaccinated)
  as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.Location, 
dea. date) as RollingPopVacinated

From ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac. date
 where dea.continent is not null
-- order by 1, 2,3
 )
 Select *, (RollingPopVaccinated/Population)*100
 From PopvsVac


 --Temp Table

 Drop Table if exists #PercentpopulationVaccinated
 Create Table #PercentpopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 population numeric,
 New_Vaccinations numeric,
 RollingPopVaccinated numeric 
)


Insert into #PercentpopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.Location, 
dea. date) as RollingPopVacinated

From ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac. date
 --where dea.continent is not null
-- order by 1, 2,3
 
  Select *, (RollingPopVaccinated/Population)*100
 From #PercentpopulationVaccinated

 -- creating view to store data for later visualizations

 Create View  PercentpopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) Over(Partition by dea.Location Order by dea.Location, 
dea. date) as RollingPopVacinated

From ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac. date
 where dea.continent is not null
 --order by 1, 2,3

 select *
 from PercentpopulationVaccinated
