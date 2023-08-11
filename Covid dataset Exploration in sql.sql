Select * from dbo.covidDeaths where continent is not NULL order by 3,4;
Select * from dbo.covidVaccinations;

select location, date, population, total_cases, new_cases, total_deaths from dbo.covidDeaths order by 1,2;

--shows likelihood of death percentage in all the countries
select location, date, population, total_cases,(total_deaths/population)*100 as deathPercentage from dbo.covidDeaths order by 1,2;

--total number of cases vs the number of infected 
select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as percernOfpeopleInfected  from dbo.covidDeaths where location like '%Af%' order by 1,2;

--percent of people infected in afganisthan 
select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as percernOfpeopleInfected  from dbo.covidDeaths where location like '%Af%' order by 1,2;

--looking at countries with highest infection rate

select location,population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as percentOfPopulationInfected from dbo.covidDeaths 
group by location, population
order by percentOfPopulationInfected desc;

--showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as highestDeathCount from dbo.covidDeaths 
where continent is not NULL
group by location, population 
order by highestDeathCount desc;

--showing countries with highest death count per continent
select continent, MAX(cast(total_deaths as int)) as highestDeathCount from dbo.covidDeaths 
where continent is not NULL
group by continent 
order by highestDeathCount desc;

--Global Numbers
--Shows the new cases and new dates per day
select date, sum(new_cases) as newCasePerDay, sum(cast(new_deaths as int) ) as DeathsPerDay from dbo.covidDeaths where continent is null group by date order by 1,2;

-- shows the death percentage per location
select date  , location, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage from dbo.covidDeaths 
where continent is not NULL
order by 1,2;  
 
 -- Global Death Percentage per day 
 select date, SUM(new_cases)as new_cases, SUM(new_deaths) as totaldeaths,
 case when sum(new_cases)>0 then SUM(new_deaths)/SUM(new_cases)*100 
 else null end as deathPercentage from dbo.covidDeaths
 where continent is not null
 group by date
 order by date;

 -- Global Death Percentage

 select SUM(new_cases)as new_cases, SUM(new_deaths) as totalDeaths,
 case when sum(new_cases)>0 then SUM(new_deaths)/SUM(new_cases)*100 
 else null end as deathPercentage from dbo.covidDeaths
 where continent is not null
 order by 1,2;

 --looking at population vs vaccinations

 select D.continent, D.location, D.date, D.population, V.new_vaccinations from covidDeaths D 
 join covidVaccinations V on D.location = V.location and D.date = V.date order by 2,3;

 --looking at population vs vaccination per location
  select D.continent, D.location, D.date, D.population, V.new_vaccinations, sum(new_vaccinations) OVER(PARTITION BY D.location order by D.location, D.date)  as rollingPeopleVaccinated from covidDeaths D 
 join covidVaccinations V on D.location = V.location and D.date = V.date order by 2,3;

 --- use CTE to compare the population with the vaccination
 With PopVsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated) as
  (select D.continent, D.location, D.date, D.population, V.new_vaccinations, sum(V.new_vaccinations) OVER(PARTITION BY D.location order by D.location, D.date)  as rollingPeopleVaccinated from covidDeaths D 
 join covidVaccinations V on D.location = V.location and D.date = V.date 
 )
 select *, case when rollingPeopleVaccinated>0 then (rollingPeopleVaccinated/population)* 100 else 0  end as popVSvac_percent from PopVsVac order by location, date;

 --Temp Table
 Drop table if exists #PercentPopulationVaccinated
 Create table #PercentPopulationVaccinated
 (continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingPeopleVaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
  select D.continent, D.location, D.date, D.population, V.new_vaccinations, sum(V.new_vaccinations) OVER(PARTITION BY D.location order by D.location, D.date)  as rollingPeopleVaccinated from covidDeaths D 
 join covidVaccinations V on D.location = V.location and D.date = V.date 
 
 select *, case when rollingPeopleVaccinated>0 then (rollingPeopleVaccinated/population)* 100 else 0  end as popVSvac_percent 
 from #PercentPopulationVaccinated 
 where continent is not null 
 order by popVSvac_percent desc;

 -- View
 Create view percentPopulationVaccinated as 
 select D.continent, D.location, D.date, D.population, V.new_vaccinations, sum(V.new_vaccinations) OVER(PARTITION BY D.location order by D.location, D.date)  
 as rollingPeopleVaccinated from covidDeaths D 
 join covidVaccinations V on D.location = V.location and D.date = V.date 

 select * from percentPopulationVaccinated
 
