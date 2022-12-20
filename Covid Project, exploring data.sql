select * from CovidDeaths cd 
WHERE continent <> ""
order by 3,4;

--select * from CovidVaccinations cv  
--order by 3,4;
 
select location, date, population, total_cases, total_deaths, ((total_deaths/total_cases)*100) as deathpercentage
from CovidDeaths cd
--WHERE location = "United States"
order by 1, 2


select * 
--Looking at country with highest infection rate comapred to population
 select location, population, max(total_cases) as HighestInfectionCount, total_deaths, MAX((total_cases/population))*100 as PercentofPopulationInfected
from CovidDeaths cd
--WHERE location = "United States"
group by location , population 
order by PercentofPopulationInfected desc


 --Showing countries with highest death count per population
select location, MAX(CAST (total_deaths as int)) as TotalDeathCount 
from CovidDeaths cd
WHERE continent <> ""
group by location  
order by Totaldeathcount DESC  

--Break things down to continent
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
from CovidDeaths cd
WHERE continent = ""
group by location  
order by Totaldeathcount DESC  

SELECT DISTINCT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount 
from CovidDeaths cd
WHERE continent <> ""
group by continent  
order by Totaldeathcount DESC 

-- Join the two tables
-- total at total population vs vaccinations
-- Use a rolling function
SELECT cv.continent , cd.location , cd.date , cd.population , cv.new_vaccinations 
, SUM(CAST (cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER by cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON cd.location = cv.location 
	and cd.date = cv.date 
where cd .continent  <> ""
order by 2, 3

-- USE CTE 

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT cv.continent , cd.location , cd.date , cd.population , cv.new_vaccinations 
, SUM(CAST (cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER by cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON cd.location = cv.location 
	and cd.date = cv.date 
where cd .continent  <> ""
--order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated as
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric,
)


Insert into
SELECT cv.continent , cd.location , cd.date , cd.population , cv.new_vaccinations 
, SUM(CAST (cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER by cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON cd.location = cv.location 
	and cd.date = cv.date 
where cd .continent  <> ""
--order by 2, 3

SELECT *,(RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated


-- Create a View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT cv.continent , cd.location , cd.date , cd.population , cv.new_vaccinations 
, SUM(CAST (cv.new_vaccinations as int)) OVER (PARTITION BY cd.location ORDER by cd.location, cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv 
	ON cd.location = cv.location 
	and cd.date = cv.date 
where cd .continent  <> ""
--order by 2, 3

