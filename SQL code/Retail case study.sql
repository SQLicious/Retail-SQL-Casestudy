# Date created and Last ran : 08-23-2023 
# Retail Data Set Case Study
# Data Source : Kaggle, Link https://www.kaggle.com/datasets/manjeetsingh/retaildataset
# Course: Submission for  Cosmo AI Learning Community Week 3 Assignment

/* Lets Create the Tables in a new Database called Retail*/

CREATE DATABASE retail;
USE retail;

CREATE TABLE stores (
  Store INT PRIMARY KEY,
  Type VARCHAR(1),
  Size INT
);
describe table stores;

CREATE TABLE features (
  Store INT,
  Date DATE,
  Temperature DECIMAL(6, 2),
  Fuel_Price DECIMAL(5, 3),
  MarkDown1 DECIMAL(10, 2) DEFAULT NULL,
  MarkDown2 DECIMAL(10, 2) DEFAULT NULL,
  MarkDown3 DECIMAL(10, 2) DEFAULT NULL,
  MarkDown4 DECIMAL(10, 2) DEFAULT NULL,
  MarkDown5 DECIMAL(10, 2) DEFAULT NULL,
  CPI DECIMAL(10, 7) DEFAULT NULL,
  Unemployment DECIMAL(6, 3) DEFAULT NULL,
  IsHoliday BOOLEAN,
 -- PRIMARY KEY (Store, Date,IsHoliday),
  FOREIGN KEY (Store) REFERENCES stores (Store)
);

CREATE INDEX idx_features_store_date ON features (Store, Date);
SHOW TABLES FROM retail;

CREATE INDEX idx_features_store_date ON features (Store, Date);

CREATE TABLE sales (
  Store INT,
  Dept INT,
  Date DATE,
  Weekly_Sales DECIMAL(10,2),
  IsHoliday BOOLEAN,
  PRIMARY KEY (Store, Dept, Date),
  FOREIGN KEY (Store) REFERENCES stores (Store),
  FOREIGN KEY (Store, Date) REFERENCES features (Store, Date)
);

/* Load Data into the tables */
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA LOCAL INFILE 'C:/Users/roopm/OneDrive/Desktop/Datasets/stores data-set.csv'
INTO TABLE stores
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/roopm/OneDrive/Desktop/Datasets/sales data-set.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/roopm/OneDrive/Desktop/Datasets/Features data set_new1.csv'
INTO TABLE features
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/* Validate the dat has been loaded */
SELECT * from stores LIMIT 10;
SELECT * from features limit 10;
SELECT * from sales LIMIT 10;
/* Add a new column to identify major USA holidays */

ALTER TABLE features
ADD COLUMN HolidayName VARCHAR(20);

-- Execute the following update query sets for each of the years 2010-2013
-- Update the HolidayName column for Super Bowl
UPDATE features
SET HolidayName = 'Super Bowl'
WHERE IsHoliday = TRUE AND Date BETWEEN '2013-02-08' AND '2013-02-11';

-- Update the HolidayName column for Labor Day
UPDATE features
SET HolidayName = 'Labor Day'
WHERE IsHoliday = TRUE AND Date BETWEEN '2013-09-07' AND '2013-09-09';

-- Update the HolidayName column for Thanksgiving Weekend
UPDATE features
SET HolidayName = 'Thanksgiving Weekend'
WHERE IsHoliday = TRUE AND Date BETWEEN '2013-11-23' AND '2013-11-29';

-- Update the HolidayName column for Christmas
UPDATE features
SET HolidayName = 'Christmas'
WHERE IsHoliday = TRUE AND Date BETWEEN '2013-12-28' AND '2013-12-31';

-- Validate HolidayName has populated correctly for all holiday weekends for all years */
SELECT store,
       date,
       IsHoliday,
	   HolidayName
FROM features 
where IsHoliday = TRUE;


/* 1. Data Retrieval: Write an SQL query to retrieve the total weekly sales for each department in each store.
 Include the store number, department number, week, and the sum of weekly sales. */
 
SELECT Store,
	   Dept,
       Date,
       SUM(Weekly_Sales) AS Total_Weekly_Sales
FROM sales
GROUP BY Store, Dept, Date
ORDER BY Store ASC, Dept ASC, Date ASC;

/* 2. Data Aggregation: Calculate the average consumer price index (CPI) for each store over the entire period. 
Display the store number and its average CPI. */

SELECT 
    Store,
    AVG(CPI) AS Average_CPI
FROM
    features
GROUP BY Store
ORDER BY Store ASC;

/* 3. Joining Tables: Combine the ‘Sales’ and ‘Features’ tables to retrieve the store number, department number, date, and weekly sales
 where the consumer price index (CPI) is greater than 160. */

SELECT 
    s.Store,
    s.Dept,
    s.Date,
    s.Weekly_Sales
FROM
    sales s
        JOIN
    features f ON s.Store = f.Store AND s.Date = f.Date
WHERE
    f.CPI > 160
ORDER BY s.Store ASC , s.Dept ASC , s.Date ASC;

/* 4. Subqueries and Filtering: Find the department(s) with the highest weekly sales in a specific store during a holiday week. 
Display the store number, department number, and week. */

-- Use a CTE to create a temporary table that contains the store number, department number, date, weekly sales, and rank for weekly sales
WITH holiday_sales AS (
  SELECT s.Store, s.Dept, s.Date, s.Weekly_Sales,f.HolidayName,
         RANK() OVER (PARTITION BY s.Store ORDER BY s.Weekly_Sales DESC) AS Sales_Rank
  FROM sales s
  JOIN features f ON s.Store = f.Store AND s.Date = f.Date
  WHERE f.IsHoliday = TRUE
)
-- Now use the CTE  above to find the highest weekly sales in a specific store during a holiday week
-- Use WEEK(), Use mode 2 to get the week number as Sunday is the first day and Week 1 has a Sunday. This fits the sales data table logic
SELECT 
    Store,
    Dept,
    Date,
    WEEK (Date, 2) AS Week_Number, 
    HolidayName
FROM
    holiday_sales
WHERE
    Sales_Rank = 1
ORDER BY Store ASC , Dept ASC , Date ASC;

/* 5. Holiday Markdown Analysis: Calculate the average sales for departments with markdowns during holiday weeks and
 compare them to non-holiday weeks. Display the department number, average sales on holidays, and average sales on non-holidays. */
 
 SELECT s.Dept,
       AVG(CASE WHEN f.IsHoliday = TRUE THEN s.Weekly_Sales ELSE NULL END) AS Average_Sales_Holiday,
       AVG(CASE WHEN f.IsHoliday = FALSE THEN s.Weekly_Sales ELSE NULL END) AS Average_Sales_Non_Holiday
FROM sales s
JOIN features f ON s.Store = f.Store AND s.Date = f.Date
WHERE f.MarkDown1 IS NOT NULL OR f.MarkDown2 IS NOT NULL OR f.MarkDown3 IS NOT NULL OR f.MarkDown4 IS NOT NULL OR f.MarkDown5 IS NOT NULL
GROUP BY s.Dept
ORDER BY s.Dept desc;

/* 6. Store-Specific Recommendations: Identify the store with the highest sales during a Super Bowl holiday week.
 Retrieve the store number, department number, week, and sales for that specific store. */
 
-- Use a CTE to create a temporary table that contains the store number, department number, date, weekly sales, and rank for Super Bowl holiday weeks

WITH super_bowl_sales AS (
  SELECT s.Store, s.Dept, s.Date, s.Weekly_Sales,
         RANK() OVER (ORDER BY SUM(s.Weekly_Sales) DESC) AS Store_Rank
  FROM sales s
  JOIN features f ON s.Store = f.Store AND s.Date = f.Date
  WHERE f.IsHoliday = TRUE AND f.HolidayName = 'Super Bowl'
  GROUP BY s.Store, s.Dept, s.Date
)
-- Use CTE to get store, dept, date, and sales for top grossing store during a Super Bowl holiday week

SELECT Store, Dept, Date, Weekly_Sales
FROM super_bowl_sales
WHERE Store_Rank = 1 -- filters by the highest rank
ORDER BY Store ASC , Dept ASC , Date ASC;

/*7. Markdown Impact Evaluation: Waiting for a clarificatin TB Solved*/ 


/* 8. Store's Most and Least Affected Departments: For a specific store, identify the department with the highest and lowest average weekly sales.
 Display the store number, department numbers, and their respective average sales. */
 
 -- Use a CTE to calculate average weekly sales, and rank for each store and department
WITH avg_sales AS (
  SELECT Store,
         Dept,
         ROUND(AVG(Weekly_Sales),2) AS Average_Weekly_Sales,
         RANK() OVER (PARTITION BY Store ORDER BY AVG(Weekly_Sales) ASC) AS Lowest_Sales_Rank,
         RANK() OVER (PARTITION BY Store ORDER BY AVG(Weekly_Sales) DESC) AS Highest_Sales_Rank
  FROM sales
  GROUP BY Store, Dept
)
-- Use the CTE to find the store and department combinations with the lowest and highest average weekly sales in each store
SELECT Store, Dept, Average_Weekly_Sales,
       CASE 
         WHEN Lowest_Sales_Rank = 1 THEN 'Least performing'
         WHEN Highest_Sales_Rank = 1 THEN 'Highest performing'
         ELSE NULL
       END AS Status
FROM avg_sales
WHERE Lowest_Sales_Rank = 1 OR Highest_Sales_Rank = 1
ORDER BY Store ASC, Dept ASC;

/* 9. Maximum Weekly Sales Department:Find the department with the highest weekly sales across all stores and weeks. 
Display the department number, its highest sales value, and the week. */
 
 SELECT
    s.Dept AS Department_Number,
    MAX(s.Weekly_Sales) AS Highest_Weekly_Sales,
    s.Date AS Week
FROM
    sales s
GROUP BY
    s.Dept, s.Date
ORDER BY
    Highest_Weekly_Sales DESC
LIMIT 1;

/* 10. Top Performing Departments: Retrieve the top 5 departments with the highest total sales across all stores.
 Display the department number and its total sales. */

SELECT
    Dept AS Department_Number,
    SUM(Weekly_Sales) AS Total_Sales
FROM
    sales
GROUP BY
    Dept
ORDER BY
    Total_Sales DESC
LIMIT 5;


