drop table if exists netflx;
create table netlix(
show_id	varchar(5),
type	varchar(10),
title   varchar(250),
director varchar(550),
casts      varchar(1050),
country    varchar(550),
date_added  varchar(55),
release_year int,
rating   varchar(15),
duration  varchar(15),
listed_in  varchar(250),
description  varchar(550)

);
select * from netlix;
show columns from netlix;

-- business problems 
-- 1. Count the number of Movies vs TV Shows
select type,
count(*)
from netlix
group by 1
-- 2. Find the most common rating for movies and TV shows
select type , rating
from
(select 
type,
rating,
count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netlix
group by 1,2) as t1
where ranking=1;
-- 3. List all movies released in a specific year (e.g., 2020)
select * from netlix where type='Movie' and release_year='2020'

-- 4. Find the top 5 countries with the most content on Netflix
select
unnest(string_to_array(country,',')) as new_country,
count(show_id) as total_content
from netlix
group by 1
order by 2 desc
limit 5
-- 5. Identify the longest movie
select * from 
netlix where type='Movie' and duration=(select max(duration) from netlix) 
-- 6. Find content added in the last 5 years
select * from 
netlix where to_date(date_added,'month dd, yyyy') >= current_date- interval '5 years'
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netlix 
where director like '%Rajiv Chilaka%'


-- 8. List all TV shows with more than 5 seasons
select * from netlix where type='TV Show' and split_part(duration,' ',1)::numeric >5


-- 9. Count the number of content items in each genre
select unnest(string_to_array(listed_in,',')) as genres,
count(show_id) as content_items
from netlix 
group by 1

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

select
extract(year from to_date(date_added,'month dd, yyyy')) as year,
count(*),
round(count(*)::numeric/(select count(*) from netlix where country ='India')::numeric,2) as avg_count
from netlix where country='India'
group by 1
order by 3 desc
limit 5

-- 11. List all movies that are documentaries
select * from netlix where listed_in ilike '%documentaries%'

-- 12. Find all content without a director
select * from  netlix where director is null;
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netlix where
casts ilike '%Salman Khan%' 
and release_year > extract(year from current_date) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 

unnest(string_to_array(casts,',')) as actors,
count(*)
from netlix where country ilike '%India'
group by 1
order by 2 desc
limit 10

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2

