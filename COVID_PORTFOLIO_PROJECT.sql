select * from Portfolio_project..covid_death;


select * from Portfolio_project..covid_death where continent is not null
order by 3,4;

--select * 
--from covid_vaccinations 
--order by 3,4;

---select data that we are going to be useing

select location,date ,total_cases, new_cases,total_deaths,population
from Portfolio_project..covid_death 
where continent is not null
order by 3,4;

---looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location,date ,total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from Portfolio_project..covid_death 
where location like '%states%' and continent is not null
order by 1,2;

---looking at the total cases vs population
--shows what percentage of population got covid

select location,date , population ,total_cases, (total_cases/population)*100 as percentage_population_infected
from Portfolio_project..covid_death 
--where location like '%states%'
where continent is not null
order by 1,2;

--looking at countries with highest infection rate compared to population

select location, population , max(total_cases) as highes_tinfection_count, max((total_cases/population))*100 as percentage_population_infected
from Portfolio_project..covid_death 
--where location like '%states%'
group by  location, population
order by percentage_population_infected desc;

---showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count
from Portfolio_project..covid_death 
--where location like '%states%'
where continent is not null
group by  location
order by total_death_count desc;

---showing the continents with highest  death count per population

---LET'S BREAK THINGS DOWN BY CONTINENT


select continent, max(cast(total_deaths as int)) as total_death_count
from Portfolio_project..covid_death 
--where location like '%states%'
where continent is not null
group by continent
order by total_death_count desc;


---global number 

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
--- total_deaths,(total_deaths/total_cases)*100 as death_percentage
from Portfolio_project..covid_death 
---where location like '%states%' 
where continent is not null
---group by date
order by 1,2;

---total at population vs vaccinations


select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int ,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
from Portfolio_project..covid_death dea
 join Portfolio_project..covid_vaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3
 

 ---use CTE
 with popvsvac (continent,location,date,population, new_vaccinations,rolling_people_vaccinated)
as
(
select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int ,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
from Portfolio_project..covid_death dea
 join Portfolio_project..covid_vaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select*,(rolling_people_vaccinated/population)*100
 from popvsvac

 --temp table
 
 drop table if exists #percent_population_vaccinated
 create table #percent_population_vaccinated
 (
 continent nvarchar (255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rolling_people_vaccinated numeric
 )



insert into #percent_population_vaccinated
 select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int ,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
from Portfolio_project..covid_death dea
 join Portfolio_project..covid_vaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 --where dea.continent is not null
 --order by 2,3
 select*,(rolling_people_vaccinated/population)*100
 from #percent_population_vaccinated


 --- creating  view to store data for later visualization

 create view percent_population_vaccinated as
 select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int ,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
from Portfolio_project..covid_death dea
 join Portfolio_project..covid_vaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3

 select * from percent_population_vaccinated


