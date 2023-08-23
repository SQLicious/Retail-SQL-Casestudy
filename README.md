# Retail-Store-Analysis-with-SQL
Retail Dataset Sales Case Study Analysis using SQL

This project is a case study analysis of a retail store dataset from Kaggle using SQL. The dataset contains information about sales, features, and stores of a retail chain. The goal of this project is to answer various business questions using SQL queries and data visualization.

Dataset

The dataset used in this project can be found here. It consists of three CSV files:

Sales Data-set.csv: This file contains the transactional data of the retail chain, including information such as date, store number, department number, weekly sales, and an indicator of whether the week is a special holiday week.

Product Data-set.csv: This file provides product-related information within the retail chain. It includes details like product number, department, category, sub-category, and cost.

Stores Data-set.csv: In this file, you will find essential store information, including store number, city, state, region, and size.of the retail chain, such as store number, city, state, region, and size.

https://www.kaggle.com/datasets/manjeetsingh/retaildataset

**1. Data Retrieval:**
Write an SQL query to retrieve the total weekly sales for each department in each store. Include the store number, department number, week, and the sum of weekly sales.

**2. Data Aggregation:**
Calculate the average consumer price index (CPI) for each store over the entire period. Display the store number and its average CPI.

**3. Joining Tables:**
Combine the 'Sales' and 'Features' tables to retrieve the store number, department number, date, and weekly sales where the consumer price index (CPI) is greater than 160.

**4. Subqueries and Filtering:**
Find the department(s) with the highest weekly sales in a specific store during a holiday week. Display the store number, department number, and week.

**5. Holiday Markdown Analysis:**
Calculate the average sales for departments with markdowns during holiday weeks and compare them to non-holiday weeks. Display the department number, average sales on holidays, and average sales on non-holidays.

**6. Store-Specific Recommendations:**
Identify the store with the highest sales during a Super Bowl holiday week. Retrieve the store number, department number, week, and sales for that specific store.

**7. Markdown Impact Evaluation:**
Determine the correlation between markdown values (MarkDown1 to MarkDown5) and weekly sales. Display the department number, markdown type, and the correlation coefficient.

**8. Store's Most and Least Affected Departments:**
For a specific store, identify the department with the highest and lowest average weekly sales. Display the store number, department numbers, and their respective average sales.

**9. Maximum Weekly Sales Department:**
Find the department with the highest weekly sales across all stores and weeks. Display the department number, its highest sales value, and the week.

**10. Top Performing Departments:**
Retrieve the top 5 departments with the highest total sales across all stores. Display the department number and its total sales.
