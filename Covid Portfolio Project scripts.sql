
--Looking at Total_cases Vs Total_deaths (Saudi Arabia)

SELECT location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18, 2), total_deaths)/CONVERT(DECIMAL(18, 2), total_cases))*100 as Death_Precentage
FROM ProtefolioProject..CovidDeaths
where location like '%Saudi%'
order by 1,2


-- Looking at Total_cases VS Population  (Saudi Arabia)
-- Showes what precentage of Population got Covid
SELECT location, date, population , total_cases,  (CONVERT(DECIMAL(18, 2), total_cases)/CONVERT(DECIMAL(18, 2), population))*100 as Precent_Population_Infected
FROM ProtefolioProject..CovidDeaths
where location like '%Saudi%'
order by 1,2
--- Looking at Countries with Hieghst infection Rate Compared to population
SELECT location, population , Max(cast(total_cases as int)) as HighestInfectionCount,  Max(CONVERT(DECIMAL(18, 2), total_cases)/CONVERT(DECIMAL(18, 2), population))*100 as Precent_Population_Infected
FROM ProtefolioProject..CovidDeaths
Where continent is not null
Group by location,population
order by Precent_Population_Infected Desc

--- Showing Countries with Hightes Death count per population
SELECT location, Max(cast(total_Deaths as int)) as Precent_Of_Deaths
FROM ProtefolioProject..CovidDeaths
Where continent is not null
Group By location
order by Precent_Of_Deaths Desc

--- LETS BREAK THINGS DOWN BY CONTINENT 
SELECT continent, Max(cast(Total_deaths as int)) as Precent_Of_Deaths
 FROM ProtefolioProject..CovidDeaths
 where continent is not null 
 group by continent
 order by Precent_Of_Deaths Desc

 --- Global Numbers----  -- Total new cases & new Deaths by each day
 SELECT date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths,sum(new_deaths)/NULLIF(sum(new_cases),0)*100 as Present_Of_Deaths
 FROM ProtefolioProject..CovidDeaths
 where continent is not null
 Group by date
 order by 1,2

  SELECT sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths,sum(new_deaths)/NULLIF(sum(new_cases),0)*100 as Present_Of_Deaths
 FROM ProtefolioProject..CovidDeaths
 where continent is not null
 --Group by date
 order by 1,2


 Select *
 FROM ProtefolioProject..CovidDeaths DEA
 join
 ProtefolioProject..CovidVaccinations VAC
 on DEA.continent=VAC.continent
 AND DEA.location=VAC.location

 --Looking At total Population VS Vaccinations at Saudi Arabia

  Select DEA.continent,DEA.location,DEA.date, DEA.population,VAC.new_vaccinations
  , SUM (CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.location,
  DEA.date) as RollingPeopleVaccinated
 FROM ProtefolioProject..CovidDeaths DEA
 join
 ProtefolioProject..CovidVaccinations VAC
 on DEA.location=VAC.location
 AND DEA.date=VAC.date
 where DEA.continent is not null And DEA.location like '%Saudi%'
 order by 2,3


 -------------------------------------

 ----WITH CTE---------- 
 
 --Find out the Present Of People Vaccinated per Population

 with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated) as

  ( Select DEA.continent,DEA.location,DEA.date, DEA.population,VAC.new_vaccinations
  , SUM (CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.location,
  DEA.date) as RollingPeopleVaccinated
 FROM ProtefolioProject..CovidDeaths DEA
 join
 ProtefolioProject..CovidVaccinations VAC
 on DEA.location=VAC.location
 AND DEA.date=VAC.date
 where DEA.continent is not null And DEA.location like '%Saudi%'
 --order by 2,3
 )

 SELECT *,(RollingPeopleVaccinated/population)*100
 FROM PopvsVac


 ----- with Temp Table---------

 DROP TABLE if exists #PresentPopulationVccinated   --- This help when want to alter the Temp Table.

 CREATE TABLE #PresentPopulationVccinated(
 continent varchar(255),
 location varchar(255),
 date date,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric


 )

 ---------------------------------------------------

 INSERT INTO #PresentPopulationVccinated 
   Select DEA.continent,DEA.location,DEA.date, DEA.population,VAC.new_vaccinations
  , SUM (CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.location,
  DEA.date) as RollingPeopleVaccinated
 FROM ProtefolioProject..CovidDeaths DEA
 join
 ProtefolioProject..CovidVaccinations VAC
 on DEA.location=VAC.location
 AND DEA.date=VAC.date
 where DEA.continent is not null And DEA.location like '%Saudi%'
 --order by 2,3
 

 SELECT *,(RollingPeopleVaccinated/population)*100
 FROM #PresentPopulationVccinated 


 ----- Createing  view to store data for later visualization 

 create  View PresentPopulationVccinated as
 Select DEA.continent,DEA.location,DEA.date, DEA.population,VAC.new_vaccinations
  , SUM (CONVERT(bigint,VAC.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.location,
  DEA.date) as RollingPeopleVaccinated
 FROM ProtefolioProject..CovidDeaths DEA
 join
 ProtefolioProject..CovidVaccinations VAC
 on DEA.location=VAC.location
 AND DEA.date=VAC.date
 where DEA.continent is not null And DEA.location like '%Saudi%'
 --order by 2,3


 

