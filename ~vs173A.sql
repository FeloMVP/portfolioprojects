select*
from [portfolio project].dbo.coviddeaths

select *
from [portfolio project].dbo.covidvaccine

create table covidgeen
(android_id int,
full_name varchar(50),
first_name varchar(50))

select *
from [portfolio project].dbo.coviddeaths
order by 3,4

select *
from [portfolio project].dbo.covidvaccine
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths
order by 1,2

--looaking at total cases vs total deaths
--% of people whio died

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
order by 1,2

--choosing location when not sure with the name using the like option
--shows likelyhood if you contract covid in kenya
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from coviddeaths
where location like 'k%en%'
order by 1,2

--looking at total cases vs population
--shows % population with covid
select location,date,population,total_cases,(total_cases/population)*100 as percentofpopulationinfected
from coviddeaths
where location like '%states%'
order by 1,2

--highest infection rate according to population
select location,population,total_cases,(total_cases/population)*100 as infection_rate
from coviddeaths
ORDER BY 4 DESC

--ABOVE IS MY TRIAL. INSTRUCTORS TRIAL
select location,population,max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as percentofpopulationinfected
from coviddeaths
group by location,population
ORDER BY percentofpopulationinfected desc

--show country with highest death count per populat
--instructors trial below

select location, max(cast(total_deaths as int)) as totaldeathcount
from [portfolio project].dbo.coviddeaths
where continent is not null
group by location
order by totaldeathcount desc

--LETS BREAK THIS BASED ON CONTINENT
select continent, max(cast(total_deaths as int)) as totaldeathcount
from [portfolio project].dbo.coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc


select  location,max(cast(total_deaths as int)) as totaldeathcount
from [portfolio project].dbo.coviddeaths
where continent is  null
group by location
order by totaldeathcount desc



--issue with data type hence above was converted to an integer, issue was total_deaqth data type
--my trial
select location,max(total_deaths) as deathcount
from [portfolio project].dbo.coviddeaths
group by location
order by deathcount desc


--LETS BREAK THIS BASED ON CONTINENT
--continents with highest death count
select continent, max(cast(total_deaths as int)) as totaldeathcount
from [portfolio project].dbo.coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc


--global numbers

select date,sum(new_cases)
from coviddeaths
where continent is not null
group by date
order by 1,2

--correct one, shows total cases on each day ,death and total death percentage daily
select date,sum(new_cases)as cases,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercfent,sum(cast(new_deaths as int)) as deaths
from [portfolio project].dbo.coviddeaths
where continent is not null
group by date
order by 1,2

--shows total for the continent during the whole period
select sum(new_cases)as cases,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercfent,sum(cast(new_deaths as int)) as deaths
from [portfolio project].dbo.coviddeaths
where continent is not null
order by 1,2


select*
from [portfolio project].dbo.covidvaccine

--joining the tables
select*
from coviddeaths  dea
join covidvaccine vac
on dea.location=vac.location
and dea.date=vac.date

--total vaccination vs total population
select (char(vac.total_vaccination)as int)
from coviddeaths  dea
join covidvaccine vac
on dea.location=vac.location
and dea.date=vac.date

--correct one
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from coviddeaths  dea
join covidvaccine vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 3,2


++--fromm the cte bellow. show loacation and new vaccinations

with popsvac (continent,date,location,population,new_vaccinations,rollingpeoplevaccinated)
as 
(
select dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from coviddeaths  dea
join covidvaccine vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select distinct(continent),count(rollingpeoplevaccinated)
from popsvac
group by continent


--temp tables
DROP table if exists #percpopln
create table #percpopln
(continent nvarchar(255),
location nvarchar(255),
date nvarchar(255),
population numeric,
new_vacc numeric,
rollingpeoplevaccinated  numeric) 

insert into #percpopln
select dea.continent,dea.location, dea.date,population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from coviddeaths  dea
join covidvaccine vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *
from #percpopln

--creating view to store for later visualization

create view testview as
select dea.continent,dea.location, dea.date,population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from coviddeaths  dea
join covidvaccine vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
