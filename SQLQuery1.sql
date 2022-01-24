Select * 
From [dbo].[CovidDeaths]
order by 3,4

--Select * 
--From [dbo].[CovidVaccination]
--order by 3,4

--Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population 
From [dbo].[CovidDeaths]
order by 1,2


--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in america
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From [dbo].[CovidDeaths]
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as Infected_percentage
From [dbo].[CovidDeaths]
where location like '%states%'
order by 1,2

--finding which country have the highest infectious rate compared to population
Select location, MAX(total_cases) as Highest_Infection_Count, population, Max((total_cases/population))*100 as percent_population_infected
From [dbo].[CovidDeaths]
group by population, location
order by percent_population_infected desc

--showing countries with highest death count per population
--use cast method to convert to int
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
where continent is not null
group by location
order by TotalDeathCount desc

--break things down by continent
--showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From [dbo].[CovidDeaths]
--where location like '%states%'
where continent is not null
group by date 
--group the same date together 
order by 1,2
--output will have an error as there is calculations, too many things

--show new cases in each day
--new cases is a float
--new deaths is a nvarchar
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentages
from [dbo].[CovidDeaths]
where continent is not null
--group by date 
order by 1,2

--join 2 database together
--vac and dea are alias so that we dont have to type them  
select * 
from [dbo].[CovidVaccination] vac
join [dbo].[CovidDeaths] dea
	On dea.location= vac.location
	and dea.date = vac.date

--looking at total population vs vaccinations
--partition by means breaking the location individually
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as NumberOfPplVaccinatedPercentage
from [dbo].[CovidVaccination] vac
join [dbo].[CovidDeaths] dea
	On dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
--number of columns in with statement must match no. of columns in select statement
With PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as NumberOfPplVaccinatedPercentage
from [dbo].[CovidVaccination] vac
join [dbo].[CovidDeaths] dea
	On dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as NumberOfPplVaccinatedPercentage 
from PopvsVac



--Temp
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as NumberOfPplVaccinatedPercentage
from [dbo].[CovidVaccination] vac
join [dbo].[CovidDeaths] dea
	On dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as NumberOfPplVaccinatedPercentage 
from #PercentPopulationVaccinated


--creating view to store data for later visualizations
Create view PercentPopulationVaccinated as

Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as NumberOfPplVaccinatedPercentage
from [dbo].[CovidVaccination] vac
join [dbo].[CovidDeaths] dea
	On dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
from PercentPopulationVaccinated