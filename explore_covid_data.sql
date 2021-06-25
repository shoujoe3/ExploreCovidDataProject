select * from public.covid_death_data
select * from public.covid_vacination_data

--select the date that we going to use

select location, date, total_cases, new_cases, total_deaths, population
from public.covid_death_data
order by 1, 2

--looking at total cases vs total deaths
--showing likelihood of dying by contracting covid based on country 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as perct_death
from public.covid_death_data
order by 1, 2

--usa

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as perct_death
from public.covid_death_data
where location like '%United Sta%'
order by 1, 2

--nigeria
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as perct_death
from public.covid_death_data
where location like '%Nigeria%'
order by 1, 2

--loking at total cases vs population
--showing percentage of population contracted covid 

--usa
select location, date, total_cases, population, (total_cases/population)*100 as perct_got_covid
from public.covid_death_data
where location like '%United Sta%'
order by 1, 2

--nigeria
select location, date, total_cases, population, (total_cases/population)*100 as perct_got_covid
from public.covid_death_data
where location like '%Nigeria%'
order by 1, 2

--indection rates by countries based on population 

select location, population, max(total_cases) as max_infection_count,  max((total_cases/population))*100 as perct_infection
from public.covid_death_data
group by 
	location, 
	population
order by perct_infection desc


--showng countries with highest death count per population

--whole world continents included
select location, population, max(total_deaths) as total_death_count
from public.covid_death_data
group by 
	location, 
	population
order by total_death_count desc

--just countries 
select location, population, max(total_deaths) as total_death_count
from public.covid_death_data
where continent is not null
group by 
	location, 
	population
order by total_death_count desc


--let's take a look as what's happening by continents

select location, population, max(total_deaths) as total_death_count
from public.covid_death_data
where continent is null
group by 
	location,
	population
order by total_death_count desc

--continets with the highest death count per population

select continent, max(total_deaths) as total_death_count 
from public.covid_death_data
where continent is not null
group by
	continent
order by total_death_count desc

--to do, add continents quaries for the other country quuaries 
-----------
-------
----
--


-- Global numbers 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as perct_death
from public.covid_death_data
where continent is not null
order by 1, 2

-- deaths and cases across the globe

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_death, 
(sum(new_deaths)/sum(new_cases))*100 as perct_death_gbl
from public.covid_death_data
where continent is not null
group by date
order by 1,2

--overall in the globe

select sum(new_cases) as total_cases, sum(new_deaths) as total_death, 
(sum(new_deaths)/sum(new_cases))*100 as perct_death_gbl
from public.covid_death_data
where continent is not null
order by 1,2

--total population vs vacination 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from public.covid_death_data dea
	join public.covid_vacination_data vac
		on dea.location = vac.location 
		and dea.date = vac.date
Where vac.continent is not null
order by 2, 3

--rolling count

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from public.covid_death_data dea
	join public.covid_vacination_data vac
		on dea.location = vac.location 
		and dea.date = vac.date
Where vac.continent is not null
order by 2, 3

--use cte

with pop_vac (continent, location, date, population, new_vaccinations, rolling_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from public.covid_death_data dea
	join public.covid_vacination_data vac
		on dea.location = vac.location 
		and dea.date = vac.date
Where vac.continent is not null
--order by 2, 3
)
select *, (rolling_count/population)*100 as perct_vac
from pop_vac

--using temp table------------------------------------------------------------------------
drop table if exists public.percent_population_vacinated
create table percent_population_vacinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_count, 
(select (rolling_count/population)*100 as perct_vac)
from public.covid_death_data dea
	join public.covid_vacination_data vac
		on dea.location = vac.location 
		and dea.date = vac.date
Where vac.continent is not null
order by 2, 3

select (rolling_count/population)*100 as perct_vac
from perct_pop_vac

select * from public.percent_population_vacinated
--------------------------------------------------------------------------------------------------------------

--create view for visualization 
create view population_vacinated as 
with pop_vac (continent, location, date, population, new_vaccinations, rolling_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_count
from public.covid_death_data dea
	join public.covid_vacination_data vac
		on dea.location = vac.location 
		and dea.date = vac.date
Where vac.continent is not null
--order by 2, 3
)
select *, (rolling_count/population)*100 as perct_vac
from pop_vac

select * from public.population_vacinated

--view for deaths by country 
create view population_death as 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as perct_death
from public.covid_death_data
where continent is not null
order by 1, 2

select * from public.population_death


--view for death per continents 
create view population_death_per_continent as 
select continent, max(total_deaths) as total_death_count 
from public.covid_death_data
where continent is not null
group by
	continent
order by total_death_count desc

select * from public.population_death_per_continent



