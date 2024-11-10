--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
with cte as (
select r.runner_id, date_trunc('week', r.registration_date) as WeekStart
from runners r )
select count(runner_id) as Signups, WeekStart
from cte
group by 2
order by 2


--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select ro.runner_id , avg(age(ro.pickup_time::timestamp , co.order_time::timestamp)) as TimeToPick
from customer_orders co join runner_orders ro on co.order_id = ro.order_id 
where ro.pickup_time <> 'null'
group by 1

--Is there any relationship between the number of pizzas and how long the order takes to prepare?
with cte as (
select ro.order_id , count(co.pizza_id) as NumPizzas, max(age(ro.pickup_time::timestamp, co.order_time::timestamp)) as OrderPrepTime 
from runner_orders ro inner join customer_orders co on ro.order_id = co.order_id 
where ro.pickup_time <> 'null'
group by ro.order_id )
select numpizzas, avg(orderpreptime)
from cte
group by numpizzas

--What was the average distance travelled for each customer?
select co.customer_id, round(avg(replace(ro.distance, 'km', '')::numeric(3,1)),2) as avg_dist
from runner_orders ro join customer_orders co on co.order_id = ro.order_id
where ro.distance <> 'null'
group by 1

--What was the difference between the longest and shortest delivery times for all orders?
select max(regexp_replace(ro.duration, '[^0-9]', '')::int) - min(regexp_replace(ro.duration, '[^0-9]', '')::int) as TimeDiff
from runner_orders ro 
where ro.duration <> 'null'

--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
with cte as (
select distinct co.pizza_id, (case 
	when co.pizza_id = 1 then 12
	else 10
end ) as cost
from customer_orders co )
select sum(cost) as TotalMoney
from customer_orders co inner join cte on co.pizza_id = cte.pizza_id

--What are the standard ingredients for each pizza?
with cte as (
select unnest(string_to_array(pr.toppings,','))::int as value
from pizza_recipes pr 
)
select pt.topping_name 
from cte join pizza_toppings pt on cte.value = pt.topping_id 
group by value, pt.topping_name 
having count(*) >= 2

--What was the most commonly added extra?
with cte as (
select unnest(string_to_array(co.extras,',')) as toppings_ext
from customer_orders co 
where co.extras <> 'null' and length(co.extras) >= 1
group by 1
having count(1) >= 2 )
select pt.topping_name 
from pizza_toppings pt join cte on cte.toppings_ext::int = pt.topping_id 

--What was the most common exclusion?
with cte as (
select unnest(string_to_array(co.exclusions, ',')) as Excluded, count(1)
from customer_orders co 
where co.exclusions <> 'null' and length(co.exclusions) >= 1
group by 1
order by count(1) desc
limit 1 )
select pt.topping_name 
from pizza_toppings pt join cte on pt.topping_id = cte.excluded::int



