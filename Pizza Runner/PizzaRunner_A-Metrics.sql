select pt.topping_name 
from pizza_toppings pt join ( select unnest(string_to_array(pr.toppings,','))::int as value
from pizza_recipes pr where pr.pizza_id = 1 ) p2 on p2.value = pt.topping_id 

--How many pizzas were ordered?
select count(co.order_id)
from customer_orders co 

--How many unique customer orders were made?
select count(distinct order_id) 
from customer_orders co 

--How many successful orders were delivered by each runner?
select ro.runner_id, count(ro.order_id)
from runner_orders ro 
where ro.pickup_time <> 'null'
group by ro.runner_id 

--How many of each type of pizza were ordered?
select count(co.pizza_id), pn.pizza_name 
from customer_orders co join pizza_names pn on co.pizza_id = pn.pizza_id 
group by co.pizza_id, pn.pizza_name

--How many of each type of pizza was delivered?
select count(ro.order_id), pn.pizza_name 
from customer_orders co join runner_orders ro on co.order_id = ro.order_id 
join pizza_names pn on pn.pizza_id = co.pizza_id 
where ro.pickup_time <> 'null'
group by pn.pizza_name 

--How many Vegetarian and Meatlovers were ordered by each customer?
select distinct co.customer_id, pn.pizza_name, count(pn.pizza_name) 
from customer_orders co join pizza_names pn on co.pizza_id = pn.pizza_id 
group by co.customer_id, pn.pizza_name  
order by 1

--What was the maximum number of pizzas delivered in a single order?
select count(co.order_id) as NumOFPizzas, order_id 
from customer_orders co 
group by co.order_id 
order by 1 desc 
limit 1

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select co.customer_id, count(co.pizza_id) 
from customer_orders co join runner_orders ro on co.order_id = ro.order_id 
where ro.pickup_time <> 'null' and (co.exclusions <> 'null' or co.extras <> 'null') and (co.exclusions is not null or co.extras is not null)
group by co.customer_id 
order by 1 desc

--How many pizzas were delivered that had both exclusions and extras?
select count(co.pizza_id) as Pizza_WO_Exculsions_or_Extras
from customer_orders co join runner_orders ro on co.order_id = ro.order_id 
where ro.pickup_time <> 'null' and
(co.exclusions <> 'null' and co.exclusions is not null and length(exclusions) > 0) and
(co.extras <> 'null' and co.exclusions is not null  and length(exclusions) > 0)

--What was the total volume of pizzas ordered for each hour of the day?
select date_part('hour', co.order_time), count(*) as Num_of_Pizzas 
from customer_orders co 
group by date_part('hour', co.order_time) 

---- 10. What was the volume of orders for each day of the week?
select dayname(co.order_time) as DayOfWeek , count(*) as NumOfPizzas 
from customer_orders co 
group by dayname(co.order_time) 
