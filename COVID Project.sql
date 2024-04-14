Select *
From PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

--Select *
--From PortfolioProject..CovidVaccination
--ORDER BY 3,4
Select location, date, total_case, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2
--Looking at total cases vs total deaths

SELECT location, date, total_case, total_deaths, (CAST(total_deaths AS float) / CAST(total_case AS float)) * 100 AS death_rate_percentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
ORDER BY 1,2

--Looking at countries with highest population rate
SELECT location, population, MAX(total_case) as HighestInfectionCount, MAX(CAST(total_deaths AS float) / CAST(total_case AS float)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
Group By location, population
ORDER BY 1,2

--Showing continent with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group By continent
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths--, (CAST(total_deaths AS float) / CAST(total_case AS float)) * 100 AS death_rate_percentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not null
--Group by date
ORDER BY 1,2

--Looking at total population and vaccination
With PopvsVac (Continent,location, date,population,new_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
      on dea.location = vac.location
	  and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
      on dea.location = vac.location
	  and dea.date = vac.date 
where dea.continent is not null

--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
      on dea.location = vac.location
	  and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
