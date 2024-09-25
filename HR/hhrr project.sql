CREATE DATABASE project_HR;

SELECT * FROM hhrr;

## Changing first column name
ALTER TABLE hhrr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hhrr;

## Formating the data columns from text to data
SELECT birthdate FROM hhrr;

SET sql_safe_updates = 0;

UPDATE hhrr
SET birthdate = CASE
	WHEN birthdate LIKE'%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE'%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE null
END;

ALTER TABLE hhrr
MODIFY COLUMN birthdate DATE;

SELECT birthdate FROM hhrr;

DESCRIBE hhrr;

UPDATE hhrr
SET hire_date = CASE
	WHEN hire_date LIKE'%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE'%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE null
END;

ALTER TABLE hhrr
MODIFY COLUMN hire_date DATE;

SELECT termdate FROM hhrr;

UPDATE hhrr
SET termdate = NULL
WHERE termdate = '';

UPDATE hhrr
SET termdate = DATE(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

SELECT termdate FROM hhrr;

ALTER TABLE hhrr
MODIFY COLUMN termdate DATE;

DESCRIBE hhrr;

## Adding AGE column
ALTER TABLE hhrr ADD COLUMN age INT;

UPDATE hhrr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT birthdate, age FROM hhrr;

SELECT 
	MIN(age) AS youngest,
	MAX(age) AS oldest
FROM hhrr;

SELECT COUNT(*)
FROM hhrr 
WHERE age < 18;
## We can exclude from the analysis the 967 persons with less than 18 years, because the database has more than 22.000 rows

SET sql_safe_updates = 1;

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT
	gender,
	count(*) AS count
FROM HHRR
WHERE age >= 18 AND termdate IS NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS count
FROM hhrr
WHERE age >= 18 AND termdate IS NULL
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT 
	MIN(age) AS youngest,
    MAX(age) AS oldest
FROM hhrr
WHERE age >= 18 AND termdate IS NULL;

SELECT 
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
COUNT(*) AS count
FROM hhrr
WHERE termdate IS NULL
GROUP BY age_group
ORDER BY age_group;

# group by age and gender 

SELECT 
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group, gender,
COUNT(*) AS count
FROM hhrr
WHERE termdate IS NULL
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) AS count
FROM hhrr
WHERE age >= 18 AND termdate IS NULL
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
	ROUND(avg(datediff(termdate, hire_date))/365,1) AS avg_years_employment
FROM hhrr
WHERE termdate <= curdate() AND termdate IS NOT NULL AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, COUNT(*) AS count
FROM hhrr
WHERE age >= 18 AND termdate IS NULL
GROUP BY department, gender
ORDER BY department;

SELECT department, jobtitle, gender, COUNT(*) AS count
FROM hhrr
WHERE age >= 18 AND termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle;


-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS count
FROM hhrr
WHERE age >= 18 AND termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8.  Which department has the highest turnover rate?
SELECT department, 
	total_count,
    terminated_count, 
    terminated_count/total_count AS termination_rate
FROM (
	SELECT department,
    COUNT(*) AS total_count,
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hhrr
    WHERE age >= 18
    GROUP BY department
    ) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) AS count
FROM hhrr
WHERE age >=18 AND termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT
	year,
    hires,
    terminations, 
    hires - terminations AS net_change,
    round((hires - terminations)/hires *100, 2) AS net_change_percent
FROM (
	SELECT YEAR(hire_date) AS year,
    COUNT(*) AS hires,
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hhrr
    WHERE age >= 18
    GROUP BY YEAR(hire_date)
    ) AS subquery
ORDER BY YEAR ASC;

-- 11. What is the tenure distribution for each department?
SELECT department, 
	round(avg(datediff(termdate, hire_date)/365),1) AS avg_tenure
FROM hhrr
WHERE termdate <= curdate() AND termdate IS NOT NULL AND age >= 18
GROUP BY department
ORDER BY avg_tenure DESC;





