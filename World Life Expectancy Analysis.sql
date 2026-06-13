SELECT * FROM world_life_expectancy;

#DEALING WITH DUPLICATES------------------------------------------------

SELECT Country, Year, COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year
HAVING COUNT(CONCAT(Country, Year)) > 1
;

SELECT *
FROM(
	SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_life_expectancy
    ) AS Duplicate
WHERE Row_Num > 1
;

DELETE FROM world_life_expectancy
WHERE Row_ID IN(1252, 2265, 2929);

#DEALING WITH Status row---------------------------------------

SELECT *
FROM world_life_expectancy 
WHERE Status = '';

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;


#DEALING WITH Life expectancy blanks--------------------------

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
WHERE t1.`Life expectancy` = ''
;

#Exploratory Data Analysis--------------------------

#Life increase
SELECT Country,
MIN(`Life expectancy`) AS min_life_exp,
MAX(`Life expectancy`) AS max_life_exp,
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS life_increase
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Country
ORDER BY life_increase DESC
;

#Average Life Expectancy by Year
SELECT Year,
ROUND(AVG(`Life expectancy`), 1) AS avg_life_expectancy_by_year
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year DESC
;

#Correlation between GDP and Life expectancy
SELECT Country,
ROUND(AVG(`Life expectancy`),1) AS AVG_Life_Expectancy,
ROUND(AVG(GDP),1) AS AVG_GDP
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Country
HAVING AVG_GDP > 0
AND AVG_Life_Expectancy > 0
ORDER BY AVG_GDP DESC
;

SELECT Country,
`Life expectancy`,
GDP,
CASE
	WHEN GDP >= 1000 THEN 'High GDP'
    WHEN GDP >= 300 AND GDP < 1000 THEN 'Okay GDP'
    WHEN GDP < 300 THEN 'Low GDP'
END AS GDP_GROUP
FROM world_life_expectancy
ORDER BY GDP DESC
;

SELECT
	SUM(CASE WHEN GDP >= 1000 THEN 1 ELSE 0 END) High_GDP_COUNT,
    ROUND(AVG(CASE WHEN GDP >= 1000 THEN `Life expectancy` ELSE NULL END),1) High_GDP_Life_Exp,
    SUM(CASE WHEN GDP < 1000 THEN 1 ELSE 0 END) Low_GDP_COUNT,
    ROUND(AVG(CASE WHEN GDP < 1000 THEN `Life expectancy` ELSE NULL END),1) Low_GDP_Life_Exp
FROM world_life_expectancy
;

#Correlation between status and life expectancy
SELECT Status,
ROUND(AVG(`Life expectancy`),1) as avg_life_exp,
COUNT(DISTINCT Country) AS num_of_countries
FROM world_life_expectancy
GROUP BY Status
;


#Correlation between BMI and Life expectancy
SELECT Country,
ROUND(AVG(`Life expectancy`),1) AS avg_life_exp,
ROUND(AVG(BMI),1) AS avg_bmi
FROM world_life_expectancy
GROUP BY Country
HAVING avg_bmi > 0
AND avg_life_exp > 0
ORDER BY avg_bmi DESC
;

#Data Analysis for Adult mortality
SELECT Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Total_Adult_Mortality
FROM world_life_expectancy
;