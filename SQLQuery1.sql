-- Exploring Data
SELECT *
From [Covid_Deaths]
Where continent is not NULL
order by 2, 3


-- Looking at Total Cases vs Total Deaths 
SELECT Location, date, total_cases, new_cases, total_deaths, (Total_deaths/total_cases)*100 as Mortality_rate 
From [Covid_Deaths]
Where location like '%Russia%'
order by 1,2

-- Looling at total Cases vs Population
-- SHows what % contracted Covid in the country
SELECT Location, date, population, total_cases,  total_deaths, (Total_cases/population)*100 as Contracted_rate 
From [Covid_Deaths]
Where location like '%Emirates%'
order by 1,2

-- Looking at Countriws with Higes Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((Total_cases/population)*100) as Percent_Of_Population_Contracted
From [Covid_Deaths]
--Where location like '%Emirates%'
Group by Location, Population
order by Percent_Of_Population_Contracted desc

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_deaths as bigint)) as Total_Death_Count
From [Covid_Deaths]
Where continent is not NULL
Group by Location
order by Total_Death_Count desc


-- Breaking things down by continent
SELECT continent, MAX(cast(Total_deaths as bigint)) as Total_Death_Count
From [Covid_Deaths]
Where continent is not NULL
Group by continent
order by Total_Death_Count desc
-- in this case for some reason numbers are wrong, it shows only the country with top deaths

-- Breaking things down by continent 2
SELECT location, MAX(cast(Total_deaths as bigint)) as Total_Death_Count
From [Covid_Deaths]
Where continent is NULL and location NOT LIKE '%income%' and location NOT LIKE '%World%' and location NOT LIKE '%international%'
Group by location
order by Total_Death_Count desc



-- Global numbers 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as Mortality_Rate
From [Covid_Deaths]
where continent is not null
--group by date
order by 1,2




-- 1st recorded vaccination 

-- nation with highest vacination rate today



-- USE CTE

-- Looking at Total Population vs Vaccinations 
With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated) --if the number of columns in CTE is different as in as, it will give an error
as 
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
	  --, 
	from covid_deaths dea
	join Covid_Vaccinations vac
	  on dea.location = vac.location
	  and dea.date = vac.date
	where dea.continent is not NULL
	--order by 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100 as Country_vaccination_percentage
From PopvsVac


--TEMP Table

DROP Table if exists #Percent_Population_Vaccinated

Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, --be careful of the capital letters New_vaccinations won't work
Rolling_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated

	from covid_deaths dea
	join Covid_Vaccinations vac
	  on dea.location = vac.location
	  and dea.date = vac.date

	where dea.continent is not NULL

Select *, (Rolling_People_Vaccinated/population)*100 as Percent_of_population_vaccinated
From #Percent_Population_Vaccinated


-- Creating View to store date for later visualizations

Create View Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated

	from covid_deaths dea
	join Covid_Vaccinations vac
	  on dea.location = vac.location
	  and dea.date = vac.date

	where dea.continent is not NULL