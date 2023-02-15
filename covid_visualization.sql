use Portfolio;

select count(*) 
from coviddeaths;

select count(*) 
from covidvaccinations;

select *
from covidvaccinations 
order by 3,4 
limit 5;


-- let's look at the data we have here.
select Location, date, population, total_cases, new_cases, total_deaths
from coviddeaths
order by 1,2 desc
limit 5;

-- total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
order by 1,2

-- likelihood of dying if contracted in my country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location like '%India'
order by 1,2

-- looking at the total cases Vs Population
-- likelihood of you being infeccted considering the country you populate in

select Location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
from coviddeaths
where location like '%India'
order by 1,2


-- looking at countries with highest infected rate

select Location, Population, Max(total_cases), Max((total_cases/population))*100 as infected_percentage
from coviddeaths
where location not like '%World' 
group by Location, Population
order by 4 desc

-- countries with highest death
select location, Max(cast(total_deaths as double)) as death
from coviddeaths
where location not like '%World' and continent <> ""
group by location
order by 2 desc

-- these are all the continents
select * from coviddeaths where continent = ""

-- check the continent location (excluding the countries data above in these continents. )
select location, Max(cast(total_deaths as double)) as death
from coviddeaths
where continent = ""
group by location
order by 2 desc

-- get the global view for new cases / new deaths and the death percentage

select date, sum(new_cases) new_cases, sum(cast(new_deaths as double)) as new_death, (sum(cast(new_deaths as double))/sum(new_cases))*100 as death_percent_per_day
from coviddeaths
where continent <> ""
group by date
order by date

-- total death percentage for the new cases

select sum(new_cases) new_cases, sum(cast(new_deaths as double)) as new_death, (sum(cast(new_deaths as double))/sum(new_cases))*100 as death_percent_per_day
from coviddeaths
where continent <> ""
# overall in the world we are looking at a death percentage of 1% in the above query

-- covid vaccinations

select * from covidvaccinations

-- total vaccinations world wide

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations , 
sum(convert(cv.new_vaccinations, double)) over (partition by cv.location order by cv.location, cv.date) vaccination_rolling
from coviddeaths cd
join
 covidvaccinations cv on cd.location=cv.location and cd.date=cv.date
where cd.continent <> ""
order by 1,2,3


-- use cte
with popVSvacc ( continent, location, date, population, new_vaccinations, rolling_vaccinations
)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations , 
sum(convert(cv.new_vaccinations, double)) over (partition by cv.location order by cv.location, cv.date) vaccination_rolling
from coviddeaths cd
join
 covidvaccinations cv on cd.location=cv.location and cd.date=cv.date
where cd.continent <> ""
-- order by 1,2,3
)
select *, rolling_vaccinations/population*100 as vaccination_percentage
from popVSvacc
 
 
 -- Temp Table
Drop TEMPORARY table if exists percentPopulationVaccinated;
CREATE TEMPORARY TABLE percentPopulationVaccinated
(	continent nvarchar(255),
    location nvarchar(255),
    date_marked timestamp,
    population bigint(255),
    new_vaccinations integer(255),
    rolling_vaccinations bigint(255)
);
Insert into  percentPopulationVaccinated 
select cd.continent, cd.location, cd.date, cd.population, cast(cv.new_vaccinations as double), 
sum(convert(cv.new_vaccinations, double)) over (partition by cv.location order by cv.location, cv.date) rolling_vaccinations
from coviddeaths cd
join
 covidvaccinations cv 
 on 
 cd.location=cv.location and cd.date=cv.date;


select *, rolling_vaccinations/population*100 as vaccination_percentage
from percentPopulationVaccinated;

-- creating a view for the same.
create view percentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cast(cv.new_vaccinations as double), 
sum(convert(cv.new_vaccinations, double)) over (partition by cv.location order by cv.location, cv.date) rolling_vaccinations
from coviddeaths cd
join
 covidvaccinations cv 
 on 
 cd.location=cv.location and cd.date=cv.date
where cd.continent <> "";




 
