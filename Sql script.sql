CREATE database Sales;

USE SALES;
SELECT * FROM `coffee shop`;
RENAME TABLE `COFFEE SHOP` TO COFFEE_SHOP_SALES;

SELECT * FROM COFFEE_SHOP_SALES;
DESC coffee_shop_sales;



-- DATA VALIDATION

 # changing data types of store location text to varchar
 
 ALTER TABLE coffee_shop_sales MODIFY store_location VARCHAR(100);
 
# Changing data type of transaction date to date

ALTER TABLE coffee_shop_sales MODIFY transaction_date DATE;    -- Gives an error

SELECT STR_TO_DATE(transaction_date, "%m/%d/%Y") AS Date_Format FROM coffee_shop_sales;


SET SQL_SAFE_UPDATES = 0;            #For update the date permanantly#

UPDATE coffee_shop_sales SET transaction_date = STR_TO_DATE(transaction_date, "%m/%d/%Y");

ALTER TABLE coffee_shop_sales MODIFY transaction_date DATE; 



# Changing data type of transaction_time to TIME from text

ALTER TABLE coffee_shop_sales MODIFY transaction_time TIME;




# Changing column name 'ï»¿transaction_id' to 'transaction_id'

ALTER TABLE coffee_shop_sales RENAME COLUMN ï»¿transaction_id TO transaction_id ;



# Check for Null values 

SELECT
	SUM(transaction_id IS NULL) AS Null_Transaction_Id,
	SUM(transaction_date IS NULL) AS Null_Transaction_date,
	SUM(transaction_qty IS NULL) AS NULL_transaction_qty,
    SUM(store_id IS NULL) AS NULL_store_id,
    SUM(store_location IS NULL) AS NULL_store_location,
    SUM(unit_price IS NULL) AS NULL_unit_price,
    SUM(product_type IS NULL) AS NULL_product_type,
    SUM(product_detail IS NULL) AS NULL_product_detail,
    SUM(product_category IS NULL) AS NULL_product_category
FROM coffee_shop_sales;




# CHECK FOR INVALID QUANTITY

SELECT * FROM coffee_shop_sales WHERE transaction_qty <= 0;



# CHECK FOR INVALID PRICESS

SELECT * FROM coffee_shop_sales WHERE unit_price <= 0;



# CHECK UNIQUE VALUES

SELECT DISTINCT(store_location) FROM coffee_shop_sales;

SELECT DISTINCT(product_category) FROM coffee_shop_sales;

SELECT DISTINCT(product_type) FROM coffee_shop_sales;



# DUPLICATE TRANSACTION CHECK

SELECT transaction_id, COUNT(*) AS Duplicate_count 
FROM coffee_shop_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------------------------------------------------------------------------------------------
 
 
 # DATA TRANSFORMATION (DERIVED FILEDS)
 
 
 # Calculate Revenue/Sales from table
  
SELECT transaction_qty * unit_price FROM coffee_shop_sales;


# Create a VIEW With Revenue Calculations

CREATE VIEW Revenue AS
SELECT 
		*, transaction_qty * unit_price AS Revenue
FROM coffee_shop_sales;

SELECT * FROM REVENUE;

-- --------------------------------------------------------------------------------------------------------------


# Add TIME RELATED ATTRIBUTES

CREATE VIEW Trend_data AS
SELECT
		*, 
        HOUR(transaction_time) AS sales_hour,
        MINUTE(transaction_time) AS sales_min,
        DAYNAME(transaction_date) AS sales_dayname,
        MONTH(transaction_date) AS sales_month,
        DATE(transaction_date) AS sales_date,
        YEAR(transaction_date) AS sales_year
FROM Revenue;

SELECT * FROM TREND_DATA;




# Exploratory Business Analysis using SQL

# 1. TOTAL REVENUE

SELECT ROUND(SUM(revenue), 2) AS total_revenue FROM revenue;


# 2. REVENUE BY STORE LOCATION

SELECT 
	store_location,
	ROUND(SUM(revenue),2) AS Total_Revenue
FROM revenue
GROUP BY store_location
ORDER BY Total_Revenue DESC;


# 3. REVENUE BY PRODUCT CATEGORY

SELECT
	product_category,
    ROUND(SUM(revenue),2) AS total_revenue
FROM revenue
GROUP BY product_category
ORDER BY Total_Revenue DESC;

# 4. TOP 10 PRODUCT BY REVENUE

SELECT 
	product_detail,
    SUM(revenue) AS top10_Revenue
FROM revenue
GROUP BY product_detail
ORDER BY top10_Revenue DESC
LIMIT 10;

# BOTTOM 10 PRODUCT BY REVENUE

SELECT
	product_detail,
    SUM(revenue) AS total_revenue
FROM revenue
GROUP BY product_detail
ORDER BY total_revenue
LIMIT 10;



# 5. SECOND HIGHEST PRODUCT

SELECT 
	product_detail,
    SUM(revenue) AS top10_Revenue
FROM revenue
GROUP BY product_detail
ORDER BY top10_Revenue DESC
LIMIT 1,1;                -- By using offset 


# 6 REVENUE FROM TOP LOCATION AND PRODUCT CATEGORY

SELECT 
	store_location,
    product_category,
    SUM(revenue) AS total_Revenue
FROM revenue
GROUP BY store_location, product_category
ORDER BY total_Revenue DESC;


# 7. HOURLY  SALES TREND

SELECT
	sales_hour,
    ROUND(SUM(revenue),2) AS hourly_revenue
FROM trend_data
GROUP BY sales_hour
ORDER BY hourly_revenue DESC;


# During peak hr/ non peak hr which product sold

SELECT
	sales_hour,
    product_category,
    ROUND(SUM(revenue),2) AS hourly_revenue
FROM trend_data
GROUP BY sales_hour, product_category
ORDER BY hourly_revenue DESC;



# 8. DAILY SALES TREND

SELECT
	sales_dayname,
    ROUND(SUM(revenue),2) AS Daily_revenue
FROM trend_data
GROUP BY sales_dayname
ORDER BY Daily_revenue DESC;


# 9. MONTHLY SALES TREND
SELECT
	sales_month,
    ROUND(SUM(revenue),2) AS Monthly_revenue
FROM trend_data
GROUP BY sales_month
ORDER BY Monthly_revenue DESC;

# 10. IN DETAIL SALES TREND
SELECT
	sales_year,
	sales_month,
    sales_dayname,
    sales_hour,
    ROUND(SUM(revenue),2) AS total_revenue
FROM trend_data
GROUP BY sales_year,
	sales_month,
    sales_dayname,
    sales_hour
ORDER BY total_revenue DESC;



# REVENUE AS PER STORE LOCATION AND TREND DATA

SELECT 
	store_location,
    sales_dayname,
    product_category, 
    ROUND(SUM(revenue),2) AS total_revenue
FROM trend_data 
GROUP BY
	store_location,
    sales_dayname,
    product_category
ORDER BY total_revenue DESC;



 -- -- ADD COLUMN FOR WEEKDAYS AND WEEKEND
 
 ALTER TABLE coffee_shop_sales ADD COLUMN Day_Type VARCHAR(20);
    
SELECT * FROM coffee_shop_sales;

SELECT CASE
	WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN "WEEKEND"
    ELSE "WEEKDAY"
    END AS WEEKDAY_WEEKEND FROM coffee_shop_sales;


SET SQL_SETS_UPDATES = 0;
UPDATE coffee_shop_sales SET Day_TYPE = CASE
	WHEN  DAYOFWEEK(transaction_date) IN (1,7) THEN "WEEKEND"
    ELSE "WEEKDAY"
    END;
    
    
SELECT * FROM coffee_shop_sales;

# CHECK REVENUE FOR THIS DAY

SELECT day_type, 
SUM(transaction_qty * unit_price) AS REVENUE 
FROM coffee_shop_sales
GROUP BY day_type;

    
-- CORE KPI CALCULATIONS

#1. TOTAL ORDERS

SELECT COUNT(DISTINCT transaction_id) AS total_orders
FROM coffee_shop_sales;



#2. TOTAL REVENUE

SELECT ROUND(SUM(transaction_qty * unit_price),2) AS total_revenue
FROM coffee_shop_sales;



#3. AVERAGE ORDER VALUE (AOV)

SELECT  ROUND (SUM(transaction_qty * unit_price) / COUNT(DISTINCT transaction_id), 2) AS average_order_value
FROM coffee_shop_sales;
  



















