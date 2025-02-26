--SELECT * FROM portfolioprojects.dbo.CovidDeaths$
--order by 3,4
--SELECT * FROM portfolioprojects..Covidvaccinations34$
--order by 3,4
--select Data that we are going to use
--The data shows likelyhood of dying from covid in my country which is very less ie is around 3 percent
SELECT location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage from portfolioprojects..CovidDeaths$
where location like '%India%'
order by 1,2

--looking at total cases vs population
--shows what popullation got covid
SELECT location,date,total_cases, population,(total_cases/population)*100 as percentofpopulationinfected from portfolioprojects..CovidDeaths$
where location like '%India%'
order by 1,2
--looking at countries with highest infection rate compared to population

SELECT location,MAX(total_cases) as highestinfectioncount,  Max(total_cases/population)*100 as 
percentofpopullationinfected from portfolioprojects..CovidDeaths$
--where location like '%India%'
Group by location,population
order by percentofpopullationinfected 
--showing the countries with highest death count per population
--LETS BREAK DOWN THE DATA WITH CONTINENTS
SELECT location, MAX(cast (total_deaths as int)) as totaldeath_count
 from portfolioprojects..CovidDeaths$
--where location like '%India%'
where continent is not null
Group by location
order by totaldeath_count desc


--Global Numbers
SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)),SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioprojects..CovidDeaths$
where continent is not null
group by date
order by 1,2
--looking at total popullation
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by  dea.location order by dea.location,
dea.date) as rollingpeoplevaccination
FROM portfolioprojects..CovidDeaths$ as dea
JOIN portfolioprojects..Covidvaccinations34$ as vac
 on dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
 order by 2,3
 --USING CTES TO GET ROLLINGVACCINATION?POPULLATION DATA FROM A TABLE

 WITH Popsvsvac(continent,locations,date,Population,new_vaccinations,rollingpeoplevaccinated)
 as
 (SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by  dea.location order by dea.location,
dea.date) as rollingpeoplevaccination
FROM portfolioprojects..CovidDeaths$ as dea
JOIN portfolioprojects..Covidvaccinations34$ as vac
 on dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
 )select *,(rollingpeoplevaccinated/Population)*100 from Popsvsvac

 --TEMP TABLE
 Create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric)
 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by  dea.location order by dea.location,
dea.date) as rollingpeoplevaccination
FROM portfolioprojects..CovidDeaths$ as dea
JOIN portfolioprojects..Covidvaccinations34$ as vac
 on dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
 --order by 2,3 
 select *,(rollingpeoplevaccinated/population)*100 from #PercentPopulationVaccinated



 --creating view for data visualization
 CREATE VIEW PercentPopulationVaccinated as
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by  dea.location order by dea.location,
dea.date) as rollingpeoplevaccination
FROM portfolioprojects..CovidDeaths$ as dea
JOIN portfolioprojects..Covidvaccinations34$ as vac
 on dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
 --order by 2,3

select* from PercentPopulationVaccinated