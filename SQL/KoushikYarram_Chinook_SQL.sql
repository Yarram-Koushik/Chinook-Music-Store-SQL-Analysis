/* =====================================================================
   CHINOOK MUSIC STORE — STUDENT ANSWER TEMPLATE
   ===================================================================== */

USE chinook;


/* =====================================================================
   OBJECTIVE QUESTIONS
   ===================================================================== */

-- O1
-- Does any table have missing values or duplicates? If yes how would you
-- handle it ?
-- Query 1: Duplicate check
SELECT customer_id, COUNT(*) AS cnt
FROM customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Query 2: Customer NULL profile
SELECT 
    SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS null_company,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN postal_code IS NULL THEN 1 ELSE 0 END) AS null_postal_code,
    SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) AS null_phone,
    SUM(CASE WHEN fax IS NULL THEN 1 ELSE 0 END) AS null_fax
FROM customer;

-- Query 3: Track NULL profile
SELECT 
    SUM(CASE WHEN composer IS NULL THEN 1 ELSE 0 END) AS null_composer,
    SUM(CASE WHEN album_id IS NULL THEN 1 ELSE 0 END) AS null_album_id,
    SUM(CASE WHEN genre_id IS NULL THEN 1 ELSE 0 END) AS null_genre_id
FROM track;

-- O2
-- Find the top-selling tracks and top artist in the USA and identify their
-- most famous genres.
-- Top Tracks
SELECT 
    t.name AS track_name,
    ar.name AS artist_name,
    g.name AS genre_name,
    SUM(il.unit_price * il.quantity) AS revenue,
    SUM(il.quantity) AS units_sold
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY t.track_id, t.name, ar.name, g.name
ORDER BY units_sold DESC, revenue DESC
LIMIT 5;

-- Top Artists

SELECT 
    ar.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS revenue,
    SUM(il.quantity) AS units_sold
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
WHERE i.billing_country = 'USA'
GROUP BY ar.artist_id, ar.name
ORDER BY revenue DESC
LIMIT 5;


-- O3
-- What is the customer demographic breakdown (age, gender, location) of
-- Chinook's customer base?

SELECT 
    country,
    state,
    city,
    COUNT(customer_id) AS customer_count
FROM customer
GROUP BY country, state, city;

SELECT 
    country,
    COUNT(customer_id) AS customer_count
FROM customer
GROUP BY country;


-- O4
-- Calculate the total revenue and number of invoices for each country, state,
-- and city:

SELECT 
    i.billing_country AS country,
    i.billing_state AS state,
    i.billing_city AS city,
    COUNT(DISTINCT i.invoice_id) AS num_invoices,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY i.billing_country, i.billing_state, i.billing_city;


-- O5
-- Find the top 5 customers by total revenue in each country

WITH customer_revenue AS (
    SELECT
        c.country,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(il.quantity * il.unit_price) AS total_revenue,
        DENSE_RANK() OVER(PARTITION BY c.country ORDER BY SUM(il.quantity * il.unit_price) DESC) AS rnk
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY c.country, c.customer_id, c.first_name, c.last_name
)
SELECT country, customer_name, total_revenue, rnk
FROM customer_revenue
WHERE rnk <= 5
ORDER BY country, rnk;


-- O6
-- Identify the top-selling track for each customer

WITH customer_tracks AS (
    SELECT
        c.customer_id,
        t.name AS track_name,
        SUM(il.quantity) AS units,
        ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY SUM(il.quantity) DESC) AS rn
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    GROUP BY c.customer_id, t.track_id, t.name
)
SELECT customer_id, track_name, units
FROM customer_tracks
WHERE rn = 1
ORDER BY customer_id;



-- O7
-- Are there any patterns or trends in customer purchasing behavior (e.g.,
-- frequency of purchases, preferred payment methods, average order value)?

SELECT 
    ROUND(AVG(i.total), 2) AS avg_order_value,
    ROUND(COUNT(DISTINCT i.invoice_id) / COUNT(DISTINCT i.customer_id), 2) AS avg_invoices_per_customer,
    ROUND(COUNT(il.invoice_line_id) / COUNT(DISTINCT i.invoice_id), 2) AS avg_tracks_per_invoice
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id;

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT i.invoice_id) AS num_orders,
    ROUND(AVG(i.total), 2) AS avg_order_value,
    ROUND(SUM(i.total), 2) AS total_spend,
    DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS tenure_days
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY customer_id;



-- O8
-- What is the customer churn rate?

SELECT 
    COUNT(DISTINCT c.customer_id) AS total_customers,
    SUM(CASE 
        WHEN c.customer_id NOT IN (
            SELECT DISTINCT customer_id 
            FROM invoice 
            WHERE invoice_date >= DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH)
        ) THEN 1 ELSE 0 
    END) AS churned_customers,
    ROUND(
        SUM(CASE 
            WHEN c.customer_id NOT IN (
                SELECT DISTINCT customer_id 
                FROM invoice 
                WHERE invoice_date >= DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH)
            ) THEN 1 ELSE 0 
        END) * 100.0 / COUNT(DISTINCT c.customer_id), 2
    ) AS churn_rate_pct
FROM customer c;


-- O9
-- Calculate the percentage of total sales contributed by each genre in the
-- USA and identify the best-selling genres and artists.

SELECT 
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS genre_revenue,
    ROUND(
        SUM(il.unit_price * il.quantity) * 100.0 / 
        (SELECT SUM(il2.unit_price * il2.quantity) 
         FROM invoice i2 
         JOIN invoice_line il2 ON i2.invoice_id = il2.invoice_id 
         WHERE i2.billing_country = 'USA'), 2
    ) AS pct_of_usa_sales
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id, g.name
ORDER BY genre_revenue DESC;


-- O10
-- Find customers who have purchased tracks from at least 3 different genres

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT g.genre_id) AS distinct_genres
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT g.genre_id) >= 3
ORDER BY customer_id;



-- O11
-- Rank genres based on their sales performance in the USA

SELECT 
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue,
    RANK() OVER(ORDER BY SUM(il.unit_price * il.quantity) DESC) AS sales_rank
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id, g.name
ORDER BY sales_rank;



-- O12
-- Identify customers who have not made a purchase in the last 3 months

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    MAX(i.invoice_date) AS last_purchase_date
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
HAVING MAX(i.invoice_date) < DATE_SUB(
    (SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH
)
ORDER BY last_purchase_date;



/* =====================================================================
   SUBJECTIVE QUESTIONS
   ===================================================================== */

-- S1
-- Recommend the three albums from the new record label that should be
-- prioritised for advertising and promotion in the USA based on genre
-- sales analysis.

-- Step 1: Top genres in USA by revenue
SELECT 
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS genre_revenue,
    COUNT(DISTINCT i.invoice_id) AS total_transactions
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id, g.name
ORDER BY genre_revenue DESC
LIMIT 3;

-- Step 2: Top album per top genre in USA
WITH top_genres AS (
    SELECT g.genre_id, g.name AS genre,
           SUM(il.unit_price * il.quantity) AS genre_revenue
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE i.billing_country = 'USA'
    GROUP BY g.genre_id, g.name
    ORDER BY genre_revenue DESC
    LIMIT 3
),
album_sales AS (
    SELECT 
        a.title AS album_name,
        ar.name AS artist_name,
        g.name AS genre,
        ROUND(SUM(il.unit_price * il.quantity), 2) AS album_revenue,
        SUM(il.quantity) AS units_sold,
        ROW_NUMBER() OVER(PARTITION BY g.genre_id ORDER BY SUM(il.unit_price * il.quantity) DESC) AS rn
    FROM top_genres tg
    JOIN genre g ON tg.genre_id = g.genre_id
    JOIN track t ON g.genre_id = t.genre_id
    JOIN album a ON t.album_id = a.album_id
    JOIN artist ar ON a.artist_id = ar.artist_id
    JOIN invoice_line il ON t.track_id = il.track_id
    JOIN invoice i ON il.invoice_id = i.invoice_id AND i.billing_country = 'USA'
    GROUP BY a.album_id, a.title, ar.name, g.genre_id, g.name
)
SELECT album_name, artist_name, genre, album_revenue, units_sold
FROM album_sales
WHERE rn = 1
ORDER BY album_revenue DESC;


-- S2
-- Determine the top-selling genres in countries other than the USA and
-- identify any commonalities or differences.

-- Top 3 genres per country (excluding USA)
WITH country_genre_sales AS (
    SELECT 
        i.billing_country AS country,
        g.name AS genre,
        ROUND(SUM(il.unit_price * il.quantity), 2) AS genre_revenue,
        RANK() OVER(PARTITION BY i.billing_country ORDER BY SUM(il.unit_price * il.quantity) DESC) AS genre_rank
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    WHERE i.billing_country != 'USA'
    GROUP BY i.billing_country, g.genre_id, g.name
)
SELECT country, genre, genre_revenue, genre_rank
FROM country_genre_sales
WHERE genre_rank <= 3
ORDER BY country, genre_rank;

-- Overall top genres outside USA
SELECT 
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue,
    COUNT(DISTINCT i.billing_country) AS num_countries
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country != 'USA'
GROUP BY g.genre_id, g.name
ORDER BY total_revenue DESC;


-- S3
-- Customer Purchasing Behavior Analysis: How do the purchasing habits
-- (frequency, basket size, spending amount) of long-term customers differ
-- from those of new customers? What insights can these patterns provide
-- about customer loyalty and retention strategies?

WITH customer_profile AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        COUNT(DISTINCT i.invoice_id) AS num_orders,
        ROUND(AVG(i.total), 2) AS avg_order_value,
        ROUND(SUM(i.total), 2) AS total_spend,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS tenure_days,
        ROUND(COUNT(DISTINCT il.invoice_line_id) / COUNT(DISTINCT i.invoice_id), 2) AS avg_basket_size,
        MIN(i.invoice_date) AS first_purchase
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT 
    CASE 
        WHEN first_purchase < '2017-07-01' THEN 'Long-term'
        ELSE 'New'
    END AS customer_segment,
    COUNT(*) AS num_customers,
    ROUND(AVG(num_orders), 2) AS avg_frequency,
    ROUND(AVG(avg_basket_size), 2) AS avg_basket_size,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(total_spend), 2) AS avg_total_spend,
    ROUND(AVG(tenure_days), 0) AS avg_tenure_days
FROM customer_profile
GROUP BY 
    CASE 
        WHEN first_purchase < '2017-07-01' THEN 'Long-term'
        ELSE 'New'
    END;


-- S4
-- Product Affinity Analysis: Which music genres, artists, or albums are
-- frequently purchased together by customers? How can this information
-- guide product recommendations and cross-selling initiatives?

-- SQL Query 1 — Genre pairs purchased together (same invoice):
SELECT 
    g1.name AS genre_1,
    g2.name AS genre_2,
    COUNT(DISTINCT il1.invoice_id) AS times_bought_together
FROM invoice_line il1
JOIN invoice_line il2 ON il1.invoice_id = il2.invoice_id 
    AND il1.invoice_line_id < il2.invoice_line_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN genre g1 ON t1.genre_id = g1.genre_id
JOIN genre g2 ON t2.genre_id = g2.genre_id
WHERE g1.genre_id < g2.genre_id
GROUP BY g1.genre_id, g1.name, g2.genre_id, g2.name
ORDER BY times_bought_together DESC
LIMIT 10;

-- SQL Query 2 — Artist pairs purchased together (same invoice):
SELECT 
    ar1.name AS artist_1,
    ar2.name AS artist_2,
    COUNT(DISTINCT il1.invoice_id) AS times_bought_together
FROM invoice_line il1
JOIN invoice_line il2 ON il1.invoice_id = il2.invoice_id 
    AND il1.invoice_line_id < il2.invoice_line_id
JOIN track t1 ON il1.track_id = t1.track_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN album a1 ON t1.album_id = a1.album_id
JOIN album a2 ON t2.album_id = a2.album_id
JOIN artist ar1 ON a1.artist_id = ar1.artist_id
JOIN artist ar2 ON a2.artist_id = ar2.artist_id
WHERE ar1.artist_id < ar2.artist_id
GROUP BY ar1.artist_id, ar1.name, ar2.artist_id, ar2.name
ORDER BY times_bought_together DESC
LIMIT 10;



-- S5
-- Regional Market Analysis: Do customer purchasing behaviors and churn rates
-- vary across different geographic regions or store locations? How might
-- these correlate with local demographic or economic factors?

-- SQL Query 1 — Regional behavior + churn rate by country:
WITH customer_stats AS (
    SELECT 
        c.customer_id,
        c.country,
        COUNT(DISTINCT i.invoice_id) AS num_orders,
        ROUND(AVG(i.total), 2) AS avg_order_value,
        ROUND(SUM(i.total), 2) AS total_spend,
        MAX(i.invoice_date) AS last_purchase
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
)
SELECT 
    cs.country,
    COUNT(*) AS num_customers,
    ROUND(AVG(cs.num_orders), 2) AS avg_orders_per_customer,
    ROUND(AVG(cs.avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(cs.total_spend), 2) AS avg_total_spend,
    SUM(CASE WHEN cs.last_purchase < DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH) THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(SUM(CASE WHEN cs.last_purchase < DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH) THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customer_stats cs
GROUP BY cs.country
ORDER BY num_customers DESC, avg_total_spend DESC;

-- SQL Query 2 — Revenue vs churn for countries with 2+ customers:
WITH customer_stats AS (
    SELECT 
        c.customer_id,
        c.country,
        SUM(i.total) AS total_spend,
        MAX(i.invoice_date) AS last_purchase
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
)
SELECT 
    cs.country,
    COUNT(*) AS num_customers,
    ROUND(SUM(cs.total_spend), 2) AS total_revenue,
    ROUND(AVG(cs.total_spend), 2) AS avg_spend_per_customer,
    SUM(CASE WHEN cs.last_purchase < DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH) THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN cs.last_purchase < DATE_SUB((SELECT MAX(invoice_date) FROM invoice), INTERVAL 3 MONTH) THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customer_stats cs
GROUP BY cs.country
HAVING COUNT(*) >= 2
ORDER BY total_revenue DESC;


-- S6
-- Customer Risk Profiling: Based on customer profiles (age, gender, location,
-- purchase history), which customer segments are more likely to churn or
-- pose a higher risk of reduced spending? What factors contribute to this
-- risk?

-- SQL Query 1 — Individual customer risk classification:
WITH customer_profile AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country,
        COUNT(DISTINCT i.invoice_id) AS num_orders,
        ROUND(AVG(i.total), 2) AS avg_order_value,
        ROUND(SUM(i.total), 2) AS total_spend,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS tenure_days,
        DATEDIFF((SELECT MAX(invoice_date) FROM invoice), MAX(i.invoice_date)) AS days_since_last_purchase
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT 
    customer_id, customer_name, country, num_orders,
    avg_order_value, total_spend, tenure_days, days_since_last_purchase,
    CASE 
        WHEN days_since_last_purchase > 365 THEN 'High Risk'
        WHEN days_since_last_purchase > 180 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level
FROM customer_profile
ORDER BY days_since_last_purchase DESC;

-- SQL Query 2 — Risk segment summary:
WITH customer_profile AS (
    SELECT 
        c.customer_id,
        c.country,
        COUNT(DISTINCT i.invoice_id) AS num_orders,
        ROUND(AVG(i.total), 2) AS avg_order_value,
        ROUND(SUM(i.total), 2) AS total_spend,
        DATEDIFF((SELECT MAX(invoice_date) FROM invoice), MAX(i.invoice_date)) AS days_since_last_purchase
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.country
),
risk_classified AS (
    SELECT *,
        CASE 
            WHEN days_since_last_purchase > 365 THEN 'High Risk'
            WHEN days_since_last_purchase > 180 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM customer_profile
)
SELECT 
    risk_level,
    COUNT(*) AS num_customers,
    ROUND(AVG(num_orders), 2) AS avg_orders,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(total_spend), 2) AS avg_total_spend,
    ROUND(AVG(days_since_last_purchase), 0) AS avg_days_inactive
FROM risk_classified
GROUP BY risk_level
ORDER BY avg_days_inactive DESC;


-- S7
-- Customer Lifetime Value Modeling: How can you leverage customer data
-- (tenure, purchase history, engagement) to predict the lifetime value of
-- different customer segments? This could inform targeted marketing and
-- loyalty program strategies. Can you observe any common characteristics
-- or purchase patterns among customers who have stopped purchasing?

-- SQL Query 1 — CLV per customer with segment:
WITH customer_clv AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country,
        COUNT(DISTINCT i.invoice_id) AS total_orders,
        ROUND(AVG(i.total), 2) AS avg_order_value,
        ROUND(SUM(i.total), 2) AS lifetime_value,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS tenure_days,
        ROUND(COUNT(DISTINCT i.invoice_id) * 365.0 / 
            NULLIF(DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)), 0), 2) AS purchase_frequency_per_year,
        DATEDIFF((SELECT MAX(invoice_date) FROM invoice), MAX(i.invoice_date)) AS days_since_last_purchase
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT 
    customer_id, customer_name, country, total_orders, avg_order_value,
    lifetime_value, tenure_days, purchase_frequency_per_year, days_since_last_purchase,
    CASE 
        WHEN lifetime_value >= 100 THEN 'High Value'
        WHEN lifetime_value >= 70 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS clv_segment
FROM customer_clv
ORDER BY lifetime_value DESC;

-- SQL Query 2 — CLV segment summary:
WITH customer_clv AS (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT i.invoice_id) AS total_orders,
        ROUND(AVG(i.total), 2) AS avg_order_value,
        ROUND(SUM(i.total), 2) AS lifetime_value,
        DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)) AS tenure_days,
        ROUND(COUNT(DISTINCT i.invoice_id) * 365.0 / 
            NULLIF(DATEDIFF(MAX(i.invoice_date), MIN(i.invoice_date)), 0), 2) AS freq_per_year,
        DATEDIFF((SELECT MAX(invoice_date) FROM invoice), MAX(i.invoice_date)) AS days_since_last
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
segmented AS (
    SELECT *,
        CASE 
            WHEN lifetime_value >= 100 THEN 'High Value'
            WHEN lifetime_value >= 70 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS clv_segment
    FROM customer_clv
)
SELECT 
    clv_segment,
    COUNT(*) AS num_customers,
    ROUND(AVG(lifetime_value), 2) AS avg_lifetime_value,
    ROUND(AVG(total_orders), 2) AS avg_orders,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(freq_per_year), 2) AS avg_purchase_freq_per_year,
    ROUND(AVG(tenure_days), 0) AS avg_tenure_days,
    ROUND(AVG(days_since_last), 0) AS avg_days_since_last
FROM segmented
GROUP BY clv_segment
ORDER BY avg_lifetime_value DESC;

-- SQL Query 3 — Stopped vs Active customer characteristics:
WITH customer_clv AS (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT i.invoice_id) AS total_orders,
        ROUND(AVG(i.total), 2) AS avg_order_value,
        ROUND(SUM(i.total), 2) AS lifetime_value,
        DATEDIFF((SELECT MAX(invoice_date) FROM invoice), MAX(i.invoice_date)) AS days_since_last,
        COUNT(DISTINCT g.genre_id) AS genres_purchased
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY c.customer_id
)
SELECT 
    CASE WHEN days_since_last > 180 THEN 'Stopped' ELSE 'Active' END AS status,
    COUNT(*) AS num_customers,
    ROUND(AVG(total_orders), 2) AS avg_orders,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(lifetime_value), 2) AS avg_lifetime_value,
    ROUND(AVG(genres_purchased), 2) AS avg_genres_purchased
FROM customer_clv
GROUP BY CASE WHEN days_since_last > 180 THEN 'Stopped' ELSE 'Active' END;


-- S8
-- If data on promotional campaigns (discounts, events, email marketing) is
-- available, how could you measure their impact on customer acquisition,
-- retention, and overall sales?

-- SQL Query 1 — Monthly revenue & customer trends:
SELECT 
    DATE_FORMAT(i.invoice_date, '%Y-%m') AS month,
    COUNT(DISTINCT i.invoice_id) AS num_invoices,
    COUNT(DISTINCT i.customer_id) AS active_customers,
    ROUND(SUM(i.total), 2) AS monthly_revenue,
    ROUND(AVG(i.total), 2) AS avg_order_value
FROM invoice i
GROUP BY DATE_FORMAT(i.invoice_date, '%Y-%m')
ORDER BY month;

-- SQL Query 2 — New vs returning customers per month:
WITH first_purchase AS (
    SELECT customer_id, MIN(invoice_date) AS first_date
    FROM invoice GROUP BY customer_id
)
SELECT 
    DATE_FORMAT(i.invoice_date, '%Y-%m') AS month,
    COUNT(DISTINCT i.customer_id) AS total_active,
    SUM(CASE WHEN DATE_FORMAT(i.invoice_date, '%Y-%m') = DATE_FORMAT(fp.first_date, '%Y-%m') THEN 1 ELSE 0 END) AS new_customers,
    SUM(CASE WHEN DATE_FORMAT(i.invoice_date, '%Y-%m') != DATE_FORMAT(fp.first_date, '%Y-%m') THEN 1 ELSE 0 END) AS returning_invoices,
    ROUND(SUM(i.total), 2) AS monthly_revenue
FROM invoice i
JOIN first_purchase fp ON i.customer_id = fp.customer_id
GROUP BY DATE_FORMAT(i.invoice_date, '%Y-%m')
ORDER BY month;



-- S9
-- How would you approach this problem, if the objective and subjective
-- questions weren't given?

-- Step 1: Understand table sizes and relationships
SELECT 'album' AS table_name, COUNT(*) AS row_count FROM album
UNION ALL SELECT 'artist', COUNT(*) FROM artist
UNION ALL SELECT 'customer', COUNT(*) FROM customer
UNION ALL SELECT 'employee', COUNT(*) FROM employee
UNION ALL SELECT 'genre', COUNT(*) FROM genre
UNION ALL SELECT 'invoice', COUNT(*) FROM invoice
UNION ALL SELECT 'invoice_line', COUNT(*) FROM invoice_line
UNION ALL SELECT 'media_type', COUNT(*) FROM media_type
UNION ALL SELECT 'playlist', COUNT(*) FROM playlist
UNION ALL SELECT 'playlist_track', COUNT(*) FROM playlist_track
UNION ALL SELECT 'track', COUNT(*) FROM track;



-- S10
-- How can you alter the "Albums" table to add a new column named
-- "ReleaseYear" of type INTEGER to store the release year of each album?

-- Add ReleaseYear column
ALTER TABLE album ADD COLUMN ReleaseYear INTEGER;

-- Verify the column was added
SELECT * FROM album LIMIT 5;

-- Example: Update a specific album's release year
UPDATE album SET ReleaseYear = 1981 WHERE album_id = 1;


-- S11
-- Chinook is interested in understanding the purchasing behavior of customers
-- based on their geographical location. They want to know the average
-- total amount spent by customers from each country, along with the number
-- of customers and the average number of tracks purchased per customer.
-- Write an SQL query to provide this information.

SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) AS num_customers,
    ROUND(AVG(customer_totals.total_spent), 2) AS avg_total_spent,
    ROUND(AVG(customer_totals.tracks_purchased), 2) AS avg_tracks_per_customer
FROM customer c
JOIN (
    SELECT 
        i.customer_id,
        SUM(i.total) AS total_spent,
        SUM(il_counts.track_count) AS tracks_purchased
    FROM invoice i
    JOIN (
        SELECT invoice_id, SUM(quantity) AS track_count
        FROM invoice_line
        GROUP BY invoice_id
    ) il_counts ON i.invoice_id = il_counts.invoice_id
    GROUP BY i.customer_id
) customer_totals ON c.customer_id = customer_totals.customer_id
GROUP BY c.country
ORDER BY avg_total_spent DESC;


/* ===================================== END OF FILE ===================================== */
