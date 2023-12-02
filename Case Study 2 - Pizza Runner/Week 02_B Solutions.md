# Solution B. Runner and Customer Experience #

**Schema (PostgreSQL v13)**

    CREATE SCHEMA pizza_runner;
    SET search_path = pizza_runner;
    
    DROP TABLE IF EXISTS runners;
    CREATE TABLE runners (
      "runner_id" INTEGER,
      "registration_date" DATE
    );
    INSERT INTO runners
      ("runner_id", "registration_date")
    VALUES
      (1, '2021-01-01'),
      (2, '2021-01-03'),
      (3, '2021-01-08'),
      (4, '2021-01-15');
    
    
    DROP TABLE IF EXISTS customer_orders;
    CREATE TABLE customer_orders (
      "order_id" INTEGER,
      "customer_id" INTEGER,
      "pizza_id" INTEGER,
      "exclusions" VARCHAR(4),
      "extras" VARCHAR(4),
      "order_time" TIMESTAMP
    );
    
    INSERT INTO customer_orders
      ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
    VALUES
      ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
      ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
      ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
      ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
      ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
      ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
      ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
      ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
      ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
      ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
      ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
      ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
      ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
      ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
    
    
    DROP TABLE IF EXISTS runner_orders;
    CREATE TABLE runner_orders (
      "order_id" INTEGER,
      "runner_id" INTEGER,
      "pickup_time" VARCHAR(19),
      "distance" VARCHAR(7),
      "duration" VARCHAR(10),
      "cancellation" VARCHAR(23)
    );
    
    INSERT INTO runner_orders
      ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
    VALUES
      ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
      ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
      ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
      ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
      ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
      ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
      ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
      ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
      ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
      ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
    
    
    DROP TABLE IF EXISTS pizza_names;
    CREATE TABLE pizza_names (
      "pizza_id" INTEGER,
      "pizza_name" TEXT
    );
    INSERT INTO pizza_names
      ("pizza_id", "pizza_name")
    VALUES
      (1, 'Meatlovers'),
      (2, 'Vegetarian');
    
    
    DROP TABLE IF EXISTS pizza_recipes;
    CREATE TABLE pizza_recipes (
      "pizza_id" INTEGER,
      "toppings" TEXT
    );
    INSERT INTO pizza_recipes
      ("pizza_id", "toppings")
    VALUES
      (1, '1, 2, 3, 4, 5, 6, 8, 10'),
      (2, '4, 6, 7, 9, 11, 12');
    
    
    DROP TABLE IF EXISTS pizza_toppings;
    CREATE TABLE pizza_toppings (
      "topping_id" INTEGER,
      "topping_name" TEXT
    );
    INSERT INTO pizza_toppings
      ("topping_id", "topping_name")
    VALUES
      (1, 'Bacon'),
      (2, 'BBQ Sauce'),
      (3, 'Beef'),
      (4, 'Cheese'),
      (5, 'Chicken'),
      (6, 'Mushrooms'),
      (7, 'Onions'),
      (8, 'Pepperoni'),
      (9, 'Peppers'),
      (10, 'Salami'),
      (11, 'Tomatoes'),
      (12, 'Tomato Sauce');

---

**Query #1 - How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**

    WITH CTE AS(
    		SELECT runner_id,registration_date
    	    ,registration_date-((registration_date-DATE('2021-01-01'))%7) as one_week 
            FROM pizza_runner.runners
    )
    SELECT one_week,count(runner_id) as runners_reg FROM CTE
    GROUP BY one_week
    ORDER BY one_week;

| one_week                 | runners_reg |
| ------------------------ | ----------- |
| 2021-01-01T00:00:00.000Z | 2           |
| 2021-01-08T00:00:00.000Z | 1           |
| 2021-01-15T00:00:00.000Z | 1           |

---
**Query #2 - What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**

    SELECT 
      runner_id, 
      AVG(TIMESTAMPTZ(pickup_time) - TIMESTAMPTZ(order_time)) as avg_minutes_to_pickup 
    FROM pizza_runner.runner_orders as ro 
    INNER JOIN pizza_runner.customer_orders as co on ro.order_id = co.order_id 
    WHERE pickup_time <> 'null' 
    GROUP BY runner_id
    ORDER BY runner_id;

| runner_id | avg_minutes_to_pickup |
| --------- | --------------------- |
| 1         | [object Object]       |
| 2         | [object Object]       |
| 3         | [object Object]       |

---
**Query #3 - Is there any relationship between the number of pizzas and how long the order takes to prepare?**

    WITH CTE AS(
    SELECT c.order_id,COUNT(c.order_id) as num_of_pizzas 
    ,MAX(TIMESTAMPTZ(pickup_time) - TIMESTAMPTZ(order_time)) AS prep_time_minutes
    FROM pizza_runner.customer_orders c
    JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
    WHERE r.pickup_time!='null' 
    GROUP BY c.order_id
    ORDER BY c.order_id
    )
    SELECT num_of_pizzas,AVG(prep_time_minutes) FROM CTE
    GROUP BY num_of_pizzas
    ORDER BY num_of_pizzas;

| num_of_pizzas | avg             |
| ------------- | --------------- |
| 1             | [object Object] |
| 2             | [object Object] |
| 3             | [object Object] |

---
**Query #4 - What was the average distance travelled for each customer?**

    SELECT 
      customer_id, 
      ROUND(AVG(REPLACE(distance, 'km', ''):: numeric(3, 1)),2) as avg_distance_travelled 
    FROM pizza_runner.runner_orders as r 
    INNER JOIN pizza_runner.customer_orders as c on r.order_id = c.order_id 
    WHERE distance != 'null' 
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | avg_distance_travelled |
| ----------- | ---------------------- |
| 101         | 20.00                  |
| 102         | 16.73                  |
| 103         | 23.40                  |
| 104         | 10.00                  |
| 105         | 25.00                  |

---
**Query #5 - What was the difference between the longest and shortest delivery times for all orders?**

    SELECT 
      MAX(CAST(regexp_replace(duration, '\D', '', 'g') AS INTEGER)) - 	         	MIN(CAST(regexp_replace(duration, '\D', '', 'g') AS INTEGER)) as delivery_time_difference 
    FROM  pizza_runner.runner_orders 
    WHERE duration != 'null' ;

| delivery_time_difference |
| ------------------------ |
| 30                       |

---
**Query #6 - What was the average speed for each runner for each delivery and do you notice any trend for these values?**

    SELECT 
      runner_id, 
      order_id, 
      ROUND(REPLACE(distance, 'km', '')::numeric(3, 1) / REGEXP_REPLACE(duration, '[^0-9]', '','g')::numeric(3, 1),2) as speed_km_per_minute 
    FROM pizza_runner.runner_orders 
    WHERE duration != 'null' 
    ORDER BY runner_id, order_id;

| runner_id | order_id | speed_km_per_minute |
| --------- | -------- | ------------------- |
| 1         | 1        | 0.63                |
| 1         | 2        | 0.74                |
| 1         | 3        | 0.67                |
| 1         | 10       | 1.00                |
| 2         | 4        | 0.59                |
| 2         | 7        | 1.00                |
| 2         | 8        | 1.56                |
| 3         | 5        | 0.67                |

---
**Query #7 - What is the successful delivery percentage for each runner?**

    SELECT runner_id,
    	ROUND(SUM(CASE WHEN distance='null' THEN 0 ELSE 1 END)*100/COUNT(*),2) as delivery_percentage FROM pizza_runner.runner_orders
    GROUP BY runner_id
    ORDER BY runner_id;

| runner_id | delivery_percentage |
| --------- | ------------------- |
| 1         | 100.00              |
| 2         | 75.00               |
| 3         | 50.00               |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
