
select * from covid_deaths

--select data that we are going to be using
select location,date,total_cases,total_deaths,population,new_cases
from covid_deaths
order by 1,2

--percentage of people dying who got infected
select location,date,total_cases,total_deaths,(total_deaths::decimal/total_cases)*100 as death_percentage
from covid_deaths
--where location like '%ndia'
order by 1,2,4 

--percentage of population that got covid
select location,date,total_cases,population,
(total_cases::decimal/population)*100 as covid_case_ppln_percent
--where location like '%ndia'
from covid_deaths

--countries with highest covid rate compar to population
select location,population,max(total_cases),
max((total_cases::decimal/population))*100 as covid_case_ppln_percent
--where location like '%ndia'
from covid_deaths
group by location,population
order by covid_case_ppln_percent desc

--countries with highest death count compar to population
select location,max(cast(total_deaths as int))as totaldeathcount
--where location like '%ndia'
from covid_deaths
where (continent is not null and total_deaths is not null)
group by location,population
order by totaldeathcount desc

--break down by continents
select continent,max(cast(total_deaths as int))as totaldeathcount
--where location like '%ndia'
from covid_deaths
where (continent is not null and total_deaths is not null)
group by continent
order by totaldeathcount desc

--Global Numbers
select date, sum(new_cases)as total_cases, sum(new_deaths)as total_deaths, 
sum(new_deaths::decimal)/sum(new_cases)*100 as deathpercentage
from covid_deaths
--where location like '%ndia'
where (new_cases != 0 and new_cases is not null)
group by date
order by 1,2

--vaccination
--total population vs vaccination
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations)over(partition by d.location order by d.location,d.date)as rolling_population
from covid_deaths d 
join covid_vaccination v
 on d.location = v.location
 and d.date = v.date
 where d.continent is not null
order by 2,3

--using CTE
with popvsvac (continent,location,date,population,new_vaccinations,rolling_population)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations)over(partition by d.location order by d.location,d.date)as rolling_population
from covid_deaths d 
join covid_vaccination v
 on d.location = v.location
 and d.date = v.date
 where d.continent is not null
--order by 2,3
)
select*, (rolling_population/population)*100
from popvsvac

--Temp Table
--drop table if exists popvsvac
create temp table popvsvac
(
continent varchar (100),
Location varchar (100),
date date,
population numeric,
new_vaccinations numeric,
rolling_population numeric
);
Insert into popvsvac
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations)over(partition by d.location order by d.location,d.date)as rolling_population
from covid_deaths d 
join covid_vaccination v
 on d.location = v.location
 and d.date = v.date;
--where d.continent is not null
--order by 2,3

select *, (rolling_population/population)*100
from popvsvac

--creating view to store data for visualization
create view popvsvac as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations)over(partition by d.location order by d.location,d.date)as rolling_population
from covid_deaths d 
join covid_vaccination v
 on d.location = v.location
 and d.date = v.date
where d.continent is not null;
--order by 2,3

select*from popvsvac