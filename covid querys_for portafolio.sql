select * from [dbo].[covid_vaccinations]
order by 3,4 ;

select * from [dbo].[covid_deaths]
where continent =' '
order by 3,4 ;

--select the data that we are going to be using 

select 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
from [dbo.covid_deaths]
order by 1,2
;
-- looking at total cases vs total deaths
--show likelihood  of dying if you  contract covid in your contry
select 
		location,
		date,
		cast(total_cases as numeric),
		cast(total_deaths as numeric),
		cast(total_deaths as numeric)/cast(total_cases as numeric)*100 as DeathPercentage
from [dbo].[covid_deaths]
where location = 'Peru'
order by 1,2 
;

--looking at total cases vs population
-- shows what percent of population got covid

select 
		location,
		date,
		population,
		cast(total_cases as numeric),
		cast(total_deaths as numeric),
		((cast(total_cases as numeric)/population))*100 as CasesPercentage
from [dbo].[covid_deaths]
where location = 'Peru'
order by 1,2
;

---looking at countries with hightest infections rate compares to  population
select 
		location,
		population,
		max(cast(total_cases as numeric))as hightest_infection_count,
		(max(cast(total_cases as numeric))/population)*100 as Percent_of_population_infected
from [dbo].[covid_deaths]
group by location, population
order by Percent_of_population_infected desc	
;
-- showing countries with the hightes deaths counts per population

select 
		location,
		population,
		max(cast(total_deaths as numeric))as hightest_mortality_count,
		(max(cast(total_deaths as numeric))/population)*100 as Percent_of_population_death
from [dbo].[covid_deaths]
group by location, population
order by Percent_of_population_death desc
;
--- showing countries with highets death count per population 
select 
		location,
		population,
		max(cast(total_deaths as numeric))as hightest_mortality_count
from [dbo].[covid_deaths]
where continent <> ' '
group by location, population
order by hightest_mortality_count desc
;

--let's break things down by continent
select 
		[continent],
		max(cast(total_deaths as numeric))as hightest_mortality_count,
		max(cast(population as numeric))as continent_population,
		(max(cast(total_deaths as numeric))/max(cast(population as numeric)))*100 as Percent_of_mortality
from [dbo].[covid_deaths]
where continent <> ' '
group by continent
order by hightest_mortality_count desc
;

--global numbers

select
	date,
	sum(cast(new_cases_smoothed as int)) as total_cases,
	sum(cast(new_deaths_smoothed as int)) as total_deaths,
	(sum(cast(new_deaths_smoothed as int))/sum(cast(new_cases_smoothed as int))) as percent_of_death
where  continent <> ' '
group by date
order by 1,2
;

--- loking at total population vs vaccinations
--forma chusca

select
 dea.continent,
 dea.location,
 dea.date,
 dea.population,
 vac.new_vaccinations_smoothed,
 SUM(CAST(vac.new_vaccinations_smoothed AS numeric)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingPeople_Vaccinatinated,
((SUM(CAST(vac.new_vaccinations_smoothed AS numeric)) OVER (Partition by dea.location order by dea.location,dea.date)/(cast(dea.population as numeric))*100)) as Percent_of
from [dbo].[covid_deaths] dea
join   [dbo].[covid_vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent <> ' '
order by 2,3

---forma con with

with popvsvac (Continent,location,date,population,New_vaccinations_smoothed,RollingPeopleVaccinated)
as
(
select
 dea.continent,
 dea.location,
 dea.date,
 dea.population,
 vac.new_vaccinations_smoothed,
 SUM(CAST(vac.new_vaccinations_smoothed AS numeric)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [dbo].[covid_deaths] dea
join   [dbo].[covid_vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent <> ' '
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac
ORDER BY 2,3

--CREATE A VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated as
select
 dea.continent,
 dea.location,
 dea.date,
 dea.population,
 vac.new_vaccinations_smoothed,
 SUM(CAST(vac.new_vaccinations_smoothed AS numeric)) OVER (Partition by dea.location order by dea.location,dea.date) as rollingPeople_Vaccinatinated,
((SUM(CAST(vac.new_vaccinations_smoothed AS numeric)) OVER (Partition by dea.location order by dea.location,dea.date)/(cast(dea.population as numeric))*100)) as Percent_of
from [dbo].[covid_deaths] dea
join   [dbo].[covid_vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent <> ' '
