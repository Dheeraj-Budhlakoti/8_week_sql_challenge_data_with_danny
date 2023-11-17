-- A. Pizza Metrics

-- 1. How many pizzas were ordered?

SELECT COUNT(*) as total_pizzas_ordered FROM pizza_runner.customer_orders;

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) as unique_orders FROM pizza_runner.customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT runner_id,COUNT(order_id) as successful_orders FROM pizza_runner.runner_orders
WHERE pickup_time!='null'
GROUP BY runner_id
ORDER BY runner_id;

-- 4. How many of each type of pizza was delivered?

SELECT p.pizza_name,COUNT(c.pizza_id) as pizzas_deliverred FROM pizza_runner.pizza_names p
JOIN pizza_runner.customer_orders c ON p.pizza_id=c.pizza_id
JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
WHERE r.pickup_time!='null'
GROUP BY p.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id,
SUM(CASE WHEN pizza_id=1 THEN 1 ELSE 0 END) as Meat_Lovers,
SUM(CASE WHEN pizza_id=2 THEN 1 ELSE 0 END) as Vegetarian
FROM pizza_runner.customer_orders
GROUP BY customer_id
ORDER BY customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

WITH CTE AS(
	SELECT c.order_id,COUNT(c.pizza_id) FROM pizza_runner.customer_orders c
  	JOIN pizza_runner.runner_orders r on c.order_id=r.order_id
  	WHERE pickup_time!='null'
  	GROUP BY c.order_id
)
SELECT MAX(count) as max_pizza_num FROM CTE;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT customer_id, 
  SUM(CASE 
  WHEN 
	  (exclusions IS NULL or exclusions='null' or LENGTH(exclusions)=0) 
      AND (extras IS NULL or extras='null' or LENGTH(extras)=0)
  THEN 0 
  ELSE 1
  END) as changes,
  SUM(CASE 
    WHEN 
      	(exclusions IS NULL or exclusions='null' or LENGTH(exclusions)=0) 
        AND (extras IS NULL or extras='null' or LENGTH(extras)=0)
    THEN 1 
    ELSE 0
  END) as no_changes 
FROM pizza_runner.customer_orders as c 
INNER JOIN pizza_runner.runner_orders as r on r.order_id = c.order_id 
WHERE pickup_time!='null'
GROUP BY customer_id
ORDER BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(c.order_id) as pizzas_with_both_exclusions_and_extras FROM pizza_runner.customer_orders c
JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
WHERE pickup_time!='null'
AND exclusions IS NOT NULL AND exclusions!='null' AND LENGTH(exclusions)>0
and extras IS NOT NULL AND extras!='null' AND LENGTH(extras)>0;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT DATE_PART('hour', order_time) as Hour, COUNT(*) FROM pizza_runner.customer_orders
GROUP BY Hour
ORDER BY Hour;

-- 10. What was the volume of orders for each day of the week?

SELECT to_char( order_time , 'Day' ) as day, COUNT(*) as pizza_volume FROM pizza_runner.customer_orders
GROUP BY day
ORDER BY day;
