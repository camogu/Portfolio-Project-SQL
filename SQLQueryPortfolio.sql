SELECT*
FROM [Potfolio Project].dbo.Covid_deaths
WHERE continent is not null

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM [Potfolio Project].dbo.Covid_deaths
where continent is not null
order by DeathPercentage desc

-- death toll by countries
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM [Potfolio Project].dbo.Covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- lets break things down by continent (first query is not completely correct. 2nd query is acurate)
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM [Potfolio Project].dbo.Covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM [Potfolio Project].dbo.Covid_deaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--showing conitents with the highest death counts
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM [Potfolio Project].dbo.Covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--global numbers
SELECT date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM [Potfolio Project].dbo.Covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 


--- USE CTE this is to use the created cummulative_vaccnination column in for calclution in one query 
With PopVsVac (continent, location , date, population,new_vacinations, cummulative_vaccination)
as
(
--- looking at total pop vs vac
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) OVER( partition by dea.location ORDER BY dea.location, dea.date) as cummulative_vaccination
FROM [Potfolio Project].dbo.Covid_deaths dea
JOIN [Potfolio Project].dbo.Covid_vacination vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
Select *,(cummulative_vaccination/population)*100
FROM PopVsVac
order by 2,3


--- TEMP TABLE this is to use the created cummulative_vaccnination column in for calclution in one query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Conitient nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
cummulative_vacination numeric,
)

Insert into #PercentPopulationVaccinated
--- looking at total pop vs vac
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) OVER( partition by dea.location ORDER BY dea.location, dea.date) as cummulative_vacination
FROM [Potfolio Project].dbo.Covid_deaths dea
JOIN [Potfolio Project].dbo.Covid_vacination vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3

Select *,(cummulative_vacination/population)*100
FROM #PercentPopulationVaccinated


--- creating view to store data for viz 

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, sum(vac.new_vaccinations) OVER( partition by dea.location ORDER BY dea.location, dea.date) as cummulative_vacination
FROM [Potfolio Project].dbo.Covid_deaths dea
JOIN [Potfolio Project].dbo.Covid_vacination vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3