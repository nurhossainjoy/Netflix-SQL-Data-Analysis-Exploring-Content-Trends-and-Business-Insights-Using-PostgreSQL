/*
===============================================================================
                         NETFLIX DATA ANALYSIS USING SQL
===============================================================================

Project Name : Netflix Data Analysis
Database     : PostgreSQL
Dataset      : Netflix Movies & TV Shows
Author       : MD Nur Hossain Joy

Description:
This project demonstrates SQL querying skills by solving 15 real-world business
questions using PostgreSQL. The analysis includes content distribution,
genre analysis, ratings, directors, actors, release trends, and content
classification.

Concepts Used:
• SELECT
• WHERE
• GROUP BY
• ORDER BY
• Aggregate Functions
• CASE WHEN
• Common Table Expressions (CTE)
• Window Functions
• String Functions
• Date Functions
• Regular Expressions
===============================================================================
*/


/*=============================================================================
QUESTION 1: Count the Number of Movies vs TV Shows
=============================================================================*/
SELECT
	type,
	COUNT (type)AS number_of_movies_vs_tv_shows
FROM netflix.netflix_titles
GROUP BY type
/*=============================================================================
QUESTION 2: Find the Most Common Rating for Movies and TV Shows 
=============================================================================*/
SELECT * FROM (
SELECT
	RANK() OVER (PARTITION BY type ORDER BY COUNT (rating) DESC),
	type,
	rating,
	COUNT (rating) AS no_of_ratings
FROM netflix.netflix_titles
GROUP BY type, rating
ORDER BY type, no_of_ratings DESC )
WHERE "rank" = 1
/*=============================================================================
QUESTION 3: List All Movies Released in a Specific Year (e.g., 2020)
=============================================================================*/
SELECT *
FROM netflix.netflix_titles
WHERE release_year=2020;
/*=============================================================================
QUESTION 4: Find the Top 5 Countries with the Most Content on Netflix
=============================================================================*/
SELECT 
	* 
FROM (
		SELECT
		RANK() OVER (ORDER BY COUNT (title) DESC),
		country,
		COUNT (title) AS no_of_content
	FROM netflix.netflix_titles
	GROUP BY country)
WHERE country IS NOT NULL AND rank<=5
/*=============================================================================
QUESTION 5: Identify the Longest Movie
=============================================================================*/
SELECT
	title,
	type,
	duration AS long_duration_in_min
FROM netflix.netflix_titles
WHERE type ='Movie' AND duration IS NOT NULL
	ORDER BY long_duration_in_min DESC
/*==============================================================================
QUESTION 6: Find Content Added in the Last 5 Years
==============================================================================*/
SELECT
	show_id,
	type,
	title,
	director,
	"cast",
	country,
	date_added :: date,
	listed_in
FROM netflix.netflix_titles
	WHERE date_added::date >= CURRENT_DATE - INTERVAL '5 years'
/*==============================================================================
QUESTION 7: Find All Movies/TV Shows by Director 'Rajiv Chilaka'
=============================================================================*/
SELECT *
FROM netflix.netflix_titles
WHERE director ='Rajiv Chilaka'
/*==============================================================================
QUESTION 8: List All TV Shows with More Than 5 Seasons
=============================================================================*/
WITH no_of_season AS 
(
SELECT
	*,
	SPLIT_PART (duration, ' ',1):: numeric AS number_of_season
FROM netflix.netflix_titles
	WHERE "type"= 'TV Show'
)
SELECT
show_id,
type,
	title,
	country,
	duration,
	Date_added,
	release_year,
	rating,
	listed_in
FROM no_of_season
	WHERE number_of_season>=5
	ORDER BY release_year DESC;
/*==============================================================================
QUESTION 9: Count the Number of Content Items in Each Genre
=============================================================================*/
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix.netflix_titles
GROUP BY 1
ORDER BY 2 DESC;
/*==============================================================================
QUESTION 10: Find each year and the average numbers of content release in India 
on netflix. Return top 5 with highest average release
==============================================================================*/
WITH count_table AS
(
SELECT
COUNT (*)::numeric AS number_of_Contents,
EXTRACT (YEAR FROM date_added :: date) AS release_year
FROM netflix.netflix_titles
WHERE country ILIKE '%india%'
GROUP BY EXTRACT (YEAR FROM date_added :: date)
ORDER BY release_year DESC
)
SELECT *,
ROUND ((number_of_Contents/ SUM (number_of_Contents) OVER ())*100,2) AS 
avg_percentage_of_content
FROM count_table;
/*==============================================================================
QUESTION 11: List All Movies that are Documentaries
==============================================================================*/
SELECT * 
FROM netflix.netflix_titles
WHERE listed_in LIKE '%Documentaries';
/*==============================================================================
QUESTION 12: Find All Content Without a Director
==============================================================================*/
SELECT * 
FROM netflix.netflix_titles
WHERE director IS NULL;
/*==============================================================================
QUESTION 13: Find the Movies in which Actor 'Salman Khan' Appeared in the 
Last 10 Years
=============================================================================+*/
SELECT *
FROM netflix.netflix_titles
WHERE "cast" ILIKE '%Salman Khan%'
AND "release_year" >= EXTRACT (YEAR FROM CURRENT_DATE)-10;
/*==============================================================================
QUESTION 14: Find the Top 10 Actors Who Have Appeared in the Highest Number of 
Movies Produced in India
=============================================================================*/
SELECT
UNNEST (STRING_TO_ARRAY("cast",',')) AS actors,
COUNT (*)AS Total_content
FROM netflix.netflix_titles
WHERE "country" ILIKE '%india%'
GROUP BY actors
ORDER BY Total_content DESC
LIMIT 10;
/*==============================================================================
QUESTION 15: Categorize Content Based on the Presence of 'Kill' and 'Violence' 
Keywords in the descrition field and. Lebel Contents containing this keyword as 
'Bad' and  all other contents as good. Count how many contents felkl into each 
category 
=============================================================================*/
SELECT
    CASE
        WHEN description ~* '\m(kill|violence)\M'
        THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS total_contents
FROM netflix.netflix_titles
GROUP BY content_category

/*===============================================================================
			                       END OF PROJECT
===============================================================================*/









