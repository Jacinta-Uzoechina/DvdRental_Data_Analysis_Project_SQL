-- Top Renters
-- Identifying the top 10 customers who have rented the most movies.

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	COUNT(r.rental_id) AS total_rentals
FROM 
    customer AS c
JOIN 
    rental AS r 
    ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, customer_name
ORDER BY 
    total_rentals DESC
LIMIT 
    10;
	
-- Popular Movies
-- Finding the top five most rented movies.

SELECT 
    i.film_id, 
	f.title AS movie_title,
    COUNT (r.rental_id) AS num_of_times_rented
FROM 
    rental AS r
LEFT JOIN 
    inventory AS i
    ON r.inventory_id = i.inventory_id
LEFT JOIN 
    film AS f
    ON i.film_id = f.film_id
GROUP BY 
    i.film_id, movie_title
ORDER BY 
    num_of_times_rented DESC
LIMIT 
    5;  
	

-- Rental Frequency
-- Determining the average number of rentals per customer.

SELECT 
    ROUND (COUNT(rental_id)) / COUNT(DISTINCT customer_id) AS average_num_of_rentals
FROM 
    rental;

-- Movie Genre Preferences
-- Analysing the most popular movie genres among customers.

SELECT 
    c.name AS genre_name
FROM 
    category AS c
LEFT JOIN 
    film_category AS fc
    ON c.category_id = fc.category_id
LEFT JOIN inventory AS i
    ON fc.film_id = i.film_id
LEFT JOIN 
    rental AS r
    ON i.inventory_id = r.inventory_id
GROUP BY 
    genre_name
ORDER BY 
    COUNT(r.rental11_id) DESC;

-- Peak Rental Times
-- Identifying the days and times when the store experiences the highest and lowest rental activity.

SELECT
    EXTRACT(DOW FROM rental_date) AS day_of_week,
    EXTRACT(HOUR FROM rental_date) AS hour_of_day,
    COUNT(*) AS rental_times
FROM
    rental
GROUP BY
    day_of_week,
    hour_of_day
ORDER BY
    rental_times DESC;


-- Late Returns
-- Identifying customers with a history of frequently returning movies late.

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	COUNT(r.customer_id) AS total_rentals,
        SUM(
        CASE 
            WHEN r.return_date - r.rental_date > (f.rental_duration || ' days')::interval THEN 1
            ELSE 0
        END
    ) AS late_returns

FROM 
    customer AS c
INNER JOIN 
    rental AS r 
    ON c.customer_id = r.customer_id
INNER JOIN 
    inventory AS i 
    ON r.inventory_id = i.inventory_id 
INNER JOIN
    film AS f
	ON i.film_id = f.film_id
GROUP BY
    c.customer_id, customer_name
ORDER BY
    late_returns DESC;

-- Customer Loyalty
--Determine the number of customers who have been with the store for over a year and analyse their rental behaviour.	
	
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(r.customer_id) AS total_rentals,
	SUM(p.amount) AS total_revenue,
    AVG(EXTRACT(MONTH FROM r.rental_date)) AS avg_rentals_per_month,
    CASE
        WHEN c.create_date <= c.last_update THEN 'YES'
        ELSE 'NO'
    END AS loyal_customer
FROM
    customer AS c
JOIN
    rental AS r ON c.customer_id = r.customer_id
JOIN
    payment AS p ON r.rental_id = p.rental_id
GROUP BY
    c.customer_id, customer_name, c.create_date, c.last_update
HAVING
    active = 1
ORDER BY
    create_date DESC;