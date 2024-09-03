        /*Select Data that we are going to be starting with */

select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Projects]..PandemicDeaths
order by 1,2 

			/* Percentage of death out of total cases */
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Projects]..PandemicDeaths
order by 1 , DeathPercentage desc

			/* Total Cases vs Total Deaths */
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Projects]..PandemicDeaths
where location like '%states%' 
order by 5 desc

			/* Looking at total Cases vs Population */
select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from [Portfolio Projects]..PandemicDeaths
where location like '%states%' 
order by 5 desc


								/* No. of countries infected */
select location 
from [Portfolio Projects]..PandemicDeaths
group by (location)
order by 1

					/* Countries with highest infection rate */
select location,population,Max(total_cases) as MaxInfection, Max(total_cases/population)*100 as PercentagePopulationInfected
from [Portfolio Projects]..PandemicDeaths
group by location,population
order by 4 desc

             /* Countries with highest death count per population */

select location,Max(cast (total_deaths as int)) as TotalDeathCount
from [Portfolio Projects]..PandemicDeaths
where continent is not null
group by location
order by TotalDeathCount desc

 
                 /* Breaking down into continents */
select continent , max(cast(total_deaths as int))
from [Portfolio Projects]..PandemicDeaths
where continent is not null
group by continent
order by 2


								/* Continents with the hightest death count per population */
select continent,max(cast(total_deaths as int))
from [Portfolio Projects]..PandemicDeaths
where continent is not null 
group by continent


							/* Global Numbers or Scenario */
select sum(new_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths, (sum(cast(total_deaths as int))/sum(new_cases))*100 as DeathPercentage
from [Portfolio Projects]..PandemicDeaths
where continent is not null
--group by date
order by 1,2


                                          /* Working on multiple dataset by joing tables */

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(convert(int ,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as TotalVacci
from [Portfolio Projects]..PandemicDeaths dea
join [Portfolio Projects]..Vaccination vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE to perform Calculation on Partition By in previous query

with popVSvac(continent,location,date,population,new_vaccination,totalvac)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Totalvac
from [Portfolio Projects]..PandemicDeaths dea
join [Portfolio Projects]..Vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * , (totalvac/population)*100 as Totalvac
from popVSvac



/* Using Temp Table to perform Calculation on Partition By in previous query */
drop table if exists #temp
CREATE TABLE #temp
(continent nvarchar(255),location nvarchar(255), date datetime,
population numeric,new_vaccination numeric,rolling numeric)

Insert into #temp
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rolling
from [Portfolio Projects]..PandemicDeaths dea
join [Portfolio Projects]..Vaccination vac
on dea.location = vac.location
and dea.date = vac.date

select *
from #temp


/* Creating View to store data for later visualizations */

create view PercentPopulaionVaccinatedd as
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from [Portfolio Projects]..PandemicDeaths dea
join [Portfolio Projects]..Vaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulaionVaccinatedd