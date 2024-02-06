create database portfolioProject;
use  portfolioProject;
select * from covid_deaths order by 3,4;
-- select * from covid_vaccinations order by 3,4;

select location,date, total_cases, new_cases, total_deaths, population from covid_deaths order by 1,2;

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in yur country

 select  location,sum(total_cases), sum(total_deaths)from covid_deaths group by location;

select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
 from covid_deaths where location like '%libya%'  order by 1,2;
 
 -- looking at the total cases vs population
 -- shows what percentage of population got covid 
 select location,date, total_cases,population,(total_cases/population)*100 as infectedpercentage
 from covid_deaths where location like '%libya%'  order by 1,2;
 
 -- looking at countries with highest infection rate compared to population--
  select location,population ,max(total_cases) as highest_infection,max(total_cases/population)*100 
  as infectedpercentage from covid_deaths 
  group by location,population 
  order by infectedpercentage desc;
  
  -- countries with the highest of deaths counts per population--
  select location,max(cast(total_deaths as signed)) 
  as totalDeathsCounts 
from covid_deaths  where continent is  not null
  group by location 
  order by totalDeathsCounts desc;
  
  -- lets break things down by continent--
    -- showing  continents with highest death count per population --

   select continent,max(cast(total_deaths as signed)) 
  as totalDeathsCounts 
from covid_deaths where continent is not null
  group by continent  
  order by totalDeathsCounts desc;
  
-- Global numbers --

   select sum(new_cases) as total_cases,sum(cast(new_deaths as signed))
   as total_deaths,
   sum(cast(new_deaths as signed)) / sum(new_cases)*100 as Death_percentage
   from covid_deaths 
-- where location like '%libya%' --
 where  continent is not null
 -- group by date
 order by  1,2;

-- looking at total population vs Vaccinations--

-- use CTE--
with Popvsvac(continent, location,date,population,new_vaccinations,
RollingPeopleVaccinated) as (
select covid_deaths.continent,covid_deaths.location,covid_deaths.date,
covid_deaths.population,covid_vaccinations.new_vaccinations,
sum(covid_vaccinations.new_vaccinations) over (partition by covid_deaths.location
 order by covid_deaths.location,covid_deaths.date) as RollingPeopleVaccinated
  -- , (RollingPeopleVaccinated/populaton)*100
 from covid_deaths  join covid_vaccinations on
 covid_deaths.location = covid_vaccinations.location and
 covid_deaths.date = covid_vaccinations.date
where  covid_deaths.continent is not null
 -- order by 2,3
 )
 select*, (RollingPeopleVaccinated/population) * 100 from Popvsvac;
 
 
 -- temp table--
 
 drop table if exists PercentPopulationvaccinated;
Create temporary table PercentPopulationvaccinated
(continent VARCHAR(255),
location VARCHAR(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric );
 
 insert into PercentPopulationvaccinated
 select covid_deaths.continent, covid_deaths.location, covid_deaths.date,
covid_deaths.population, covid_vaccinations.new_vaccinations,
sum(covid_vaccinations.new_vaccinations) over (partition by covid_deaths.location,
 covid_deaths.date order by covid_deaths.location, covid_deaths.date) 
 as RollingPeopleVaccinated from covid_deaths
join covid_vaccinations on
covid_deaths.location = covid_vaccinations.location and
covid_deaths.date = covid_vaccinations.date
where covid_deaths.continent is not null ; -- as tinku
 
 
 SELECT *,(RollingPeopleVaccinated / population) * 100 
 AS PercentageVaccinated
FROM ( SELECT *, RollingPeopleVaccinated
FROM PercentPopulationvaccinated) AS SubqueryAlias; 
 
  -- creating view to store data for later visualization
  
  create view  PercentPopulationvaccinated as
  select covid_deaths.continent,covid_deaths.location,covid_deaths.date,
covid_deaths.population,covid_vaccinations.new_vaccinations,
sum(covid_vaccinations.new_vaccinations) over (partition by covid_deaths.location
 order by covid_deaths.location,covid_deaths.date) as RollingPeopleVaccinated
  -- , (RollingPeopleVaccinated/populaton)*100
 from covid_deaths  join covid_vaccinations on
 covid_deaths.location = covid_vaccinations.location and
 covid_deaths.date = covid_vaccinations.date
where  covid_deaths.continent is not null ;


  
  

 

