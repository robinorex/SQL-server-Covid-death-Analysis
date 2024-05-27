SELECT * FROM [Portfolio Project]..CovidDeaths ORDER BY 3,4
SELECT * FROM [Portfolio Project]..CovidVaccinations ORDER BY 3,4
UPDATE [Portfolio Project]..CovidDeaths
SET continent = NULL 
WHERE continent = ''
SELECT location,date,total_cases,new_cases, total_deaths,population FROM [Portfolio Project]..CovidDeaths order by 1;
--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from [Portfolio Project]..CovidDeaths
WHERE LOCATION LIKE '%ZEALAND%'
order by 1
---looking at total cases vs population
Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, POPULATION), 0)) * 100 AS COVIDPERCENTAGE
from [Portfolio Project]..CovidDeaths
WHERE LOCATION LIKE '%ZEALAND%'
order by 1
---HIGHEST INFECTION RATE
Select location,population, MAX(total_cases) AS HIGHEST_INFECTION_COUNT,
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, POPULATION), 0))) * 100 AS PERCENT_POPULATION_INFECTED
from [Portfolio Project]..CovidDeaths
--WHERE LOCATION LIKE '%ZEALAND%'
GROUP BY LOCATION, population
order by 4 DESC
--HIGHEST DEATH RATE
Select location, MAX(CAST(TOTAL_DEATHS AS INT)) AS HIGHEST_DEATH_COUNT
from [Portfolio Project]..CovidDeaths
--WHERE LOCATION LIKE '%ZEALAND%'
where continent is null
GROUP BY LOCATION
order by HIGHEST_DEATH_COUNT DESC
select*from [Portfolio Project]..CovidDeaths
--global numbers
Select date,sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(nullif(cast(new_cases as float),0)) *100 as death_percent
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1

Select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(nullif(cast(new_cases as float),0)) *100 as death_percent
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1


--select continent,sum(CONVERT(float, new_deaths))
--from [Portfolio Project]..CovidDeaths
--where continent!= ''
--group by continent

--looking at total population vs total vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as Rolling_Vaccinated
from [Portfolio Project]..CovidDeaths dea join 
[Portfolio Project]..CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3
--Use CTE to perfrom further/complex calculations
With PopulationvsVaccanation (continent, location,date,population,new_vaccinations,Rolling_Vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as Rolling_Vaccinated
from [Portfolio Project]..CovidDeaths dea join 
[Portfolio Project]..CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
select*,(Rolling_Vaccinated/nullif(cast(population as float),0))*100 from PopulationvsVaccanation
--Temp Table
drop table if exists #Percent_Population_Vaccinated1
Create Table #Percent_Population_Vaccinated1
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
new_vaccinations int,
Rolling_Vaccinated int
)
Insert into #Percent_Population_Vaccinated1
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as Rolling_Vaccinated
from [Portfolio Project]..CovidDeaths dea join 
[Portfolio Project]..CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
select*,(Rolling_Vaccinated/nullif(cast(population as float),0))*100 
from #Percent_Population_Vaccinated1;

--create view to store data for later viz
drop view if exists PercentPopulationVaccinated;

create view Percent_Population_Vaccinated1 as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as Rolling_Vaccinated
from [Portfolio Project]..CovidDeaths dea join 
[Portfolio Project]..CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select * from Percent_Population_Vaccinated1