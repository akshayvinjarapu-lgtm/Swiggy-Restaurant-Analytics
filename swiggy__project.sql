CREATE DATABASE IF NOT EXISTS swiggy_db;
USE swiggy_db;

DROP TABLE IF EXISTS swiggy_raw;
CREATE TABLE swiggy_raw (
    id            VARCHAR(20),
    name          VARCHAR(200),
    city          VARCHAR(60),
    rating        VARCHAR(20),
    rating_count  VARCHAR(30),
    cost          VARCHAR(20),
    cuisine       VARCHAR(300),
    lic_no        VARCHAR(30),
    link          VARCHAR(500),
    address       VARCHAR(500),
    menu          VARCHAR(20)
) CHARACTER SET utf8mb4;


   show variables like "secure_file_priv";
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/swiggy resturent raw data.csv'
INTO TABLE swiggy_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS rows_loaded FROM swiggy_raw;      -- expect 4080

select * from swiggy_raw;
-- Total Restaurants
SELECT
    COUNT(*) AS Total_Restaurants
FROM swiggy_raw;

-- 2. Average Restaurant Rating
SELECT
    ROUND(AVG(rating), 2) AS Average_Rating
FROM swiggy_raw;
-- Business Question: What is the average rating of restaurants?
-- 3. Total Cities
SELECT
    COUNT(DISTINCT city) AS Total_Cities
FROM swiggy_raw;
-- Business Question: How many cities are covered?

-- 4. Average Restaurant Cost
SELECT
    ROUND(AVG(CAST(REPLACE(cost, '₹', '') AS DECIMAL(10,2))), 2) AS Average_Cost
FROM swiggy_raw;
-- Business Question: What is the average cost for two people?

-- 5. Top 10 Cities by Restaurant Count
SELECT
    city,
    COUNT(*) AS Total_Restaurants
FROM swiggy_raw
GROUP BY city
ORDER BY Total_Restaurants DESC
LIMIT 10;
-- Business Question: Which cities have the highest number of restaurants?

-- 6. Rating Count Distribution
SELECT
    CASE
        WHEN rating_count IS NULL THEN 'Too Few Ratings'
        WHEN rating_count >= 5000 THEN '5K+ Ratings'
        WHEN rating_count >= 1000 THEN '1K+ Ratings'
        WHEN rating_count >= 500 THEN '500+ Ratings'
        WHEN rating_count >= 100 THEN '100+ Ratings'
        WHEN rating_count >= 50 THEN '50+ Ratings'
        ELSE '20+ Ratings'
    END AS Rating_Category,
    COUNT(*) AS Restaurant_Count
FROM swiggy_raw
GROUP BY Rating_Category
ORDER BY Restaurant_Count DESC;
-- Business Question: How are restaurants distributed based on customer rating counts?

-- 7. Restaurant Distribution by Cost Range
SELECT
    FLOOR(CAST(REPLACE(REPLACE(cost, '₹', ''), ',', '') AS UNSIGNED) / 100) * 100 AS Cost_Range,
    COUNT(*) AS Restaurant_Count
FROM swiggy_raw
WHERE cost IS NOT NULL
GROUP BY Cost_Range
ORDER BY Cost_Range;
-- Business Question: Which price range contains the most restaurants?

-- 8. Restaurant Cost vs Rating Analysis

SELECT
    name,
    city,
    CAST(REPLACE(REPLACE(cost, '₹', ''), ',', '') AS UNSIGNED) AS Restaurant_Cost,
    CAST(rating AS DECIMAL(3,1)) AS Rating
FROM swiggy_raw
WHERE cost IS NOT NULL
  AND rating REGEXP '^[0-9]+(\\.[0-9]+)?$'
ORDER BY Restaurant_Cost;
-- Business Question: Does restaurant cost have any relationship with customer ratings?

-- 9. Top 5 Average Rating by City
SELECT
    city,
    ROUND(AVG(rating), 2) AS Average_Rating
FROM swiggy_raw
WHERE rating IS NOT NULL
GROUP BY city
ORDER BY Average_Rating DESC
LIMIT 5;

-- Business Question: Which five cities have the highest average restaurant ratings?

-- 10. Average Cost by Cuisine
SELECT
    TRIM(SUBSTRING_INDEX(cuisine, ',', 1)) AS Cuisine,
    ROUND(
        AVG(
            CAST(
                REPLACE(REPLACE(cost, '₹', ''), ',', '')
                AS UNSIGNED
            )
        ), 2
    ) AS Average_Cost,
    COUNT(*) AS Total_Restaurants
FROM swiggy_raw
WHERE cuisine IS NOT NULL
  AND cost IS NOT NULL
GROUP BY Cuisine
ORDER BY Average_Cost DESC;

-- Business Question: Which cuisines have the highest average restaurant cost?