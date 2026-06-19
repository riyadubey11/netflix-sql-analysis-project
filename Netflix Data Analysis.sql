CREATE DATABASE netflix_analysis;
USE netflix_analysis;

CREATE TABLE netflix_titles (
show_id VARCHAR(10),
type VARCHAR(20),
title VARCHAR(255),
director VARCHAR(255),
cast_members TEXT,
country VARCHAR(255),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(20),
duration VARCHAR(50),
listed_in VARCHAR(255),
description TEXT
);

select * from netflix;

/* 1. What percentage of Netflix content is Movies vs TV Shows? */

SELECT
    type,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 /
    (SELECT COUNT(*) FROM netflix),2)
    AS percentage
FROM netflix
GROUP BY type;

/* 2. Categorize content by release period */

SELECT
CASE
WHEN release_year <2000 THEN 'Before 2000'
WHEN release_year BETWEEN 2000 AND 2010 THEN '2000-2010'
WHEN release_year BETWEEN 2011 AND 2020 THEN '2011-2020'
ELSE '2021 onwards'
END AS era,
COUNT(*) AS total
FROM netflix
GROUP BY era
ORDER BY total DESC;

/* 3. Find countries with more than 100 titles */

SELECT country,
COUNT(*) AS total
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
HAVING COUNT(*) >100
ORDER BY total DESC;

/* 4. Which year had the biggest growth compared to the previous year? */

WITH yearly_content AS (
SELECT release_year,
COUNT(*) AS total_content
FROM netflix
GROUP BY release_year
)

SELECT release_year, total_content, total_content - LAG(total_content)
 OVER(ORDER BY release_year)
AS growth
FROM yearly_content
ORDER BY growth DESC;

/* 5. Which years had below-average content production? */

WITH yearly_content AS (
SELECT release_year,
COUNT(*) AS total
FROM netflix
GROUP BY release_year
)
SELECT *
FROM yearly_content
WHERE total <
(
SELECT AVG(total)
FROM yearly_content
);

/* 6. Which countries contribute more than the average country contribution? */

WITH country_count AS (
SELECT country,
COUNT(*) AS total
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
)
SELECT *
FROM country_count
WHERE total >
(
SELECT AVG(total)
FROM country_count
)
ORDER BY total DESC;

/* 7.Find content older than 30 years. */

SELECT title, release_year
FROM netflix
WHERE YEAR(CURDATE()) - release_year >30
ORDER BY release_year;

/* 8.Rank every title within its type */

SELECT title, type, release_year,
ROW_NUMBER() OVER(PARTITION BY type ORDER BY release_year DESC) AS ranking
FROM netflix;

/* 9.Find the top 3 countries every year. */

WITH country_year AS (SELECT release_year, country,
COUNT(*) AS total,
DENSE_RANK()
OVER(PARTITION BY release_year ORDER BY COUNT(*) DESC)AS ranking
FROM netflix
WHERE country IS NOT NULL
GROUP BY release_year,country
)
SELECT *
FROM country_year
WHERE ranking<=3;

/* 10.Which countries rely mostly on Movies instead of TV Shows? */

SELECT country,
SUM(CASE WHEN type='Movie' THEN 1 ELSE 0 END) AS movies,
SUM(CASE
WHEN type='TV Show' THEN 1 ELSE 0 END) AS tvshows
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY movies DESC;