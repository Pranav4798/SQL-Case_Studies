ALTER TABLE weekly_sales
ALTER COLUMN week_date TYPE date USING week_date::date



create table clean_weekly_sales as 
select ws.week_date, date_part('week', ws.week_date) as week_number,
date_part('month', ws.week_date) as month_number,
date_part('year', ws.week_date) as year_number, region, platform,
case
	when right(segment, 1) = '1' then 'Young Adult'
	when right(segment, 1) = '2' then 'Middle Aged'
	when right(segment, 1) = '3' then 'Retirees'
	else 'Unknown'
	end as age_band,
case
	when left(segment, 1) = 'C' then 'Couples'
	when left(segment, 1) = 'D' then 'Families'
	else 'Unknown'
	end as demographic,
customer_type, transactions, sales, 
round(sales/transactions, 2) as avg_transactions
from weekly_sales ws 


--1.	Which week numbers are missing from the dataset?
WITH all_weeks AS (
    SELECT generate_series(1, 60) AS week_numberA
)
SELECT all_weeks.week_numberA
FROM all_weeks
LEFT JOIN clean_weekly_sales AS cws
ON all_weeks.week_numberA = cws.week_number::int
WHERE cws.week_number IS null
order by 1


--2.	How many total transactions were there for each year in the dataset?
select sum(cws.transactions), cws.year_number::int 
from clean_weekly_sales cws 
group by cws.year_number 
order by 1 desc

--3.	What are the total sales for each region for each month?
select cws.region, cws.month_number, sum(cws.sales) as total_sales
from clean_weekly_sales cws 
group by cws.region , cws.month_number 
order by 1,2 desc

--4.	What is the total count of transactions for each platform
select cws.platform, sum(cws.transactions) 
from clean_weekly_sales cws
group by 1
order by 2 desc

--5.	What is the percentage of sales for Retail vs Shopify for each month?
with cte as (
select sum(cws.sales) as monthly_sales, cws.platform, cws.month_number 
from clean_weekly_sales cws 
group by cws.platform, cws.month_number )
select month_number, 
round( 100 * max(case when platform = 'Retail' then monthly_sales else null end) / sum(monthly_sales),2) as Retail_perc,
round( 100 * max(case when platform = 'Shopify' then monthly_sales else null end) / sum(monthly_sales),2) as Shopify_perc
from cte
group by month_number
order by month_number


--6.	What is the percentage of sales by demographic for each year in the dataset?
with cte as (
select year_number, demographic, sum(sales) as tot_sales 
from clean_weekly_sales cws 
group by demographic, year_number
order by 1 desc )
select year_number,
round( 100 * max(case when demographic = 'Couples' then tot_sales else null end) / sum(tot_sales),2) as Couples_perc,
round( 100 * max(case when demographic = 'Unknown' then tot_sales else null end) / sum(tot_sales),2) as unknown_perc
from cte
group by 1


--7.	Which age_band and demographic values contribute the most to Retail sales?
select cws.age_band, cws.demographic, sum(cws.sales)
from clean_weekly_sales cws 
where cws.platform = 'Retail'
group by 1,2
order by 3 desc
