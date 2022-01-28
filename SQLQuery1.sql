/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [PortfolioProject].[dbo].[CovidDeaths]

  --Countries with highest infection rates --
  SELECT LOCATION, POPULATION, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercenttagePopulationInfected
	FROM PortfolioProject..CovidDeaths
	GROUP BY location, population
	order by PercenttagePopulationInfected desc

	--Countries with highest death per population--
	SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
	From PortfolioProject..CovidDeaths
	where continent is not null
	Group by location, population
	order by TotalDeathCount desc

		--Continent with highest death per population--
		SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
			From PortfolioProject..CovidDeaths
			where continent is not null
			Group by continent
			order by TotalDeathCount desc

--Total Death per month--
Select month(date) as monthdate, sum(cast(total_deaths as int)) as totaldeath 
from  PortfolioProject..CovidDeaths
group by month(date)
order by month(date) asc

--Join tables of covid vaccionations and deaths
SELECT*
from  PortfolioProject..CovidDeaths as dea
JOIN  PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 