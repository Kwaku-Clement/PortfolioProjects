/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select * from CovidDeaths
where continent is not null
order by 3, 4

select * from CovidVaccination
where continent is not null
order by 3, 4

--select data to work with

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths 
where continent is not null
order by 1, 2 desc


--shows what percentage of the population per country died from covid-19

select Location, date, total_cases, total_deaths, population,
(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1, 2

--shows what percentage of the population got infected with covid-19

select Location, date, population, total_cases,
(cast(total_cases as float)/cast(population as float))*100 as PopulationInfected
from CovidDeaths
where continent is not null
order by 1, 2

--countries with highest infection rate
select Location, population, max(total_cases)as HighestInfection,
max((cast(total_cases as float)/cast(population as float)))*100 as PopulationInfectedPercentage
from CovidDeaths
where continent is not null
group by location, population
order by PopulationInfectedPercentage desc

--countries with highest death count per population
select Location, max(cast(total_deaths as float)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--continent with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--continent with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as float)) as total_deaths,
sum(cast(new_deaths as float))/sum(new_cases)* 100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2

select * from CovidDeaths death
join CovidVaccination vaccine
on death.location = vaccine.location
and death.date = vaccine.date

--select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations 
--, sum(convert(float, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as total_new_vaccination
--from CovidDeaths death
--join CovidVaccination vaccine
--on death.location = vaccine.location
--and death.date = vaccine.date
--where death.continent is not null
--order by 2, 3

--using cte

with PopuVaccinated (Continent, Location, Date, Population, New_vaccinations, total_new_vaccination)
as 
(select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations , sum(convert(float, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as total_new_vaccination
from CovidDeaths death
join CovidVaccination vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
)
select *, (total_new_vaccination/population) * 100 as total_vaccinations
from PopuVaccinated

--using Temp table
drop table if exists #PercentagePopuVaccinated
create table #PercentagePopuVaccinated (
continet nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacciantions numeric,
total_new_vaccination numeric)

insert into #PercentagePopuVaccinated
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations , sum(convert(float, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as total_new_vaccination
from CovidDeaths death
join CovidVaccination vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null

select *, (total_new_vaccination/population) * 100 as total_vaccinations
from #PercentagePopuVaccinated

--creating views to store data for visualization

DROP VIEW if exists [dbo].PercentagePopulationVaccinated
GO

create view [dbo].PercentagePopulationVaccinated as
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations , 
sum(convert(float, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as total_new_vaccination
from CovidDeaths death
join CovidVaccination vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
GO

select * from PercentagePopulationVaccinated

--view for continent with highest death count per population

drop view if exists TotalDeathCountView
go

create view [dbo].[TotalDeathCountView] as 
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
group by location
go

select * from TotalDeathCountView