Select *
From [portfolio project1]..CovidDeaths
Where continent is not null
order by 3,4

Select *
From [portfolio project1]..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from [portfolio project1]..CovidDeaths
order by 1,2

Select location, cast(date as date), total_cases, total_deaths, cast(total_deaths as bigint)/NULLIF(cast(total_cases as float),0)*100 as DeathPercentage
From [portfolio project1]..CovidDeaths
Where cast("location" as varchar) LIKE '%Zealand%'
order by 1,2;

Select location, cast(date as date), total_cases, population, cast(total_cases as bigint)/NULLIF(cast(population as float),0)*100 as CovidCasePercentage
From [portfolio project1]..CovidDeaths
Where cast("location" as varchar) LIKE '%Zealand%'
order by 1,2;

Select location, cast(population as float), Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project1]..CovidDeaths
--Where cast("location" as varchar) LIKE '%Zealand%'
Group by location, population
Order by PercentPopulationInfected desc

Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From [portfolio project1]..CovidDeaths
--Where cast("location" as varchar) LIKE '%Zealand%'
Where continent is not null
Group by location, population
Order by TotalDeathCount desc


--Showing the continents with the highest count per population

Select continent, Max(cast(total_deaths as bigint)) as TotalDeathCount
From [portfolio project1]..CovidDeaths
--Where cast("location" as varchar) LIKE '%Zealand%'
Where continent is not null
Group by Continent
Order by TotalDeathCount desc

--Global numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [portfolio project1]..CovidDeaths
--Where cast("location" as varchar) LIKE '%Zealand%'
Where continent is not null
--Group by date
Order by 1,2



--Total population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From [portfolio project1]..CovidDeaths dea
Join [portfolio project1]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP Table

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From [portfolio project1]..CovidDeaths dea
Join [portfolio project1]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated


--Creating View to store date for later visualization

Create View v_PercentagePopulationVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
From [portfolio project1]..CovidDeaths dea
Join [portfolio project1]..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *
From v_PercentagePopulationVaccinated
