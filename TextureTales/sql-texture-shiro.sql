select sum (s.qty) as Total_Quantity
from sales s 

select concat('$', to_char(sum(s.qty * s.price),  'FM9,999,999,999')) as Total_Revenue
from sales s 

select concat('$', to_char(sum(s.discount * s.qty), 'FM9,999,999,999')) as Total_discount
from sales s 

select count(distinct s.txn_id) as Unique_Transactions
from sales s 

select round(avg(txns),3) from (
select count(distinct s.prod_id) as txns, txn_id 
from sales s 
group by txn_id )

select round(avg(discount),2), txn_id 
from sales s 
group by txn_id 

select round(avg(s.qty * s.discount),3) as total_discount, txn_id 
from sales s 
group by txn_id 

select sum(qty * price), s."member" 
from sales s 
group by s."member"


--7. What is the average revenue for member transactions and non-member transactions?
with cte as (
select txn_id, "member" as mem, round(avg(qty * price),3) as sales
from sales s 
group by txn_id, s."member"  )
select mem as if_member, round(avg(sales),3) as avg_revenue
from cte
group by mem

--8. What are the top 3 products by total revenue before discount?
with cte as (
select s.prod_id, sum(s.qty * s.price) as cost
from sales s 
group by 1
order by 2 desc
limit 3 )
select pd.product_name, cte.prod_id, cte.cost 
from cte join product_details pd on cte.prod_id = pd.product_id 

--9. What are the total quantity, revenue and discount for each segment?
with cte as (
select s.prod_id, sum(s.qty * s.discount) as tot_disc, sum(s.qty * s.price) as tot_prc, sum(s.qty) as tot_qty 
from sales s 
group by s.prod_id )
select pd.segment_name, sum(tot_disc) as tot_disc, sum(tot_prc) as tot_prc, sum(tot_qty) as tot_qty 
from cte left join product_details pd on cte.prod_id = pd.product_id 
group by pd.segment_name 
order by 3 desc

--10.A. What is the top selling product for each segment?
with cte as (
select s.prod_id, sum(s.qty)
from sales s 
group by s.prod_id )
select sum(cte.sum), pd.segment_name, pd.product_name 
from cte left join product_details pd on cte.prod_id = pd.product_id
group by rollup (pd.segment_name, pd.product_name) 
order by 2,1 desc

--10.B. What is the top selling product for each segment?
with cte as (
select s.prod_id, sum(s.qty)
from sales s 
group by s.prod_id ),
cte2 as (
select row_number () over (partition by pd.segment_name order by sum(cte.sum) desc), sum(cte.sum) as tot_qty, pd.segment_name, pd.product_name 
from cte left join product_details pd on cte.prod_id = pd.product_id 
group by pd.segment_name, pd.product_name
order by tot_qty)
select * from  cte2
where row_number = 1

--11. What are the total quantity, revenue and discount for each category?
with cte as (
select sum(s.qty * s.price) as tot_prc, sum(s.qty * s.discount) as tot_disc, sum(s.qty) as tot_qty, s.prod_id 
from sales s 
group by s.prod_id )
select pd.category_name, sum(tot_prc) as tot_prc, sum(tot_disc) as tot_disc, sum(tot_qty) as tot_qty 
from cte left join product_details pd on cte.prod_id = pd.product_id 
group by pd.category_name 

--12. What is the top selling product for each category?
with cte as (
select s.prod_id, sum(s.qty)
from sales s 
group by s.prod_id ),
cte2 as (
select row_number () over (partition by pd.category_name order by sum(cte.sum) desc), sum(cte.sum) as tot_qty, pd.category_name, pd.product_name 
from cte left join product_details pd on pd.product_id = cte.prod_id
group by pd.category_name, pd.product_name  
)
select * from cte2 
where row_number = 1