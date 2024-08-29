-- CREATE TABLE df_orders (
--     order_id INT PRIMARY KEY,
--     order_date DATE,
--     ship_mode VARCHAR(20),
--     segment VARCHAR(20),
--     country VARCHAR(20),
--     city varchar(20),
--     state VARCHAR(20),
--     postal_code VARCHAR(20),
--     region VARCHAR(20),
--     category VARCHAR(20),
--     sub_category VARCHAR(20),
--     product_id VARCHAR(20),
--     quantity INT,
--     discount DECIMAL(7,2),
--     sales_price DECIMAL(7,2),
--     profit DECIMAL(7,2)
-- );

select * from df_orders;

-- find top 10 highest revenue generating products

select sub_category, product_id, sum(sales_price) as sales
from df_orders
group by product_id, sub_category
order by sales desc
limit 10;

-- find top 5 highest selling products in each region

with cte as (
select region, product_id, sum(sales_price) as sales
from df_orders
group by region, product_id)
select * from (
select * , dense_rank() over(partition by region order by sales desc) as `rank`
from cte) A 
where `rank` <= 5;

-- find month over month growth comparison for 2022 and 2023 sales

with cte as (
select year(order_date) as order_year, month(order_date) as order_month,sum(sales_price) as sales
from df_orders
group by year(order_date), month(order_date)
)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- for each category which month has highest sales

with cte as (
select category, format(order_date,'yyyyMM') as  order_year_month,
sum(sales_price) as sales
from df_orders
group by category, format(order_date,'yyyyMM')
)
select * from (
select *, dense_rank() over(partition by category order by sales desc) as `rank`
from cte
) a
where `rank` = 1;

-- which sub category had highest growth by profit in 2023 compare to 2022

with cte as (
select sub_category, year(order_date) as order_year, sum(sales_price) as sales
from df_orders
group by sub_category, year(order_date)
)
, cte2 as (
select sub_category,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select * 
, (sales_2023 - sales_2022)*100/sales_2022 as percentage_growth
from cte2
order by (sales_2023 - sales_2022)*100/sales_2022 desc
limit 1 ;





