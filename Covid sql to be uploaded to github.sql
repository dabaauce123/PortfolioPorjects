Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


Select *
From PortfolioProject..CovidVaccinations$
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, total_deaths,Population,(Total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


-- Looking at Counties with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, population
order by PercentagePopulationInfected
desc


-- BREAKDOWN by Continent (Death Rate)

select location , MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is null
Group by location
order by TotalDeathCount desc

select continent , MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

select continent , MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/ SUM(new_cases)*100 as DeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage--
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location,dea.date) as
RollingPeopleVaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

---- Using CTE 

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as -- number of columns must be same as below
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location,dea.date) as
RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null 
AND dea.location = 'Albania'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac

-- Using Temp Table

Drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location,dea.date) as
RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null 
Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

-- Looking at Countries with the Highest Death Rate compared to Population

Select location, Population, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location, population
order by TotalDeathCount
desc


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, population
order by PercentagePopulationInfected
desc

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location,dea.date) as
RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated