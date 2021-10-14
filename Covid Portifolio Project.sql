SELECT *
FROM [Portifolio Project]..CovidDeaths$
where continent is not null
order by 3,4

--SELECT *
--FROM [Portifolio Project]..CovidVaccinations$
--order by 3,4

--Select the data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
From [Portifolio Project]..CovidDeaths$
where continent is not null
order by 1,2 

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portifolio Project]..CovidDeaths$
where location like '%Brazil%'
and continent is not null
order by 1,2 

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [Portifolio Project]..CovidDeaths$
where location like '%Brazil%' and continent is not null
order by 1,2 

--Comparing Countries with the highest infections rates and the Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From [Portifolio Project]..CovidDeaths$
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing Countries with the highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Portifolio Project]..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--EXPLORING THE DATA BY CONTINENT
--Showing Continents with the highest Death Count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Portifolio Project]..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(new_cases) as Total_Cases, SUM(cast(total_deaths as int)) as Total_Deaths,SUM(cast(total_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From [Portifolio Project]..CovidDeaths$
where continent is not null
order by 1,2 

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TPeopleVacctd
, (PeopleVacctd/population)*100
From [Portifolio Project]..CovidDeaths$ dea
Join [Portifolio Project]..CovidVaccinations$ vac 
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TPeopleVacctd)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TPeopleVacctd
--,(TPeopleVacctd/population)*100
From [Portifolio Project]..CovidDeaths$ dea
Join [Portifolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (TPeopleVacctd/population)*100
From PopvsVac

--TEMPTING TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TPeopleVacctd numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TPeopleVacctd
--,(TPeopleVacctd/population)*100
From [Portifolio Project]..CovidDeaths$ dea
Join [Portifolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select*, (TPeopleVacctd/population)*100
From #PercentPopulationVaccinated


--Creating view(use later for data visualization)
CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TPeopleVacctd
--,(TPeopleVacctd/population)*100
From [Portifolio Project]..CovidDeaths$ dea
Join [Portifolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated

----------------------------

-- Creating a view for Global Numbers
--First create a table
DROP Table if exists #GlobalNumbers
Create table #GlobalNumbers
(
Total_Cases nvarchar(255),
Total_Deaths nvarchar(255),
DeathPercentage nvarchar(255)
)

insert into #GlobalNumbers
SELECT SUM(new_cases) as Total_Cases, SUM(cast(total_deaths as int)) as Total_Deaths,SUM(cast(total_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From [Portifolio Project]..CovidDeaths$
where continent is not null
order by 1,2 

Select *
From #GlobalNumbers

--Create A View
CREATE VIEW GlobalNumbersV as
SELECT SUM(new_cases) as Total_Cases, SUM(cast(total_deaths as int)) as Total_Deaths,SUM(cast(total_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From [Portifolio Project]..CovidDeaths$
where continent is not null
--order by 1,2 

Select *
From GlobalNumbersV

---------
-- Creating a view for Countries with the highest Death Count per Population
--First create a table
DROP Table if exists #CHighestDeathCount
Create table #CHighestDeathCount
(
Location nvarchar(255),
TotalDeathCount nvarchar(255)
)

insert into #CHighestDeathCount
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Portifolio Project]..CovidDeaths$
where continent is not null
group by location
--order by TotalDeathCount desc

Select *
From #CHighestDeathCount

--Create A View

CREATE VIEW CHighestDeathCountV as
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Portifolio Project]..CovidDeaths$
where continent is not null
group by location
--order by TotalDeathCount desc

Select *
From CHighestDeathCountV
