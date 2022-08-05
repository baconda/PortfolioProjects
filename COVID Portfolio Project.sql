
-- Query covid-deaths
Select *
From PortfolioProject..['covid-deaths$']
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..['covid-vaccinations$']
--order by 3,4

-- Select Data that we are going to use
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['covid-deaths$']
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying from Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
Where location like '%states%'
order by 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
Where location like '%states%'
order by 1,2

-- Looking at countries with hightst infectino rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
Group by location
order by TotalDeathCount desc

-- Showing continets with highest deathcount
Select continent, MAX(cast(total_deaths as int)) as TotalDEATHcount
From PortfolioProject..['covid-deaths$']
Where continent is not null
Group by continent
order by TotalDEATHcount desc

-- GLOBAL NUMBERS accross the world
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentDeaths
From PortfolioProject..['covid-deaths$']
where continent is not null
Group by date
order by 1,2

-- GLOBAL NUMBERS total world
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentDeaths
From PortfolioProject..['covid-deaths$']
where continent is not null
order by 1,2

-- Looking at total population vs vaccination
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- CTE (Commmon Table Expression)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVacc
From PopvsVac

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccomatopms numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVacced
From #PercentPopulationVaccinated

-- Creating View to stre data for later visualisations
USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3