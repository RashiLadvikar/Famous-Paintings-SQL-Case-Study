select * from artist;
select * from canvas_size;
select * from image_link;
select * from museum;
select * from museum_hours;
select * from product_size;
select * from subject;
select * from work;

1) Paintings not displayed in any museum

SELECT *
FROM work
WHERE museum_id IS NULL;

2) Museums without any paintings

SELECT m.*
FROM museum m
LEFT JOIN work w
ON m.museum_id = w.museum_id
WHERE w.work_id IS NULL;

3) How many paintings have asking price more than regular price

SELECT COUNT(*) AS paintings_count
FROM product_size
WHERE sale_price > regular_price;

4) Asking price less than 50% of regular price

SELECT *
FROM product_size
WHERE sale_price < 0.5 * regular_price;

5) Which canvas size costs the most

SELECT c.label, p.sale_price
FROM product_size p
JOIN canvas_size c
ON p.size_id = c.size_id
ORDER BY p.sale_price DESC
LIMIT 1;

6) Delete duplicate records from work, product_size, subject, image_link

Work

DELETE FROM work
WHERE work_id IN (
    SELECT work_id
    FROM (
        SELECT work_id,
               ROW_NUMBER() OVER (PARTITION BY work_id ORDER BY work_id) AS rn
        FROM work
    ) t
    WHERE rn > 1
);

Product_size

DELETE FROM product_size
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (
                   PARTITION BY work_id, size_id, sale_price, regular_price
                   ORDER BY ctid
               ) AS rn
        FROM product_size
    ) t
    WHERE rn > 1
);

Subject

DELETE FROM subject
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (
                   PARTITION BY work_id, subject
                   ORDER BY ctid
               ) AS rn
        FROM subject
    ) t
    WHERE rn > 1
);

Image_link

DELETE FROM image_link
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (
                   PARTITION BY work_id
                   ORDER BY ctid
               ) AS rn
        FROM image_link
    ) t
    WHERE rn > 1
);

7) Museums with invalid city information

Usually invalid city means numeric or blank values.

SELECT *
FROM museum
WHERE city IS NULL
   OR TRIM(city) = ''
   OR city ~ '^[0-9]+$';
   
8) Invalid entry in museum_hours and remove it

Find invalid row first:

SELECT *
FROM museum_hours
WHERE day NOT IN ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

Delete it:

DELETE FROM museum_hours
WHERE day NOT IN ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday');

9) Top 10 most famous painting subjects

SELECT subject, COUNT(*) AS subject_count
FROM subject
GROUP BY subject
ORDER BY subject_count DESC
LIMIT 10;

10) Museums open on both Sunday and Monday

SELECT m.name, m.city
FROM museum m
JOIN museum_hours mh
ON m.museum_id = mh.museum_id
WHERE mh.day IN ('Sunday', 'Monday')
GROUP BY m.museum_id, m.name, m.city
HAVING COUNT(DISTINCT mh.day) = 2;

11) Museums open every single day

SELECT COUNT(*) AS museums_open_all_days
FROM (
    SELECT museum_id
    FROM museum_hours
    GROUP BY museum_id
    HAVING COUNT(DISTINCT day) = 7
) t;

12) Top 5 most popular museums

SELECT m.name, COUNT(w.work_id) AS painting_count
FROM museum m
JOIN work w
ON m.museum_id = w.museum_id
GROUP BY m.museum_id, m.name
ORDER BY painting_count DESC
LIMIT 5;

13) Top 5 most popular artists

SELECT a.full_name, COUNT(w.work_id) AS painting_count
FROM artist a
JOIN work w
ON a.artist_id = w.artist_id
GROUP BY a.artist_id, a.full_name
ORDER BY painting_count DESC
LIMIT 5;

14) 3 least popular canvas sizes

SELECT c.label, COUNT(*) AS usage_count
FROM product_size p
JOIN canvas_size c
ON p.size_id = c.size_id
GROUP BY c.size_id, c.label
ORDER BY usage_count ASC
LIMIT 3;

15) Museum open for the longest during a day

If open and close are text, cast them to time.

SELECT m.name, m.state, mh.day,
       (mh.close::time - mh.open::time) AS hours_open
FROM museum_hours mh
JOIN museum m
ON mh.museum_id = m.museum_id
ORDER BY hours_open DESC
LIMIT 1;

16) Which museum has the most number of most popular painting style

First find most popular style, then museum with highest count for that style.

WITH most_popular_style AS (
    SELECT style
    FROM work
    WHERE style IS NOT NULL
    GROUP BY style
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
SELECT m.name, w.style, COUNT(*) AS style_count
FROM work w
JOIN museum m
ON w.museum_id = m.museum_id
JOIN most_popular_style s
ON w.style = s.style
GROUP BY m.name, w.style
ORDER BY style_count DESC
LIMIT 1;

17) Artists whose paintings are displayed in multiple countries

SELECT a.full_name, COUNT(DISTINCT m.country) AS country_count
FROM artist a
JOIN work w
ON a.artist_id = w.artist_id
JOIN museum m
ON w.museum_id = m.museum_id
GROUP BY a.artist_id, a.full_name
HAVING COUNT(DISTINCT m.country) > 1
ORDER BY country_count DESC;

18) Country and city with most museums

WITH country_cte AS (
    SELECT country, COUNT(*) AS cnt,
           DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM museum
    GROUP BY country
),
city_cte AS (
    SELECT city, COUNT(*) AS cnt,
           DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM museum
    GROUP BY city
)
SELECT
    (SELECT STRING_AGG(country, ', ') FROM country_cte WHERE rnk = 1) AS top_country,
    (SELECT STRING_AGG(city, ', ') FROM city_cte WHERE rnk = 1) AS top_city;
	
19) Artist and museum where most expensive and least expensive painting is placed

WITH priced_work AS (
    SELECT w.name AS painting_name,
           a.full_name,
           m.name AS museum_name,
           m.city,
           c.label AS canvas_label,
           p.sale_price,
           DENSE_RANK() OVER (ORDER BY p.sale_price DESC) AS high_rnk,
           DENSE_RANK() OVER (ORDER BY p.sale_price ASC) AS low_rnk
    FROM product_size p
    JOIN work w ON p.work_id = w.work_id
    JOIN artist a ON w.artist_id = a.artist_id
    JOIN museum m ON w.museum_id = m.museum_id
    JOIN canvas_size c ON p.size_id = c.size_id
)
SELECT full_name, sale_price, painting_name, museum_name, city, canvas_label
FROM priced_work
WHERE high_rnk = 1 OR low_rnk = 1;

20) Country with 5th highest number of paintings

WITH country_paintings AS (
    SELECT m.country, COUNT(*) AS painting_count,
           DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM work w
    JOIN museum m
    ON w.museum_id = m.museum_id
    GROUP BY m.country
)
SELECT country, painting_count
FROM country_paintings
WHERE rnk = 5;

21) 3 most popular and 3 least popular painting styles

WITH style_counts AS (
    SELECT style, COUNT(*) AS cnt
    FROM work
    WHERE style IS NOT NULL
    GROUP BY style
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY cnt DESC) AS top_rnk,
           DENSE_RANK() OVER (ORDER BY cnt ASC) AS low_rnk
    FROM style_counts
)
SELECT style, cnt, 'Most Popular' AS category
FROM ranked
WHERE top_rnk <= 3

UNION ALL

SELECT style, cnt, 'Least Popular' AS category
FROM ranked
WHERE low_rnk <= 3;

22) Artist with most Portrait paintings outside USA

SELECT a.full_name, a.nationality, COUNT(*) AS no_of_paintings
FROM artist a
JOIN work w
ON a.artist_id = w.artist_id
JOIN subject s
ON w.work_id = s.work_id
JOIN museum m
ON w.museum_id = m.museum_id
WHERE s.subject = 'Portraits'
  AND m.country <> 'USA'
GROUP BY a.artist_id, a.full_name, a.nationality
ORDER BY no_of_paintings DESC
LIMIT 1;