-- selecting data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM deaths
WHERE continent IS NOT NULL
ORDER BY location, date;


-- Total cases vs. Total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM deaths
WHERE location like 'Germany'
ORDER BY location, date;


-- Total cases vs. Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_population_infected
FROM deaths
WHERE location like 'Germany'
ORDER BY location, date;


-- Countries with the highest infection rate compared to population
SELECT location, date, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;


-- Showing countries with the highest death count per population
SELECT location, MAX(total_deaths) AS total_death_count
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;


-- Per continent highest death count
SELECT continent, MAX(total_deaths) AS total_death_count
FROM deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;


-- Global stats
SELECT date, 
	   SUM(new_cases) AS total_cases, 
       SUM(new_deaths) AS total_deaths, 
       (SUM(new_deaths)/SUM(new_cases))*100 death_percentage
FROM deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY location, date;


-- Total population vs Vaccination
SELECT d.continent, 
	   d.location,
       d.date, 
       d.population, 
       v.new_vaccinations, 
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM deaths d
JOIN vaccination v 
	USING (location, date)
WHERE d.continent IS NOT NULL
ORDER BY continent, location, date;


-- USE CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT d.continent, 
	   d.location,
       d.date, 
       d.population, 
       v.new_vaccinations, 
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM deaths d
JOIN vaccination v 
	USING (location, date)
WHERE d.continent IS NOT NULL
ORDER BY continent, location, date
)

SELECT *, (rolling_people_vaccinated/population)*100 AS percentage_people_vaccinated
FROM pop_vs_vac;


-- Temp table
DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TEMPORARY TABLE percent_population_vaccinated(
continent VARCHAR(255),
location VARCHAR(255),
date DATE,
population DOUBLE,
new_vaccinations DOUBLE,
rolling_people_vaccinated DOUBLE);
INSERT INTO percent_population_vaccinated
SELECT d.continent, 
	   d.location,
       d.date, 
       d.population, 
       v.new_vaccinations, 
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM deaths d
JOIN vaccination v 
	USING (location, date);
-- WHERE d.continent IS NOT NULL
-- ORDER BY continent, location, date;

SELECT *, (rolling_people_vaccinated/population)*100 AS percentage_people_vaccinated
FROM percent_population_vaccinated;


-- Creating view for data visualization
CREATE VIEW percent_population_vaccinated AS 
SELECT d.continent, 
	   d.location,
       d.date, 
       d.population, 
       v.new_vaccinations, 
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_people_vaccinated
FROM deaths d
JOIN vaccination v 
	USING (location, date);
-- WHERE d.continent IS NOT NULL
-- ORDER BY continent, location, date;