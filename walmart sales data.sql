CREATE DATABASE sales_data;

CREATE TABLE sales (
    InvoiceID varchar(50) not null PRIMARY KEY,
    Branch VARCHAR(255) not null,
    City VARCHAR(255) not null,
    CustomerType VARCHAR(255) not null,
    Gender VARCHAR(255) not null,
    Product_line VARCHAR(255) not null,
    UnitPrice DECIMAL(10, 2) not null,
    Quantity INT not null,
    Tax DECIMAL(10, 2) not null,
    Total DECIMAL(10, 2) not null,
    Date DATE not null,
    Time TIME not null,
    Payment VARCHAR(255) not null,
    COGS DECIMAL(10, 2) not null,
    GrossMarginPercentage DECIMAL(5, 2) not null,
    GrossIncome DECIMAL(10, 2) not null,
    Rating DECIMAL(5, 2) not null
);
select * from sales ;

-- --------------------------------------------------------------------------------------
-- -------------------------------- Feature Engineering----------------------------------


-- --------- Time_of_Day
SELECT
    time,
    CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sales;


Alter table sales add column time_of_day varchar(25);

update  sales
set time_of_day=(
case
 when time between "00:00:00" and "12:00:00" then "morning"
 when time between "12:01:00" and "16:00:00" then "afternoon"
 else "evening" end);
 
 
 -- ------------------------------------------------------------------------------------
 
 -- ------ day_name
 
 -- use a day name function to find day name from date column.
select 
		date,
        dayname(date) as day_name
from  sales; 
alter table sales add column day_name varchar(10);
update sales
 set day_name=dayname(date);
 
 
-- ----------- month_name
  
  -- -- use a month name function to find month_name from date column.
  select date,
            monthname(date)
from sales;
  alter table  sales  add column month_name varchar(10);
  update sales
 set month_name=monthname(date);
 
-- ------------------------------Exploratory Data Analysis------------------------------

-- ------------------------------Business question to answer----------------------------
-- Generic questions

-- 1) how many unique cities does the data have?
select 
        count(distinct(city))
from  sales;
 
 -- in which city is each branch?
 -- we will use max function to answer this question. max function go to each row and select unique record.
 select city,
        max(branch)
from  `walmartsalesdata.csv` 
group by city;
 -- we can also answer the above question as 
 select distinct city,branch from sales;
 
 -- ---------------------------------- product-------------------------------------------
 
 -- how many unique product line does the data have?
 select 
       distinct(product_line) from sales;
 
 -- what is the most_common payment method?
 select payment,
		count(payment) as common_payment 
 from  sales 
 group by payment order by common_payment desc;
-- what is the most selling product_line"

-- what is the total revenue by month
select month_name as month,
       sum(total) as revenue
from sales 
group by month 
order by revenue desc ;
-- what month had the largest COGS?
select month_name as month,
       sum(cogs) as cogs
       from sales 
group by month
 order by cogs desc;

-- what  is the most selling product_line?
select product_line,
       count(product_line) as cnt
from sales
group by  product_line 
order by cnt desc;

-- what product_line had the largest revenue
select product_line,
	sum(total) as revenue
from sales 
group by Product_line 
order by revenue desc;

-- what is the city with the largest revenue?
select city,
       sum(total) as revenue 
from sales 
group by city
 order by revenue desc;

-- what product line had the largest vAT?
select product_line,
       avg(Tax) as VAT
from sales
 group by Product_line
 order by VAT desc;

-- fetch each product line and add a column to those product lying showing "Good","bad".
-- Good if it is greater than average sales.
select product_line,
       sum(total) as total_sale,
       (select avg(total) as avg_sales from sales),
       if(product_line> avg(total),"Bad","Good")
from sales 
group by Product_line;

-- which product_line sold more product than average product sold?
select branch,
       sum(quantity) as sold_quantity 
 from sales 
 group by branch 
 having sum(quantity)>(select avg(quantity) from sales);
 
 
 -- what is the most common product_line by gender.
 select product_line,
        gender ,
        count(gender) as total_count
from sales 
group by product_line,gender
 order by total_count desc;
 
 -- what is the average rating of each product_line?
 select product_line,
		round(avg(rating),2) as avg_rating
from sales
group by  product_line 
order by avg_rating desc ;
 
 -- --------------------- Sales------------------------------------
 --  number of sales made in each time of a day per weekday.
 select time_of_day,day_name,
		round(count(total),2) as total_sales
from sales where day_name="monday"
group by  time_of_day,day_name
order by total_sales desc ;

--  which of the customer type bring the most revenue
select customertype,
        sum(total) as revenue
from sales group by customertype 
order by  revenue desc;

-- which city has the largest percent/VAT ( Value Added Tax)?
select city,
       round(avg(tax),2) as tax 
from sales 
group by city
order by tax desc;

-- which customer type pays the most in VAT.
select customertype,
       round(avg(tax),2) as tax 
from sales
group by customertype
order by tax desc;
-- we can also answer the ABOVE question as.
SELECT customertype, 
       sum(tax) AS total_tax
FROM sales
GROUP BY customertype
ORDER BY total_tax DESC
LIMIT 1;

-- ----------------------- customer----------------------------------------
-- how many unique customertype does the data have.
select 
      distinct(customertype) 
from sales;
-- but this querry wil be differnt..
select 
      distinct(count(customertype) )
from sales;
-- it will return number of unique values--

-- how amny unique payment does the data have?
select
     distinct(payment) 
from sales;

-- whatis the most common customer type?
select customertype,
	count(customertype) as cnt
    from sales
    group by customertype
    order by cnt desc;
    
-- by chatgpt
SELECT customertype, COUNT(*) AS frequency
FROM sales
GROUP BY customertype
ORDER BY frequency DESC
LIMIT 1;

-- which customertype buys the most?
select customertype,
        sum(total) as total_purchase
from sales 
group by customertype
order by total_purchase;

-- what is the gender of the most customer?
select gender,
       count(*) as cnt 
from sales 
group by gender
order by cnt desc;


-- what is the gender distribution per branch?

SELECT
    branch,
    SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS Male,
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS Female,
    COUNT(gender) AS gender_count
FROM
    sales
GROUP BY
    branch
ORDER BY
    gender_count DESC;
    
-- which time of the day customer give most rating?
select time_of_day,avg(rating) as rating from sales group by time_of_day order by rating desc;

-- which time of the day do customer give most rating by per branch..
select time_of_day,avg(rating) as rating from sales where branch="c" group by time_of_day order by rating desc;



-- which day_of_the week has best avg(rating)?
select day_name,avg(rating) as avg_rating from sales group by day_name order by avg(rating) desc;
-- - which  day of the week has the best avg rating by per branch..
select day_name,avg(rating) as avg_rating from sales where branch="C" group by day_name  order by avg_rating desc;







