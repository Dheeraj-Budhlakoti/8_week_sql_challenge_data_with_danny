# Solution A. Pizza Metrics #

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

**Query #1 - How many pizzas were ordered?**

    SELECT COUNT(*) as total_pizzas_ordered FROM pizza_runner.customer_orders;

| total_pizzas_ordered |
| -------------------- |
| 14                   |

---
**Query #2 - How many unique customer orders were made?**

    SELECT COUNT(DISTINCT order_id) as unique_orders FROM pizza_runner.customer_orders;

| unique_orders |
| ------------- |
| 10            |

---
**Query #3 - How many successful orders were delivered by each runner?**

    SELECT runner_id,COUNT(order_id) as successful_orders FROM pizza_runner.runner_orders
    WHERE pickup_time!='null'
    GROUP BY runner_id
    ORDER BY runner_id;

| runner_id | successful_orders |
| --------- | ----------------- |
| 1         | 4                 |
| 2         | 3                 |
| 3         | 1                 |

---
**Query #4 - How many of each type of pizza was delivered?**

    SELECT p.pizza_name,COUNT(c.pizza_id) as pizzas_deliverred FROM pizza_runner.pizza_names p
    JOIN pizza_runner.customer_orders c ON p.pizza_id=c.pizza_id
    JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
    WHERE r.pickup_time!='null'
    GROUP BY p.pizza_name;

| pizza_name | pizzas_deliverred |
| ---------- | ----------------- |
| Meatlovers | 9                 |
| Vegetarian | 3                 |

---
**Query #5 - How many Vegetarian and Meatlovers were ordered by each customer?**

    SELECT customer_id,
    SUM(CASE WHEN pizza_id=1 THEN 1 ELSE 0 END) as Meat_Lovers,
    SUM(CASE WHEN pizza_id=2 THEN 1 ELSE 0 END) as Vegetarian
    FROM pizza_runner.customer_orders
    GROUP BY customer_id
    ORDER BY customer_id;

| customer_id | meat_lovers | vegetarian |
| ----------- | ----------- | ---------- |
| 101         | 2           | 1          |
| 102         | 2           | 1          |
| 103         | 3           | 1          |
| 104         | 3           | 0          |
| 105         | 0           | 1          |

---
**Query #6 - What was the maximum number of pizzas delivered in a single order?**

    WITH CTE AS(
    	SELECT c.order_id,COUNT(c.pizza_id) FROM pizza_runner.customer_orders c
      	JOIN pizza_runner.runner_orders r on c.order_id=r.order_id
      	WHERE pickup_time!='null'
      	GROUP BY c.order_id
    )
    SELECT MAX(count) as max_pizza_num FROM CTE;

| max_pizza_num |
| ------------- |
| 3             |

---
**Query #7 - For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

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

| customer_id | changes | no_changes |
| ----------- | ------- | ---------- |
| 101         | 0       | 2          |
| 102         | 0       | 3          |
| 103         | 3       | 0          |
| 104         | 2       | 1          |
| 105         | 1       | 0          |

---
**Query #8 - How many pizzas were delivered that had both exclusions and extras?**

    SELECT COUNT(c.order_id) as pizzas_with_both_exclusions_and_extras FROM pizza_runner.customer_orders c
    JOIN pizza_runner.runner_orders r ON c.order_id=r.order_id
    WHERE pickup_time!='null'
    AND exclusions IS NOT NULL AND exclusions!='null' AND LENGTH(exclusions)>0
    and extras IS NOT NULL AND extras!='null' AND LENGTH(extras)>0;

| pizzas_with_both_exclusions_and_extras |
| -------------------------------------- |
| 1                                      |

---
**Query #9 - What was the total volume of pizzas ordered for each hour of the day?**

    SELECT DATE_PART('hour', order_time) as Hour, COUNT(*) as pizza_volume FROM pizza_runner.customer_orders
    GROUP BY Hour
    ORDER BY Hour;

| hour | pizza_volume |
| ---- | ------------ |
| 11   | 1            |
| 13   | 3            |
| 18   | 3            |
| 19   | 1            |
| 21   | 3            |
| 23   | 3            |

---
**Query #10 - What was the volume of orders for each day of the week?**

    SELECT to_char( order_time , 'Day' ) as day, COUNT(*) as pizza_volume FROM pizza_runner.customer_orders
    GROUP BY day
    ORDER BY day;

| day       | pizza_volume |
| --------- | ------------ |
| Friday    | 1            |
| Saturday  | 5            |
| Thursday  | 3            |
| Wednesday | 5            |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
