Select *
From CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1, 2

-- looking at total cases versus total deaths
-- shows likelihood of dying if you contract Covid in your country

select location, date, total_cases, total_deaths, (try_cast(total_deaths as decimal(12,2)) /(try_cast(total_cases as int)))*100 as DeathPercentage
From CovidDeaths
where location like '%states%'
and continent is not null
Order by 1, 2

--looking at the total cases versus population 

select location, date, total_cases, population, (try_cast(total_cases as decimal(12,2)) /(try_cast(population as int)))*100 as InfectedPercentagePopulation
From CovidDeaths
where location = 'United States'
and continent is not null
Order by 1, 2

--looking at which countries has highest infection rates compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--looking at the countries with the highest death rate per population

Select Location, MAX(cast(total_Deaths as int)) as TotalDeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathRate desc

--let's break things down by continent


--showing the continents with the highest death count per population

Select continent, MAX(cast(total_Deaths as int)) as TotalDeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathRate desc


-- global numbers

select date, total_cases, total_deaths, (try_cast(total_deaths as decimal(12,2)) /(try_cast(total_cases as int)))*100 as DeathPercentage
From CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
Order by 1, 2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


--total population versus vaccinations - what is total amount of ppl in world that have been vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, convert(date,dea.date)) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, convert(date,dea.date)) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

Select *, (RollingPeopleVaccinated/Population)*100 
from PopVsVac


--Temp Table

drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, convert(date,dea.date)) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 as  PercentPopulationVaccinated
from #percentpopulationvaccinated

--Creating View to store data for later visualizations

Create view  percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, convert(date,dea.date)) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--since this is a view now, you can query off this

Select *
from percentpopulationvaccinated



--2nd view created

create view GlobalDeathRate as
Select continent, MAX(cast(total_Deaths as int)) as TotalDeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent

--can use views to connect with tableau