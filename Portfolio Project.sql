/* Covid 19 Data Exploration

SKills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



-- Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying from Covid based on country

Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal(12,2)) / CAST(total_cases AS decimal(12,2)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, total_cases, population, (CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2


-- Countries with Highest Infection Rate Compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((CAST(total_cases AS decimal(12,2)) / CAST(population AS decimal(12,2))))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, Max(CAST(total_deaths AS decimal(12,2))) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population

Select continent, Max(CAST(total_deaths AS decimal(12,2))) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to Perform Calculation on Partition By in Previous Query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPerPopulationPercentage
From PopvsVac


-- Using Temp Table to Perform Calcuation on Partition By in Previous Query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPerPopulationPercentage
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PercentPopulationVaccinated