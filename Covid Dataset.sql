SELECT * 
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Total Cases / Total Deaths

Select location, date, total_cases, total_deaths, ((cast(total_deaths as int)/(cast(total_cases as int))))*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Total Cases / Total Deaths
--percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Highest Infection Rate Compared to Population


Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where continent is not null
group by location,  population
Order by PercentPopulationInfected desc

--Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
group by location
Order by TotalDeathCount desc

--Continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
group by continent
Order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as Total_cases,SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2

--Total Population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--CTI

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date Datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
from PercentPopulationVaccinated