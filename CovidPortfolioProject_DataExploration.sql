SELECT *  FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
Order by 3,4
SELECT *  FROM [SQLPortfolioProject1].[dbo].[CovidVaccinations$]
Order by 3,4

 /* Selecting Data that we gonna use */
SELECT location, date,total_cases, new_cases, total_deaths, population 
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
order by 1,2

-- Total cases vs Total Deaths (Shows the likelyhood of dying if you contact Covid in your country)
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
Where location = 'India'
order by 1,2

--Looking at the total cases vs population (Shows what percentage of population got Covid in your country)
SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
Where location = 'India'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, Max(total_cases) as HighestInfection, Max((total_cases/population))*100 as PercentageOfPopulationInfected
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
--Where location = 'India'
Group by location, population
order by PercentageOfPopulationInfected desc

--Showing countries with Highest death count per population
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
Where Continent is not NULL
Group by location
order by TotalDeathCount desc

SELECT *  FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
Order by 3,4

--Let's Break things by Continent
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
Where Continent is not NULL
Group by continent
order by TotalDeathCount desc

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
Where Continent is NULL
Group by location
order by TotalDeathCount desc

--Showing continents with Highest death count per population
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
Where Continent is not NULL
Group by continent
order by TotalDeathCount desc

SELECT Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathCountPercentage
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$]
Where Continent is not NULL
--Group by continent
order by 1,2

-- Looking at total population vs total vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$] dea Join [SQLPortfolioProject1].[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$] dea Join [SQLPortfolioProject1].[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$] dea Join [SQLPortfolioProject1].[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
)
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to save it later for data visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM [SQLPortfolioProject1].[dbo].[CovidDeaths$] dea Join [SQLPortfolioProject1].[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select * From PercentPopulationVaccinated