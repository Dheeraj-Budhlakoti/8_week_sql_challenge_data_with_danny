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

**C. Ingredient Optimisation**

**Query #1 - What are the standard ingredients for each pizza?**

    CREATE TEMPORARY TABLE temp_table AS
    SELECT pizza_id,unnest(string_to_array(toppings, ','))::integer AS separated_values
    FROM pizza_runner.pizza_recipes;

There are no results to be displayed.

---
**Query #2**

    SELECT topping_name, COUNT(DISTINCT pizza_id) as pizzas FROM temp_table te
    JOIN pizza_runner.pizza_toppings t
    ON te.separated_values=t.topping_id
    GROUP BY topping_name
    HAVING COUNT(DISTINCT pizza_id)>1;

| topping_name | pizzas |
| ------------ | ------ |
| Cheese       | 2      |
| Mushrooms    | 2      |

---
**Query #3 - toppings for both pizzas**

    SELECT pizza_id,string_agg(topping_name::text, ', ') AS toppings FROM temp_table te
    JOIN pizza_runner.pizza_toppings t
    ON te.separated_values=t.topping_id
    GROUP BY pizza_id
    ORDER BY pizza_id;

| pizza_id | toppings                                                              |
| -------- | --------------------------------------------------------------------- |
| 1        | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 2        | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce            |

---
**Query #4 - What was the most commonly added extra?**

    WITH temp_table1 AS
    (SELECT unnest(string_to_array(extras, ','))::integer AS separated_values
    FROM pizza_runner.customer_orders
    WHERE extras IS NOT NULL AND extras!='null' AND extras!='')
    
    SELECT topping_name,COUNT(topping_name) as times_added FROM temp_table1 te
    JOIN pizza_runner.pizza_toppings top ON te.separated_values=top.topping_id
    GROUP BY topping_name
    ORDER BY times_added DESC;

| topping_name | times_added |
| ------------ | ----------- |
| Bacon        | 4           |
| Chicken      | 1           |
| Cheese       | 1           |

---
**Query #5 - What was the most common exclusion?**

    WITH temp_table2 AS
    (SELECT unnest(string_to_array(exclusions, ','))::integer AS separated_values
    FROM pizza_runner.customer_orders
    WHERE exclusions!='null' AND exclusions!='')
    
    SELECT topping_name,COUNT(topping_name) as times_excluded FROM temp_table2 te
    JOIN pizza_runner.pizza_toppings top ON te.separated_values=top.topping_id
    GROUP BY topping_name
    ORDER BY times_excluded DESC;

| topping_name | times_excluded |
| ------------ | -------------- |
| Cheese       | 4              |
| Mushrooms    | 1              |
| BBQ Sauce    | 1              |

---
**Query #6 - Generate an order item for each record in the customers_orders table in the format of one of the following:**

**-- Meat Lovers**

**-- Meat Lovers - Exclude Beef**

**-- Meat Lovers - Extra Bacon**

**-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers**

    SELECT order_id,customer_id,pizza_name FROM pizza_runner.customer_orders c
    JOIN pizza_runner.pizza_names n on c.pizza_id=n.pizza_id
    ORDER BY order_id;

| order_id | customer_id | pizza_name |
| -------- | ----------- | ---------- |
| 1        | 101         | Meatlovers |
| 2        | 101         | Meatlovers |
| 3        | 102         | Meatlovers |
| 3        | 102         | Vegetarian |
| 4        | 103         | Vegetarian |
| 4        | 103         | Meatlovers |
| 4        | 103         | Meatlovers |
| 5        | 104         | Meatlovers |
| 6        | 101         | Vegetarian |
| 7        | 105         | Vegetarian |
| 8        | 102         | Meatlovers |
| 9        | 103         | Meatlovers |
| 10       | 104         | Meatlovers |
| 10       | 104         | Meatlovers |

---
**Query #7**

    CREATE TEMPORARY TABLE temp_table3 AS
    SELECT
      order_id,
      customer_id,
      pizza_id,
      CASE
        WHEN exclusions IS NOT NULL AND exclusions != 'null' AND exclusions != '' THEN unnested_values.separated_values::integer
        ELSE NULL
      END AS separated_values
    FROM
      pizza_runner.customer_orders
    LEFT JOIN LATERAL unnest(string_to_array(coalesce(exclusions, ''), ',')) AS unnested_values(separated_values) ON true;

There are no results to be displayed.

---
**Query #8**

    SELECT order_id, customer_id, string_agg(topping_name::text, ', ') AS toppings FROM temp_table3 ta
    LEFT JOIN pizza_runner.pizza_toppings top on ta.separated_values=top.topping_id
    GROUP BY order_id, customer_id
    ORDER BY order_id;

| order_id | customer_id | toppings               |
| -------- | ----------- | ---------------------- |
| 1        | 101         |                        |
| 2        | 101         |                        |
| 3        | 102         |                        |
| 4        | 103         | Cheese, Cheese, Cheese |
| 5        | 104         |                        |
| 6        | 101         |                        |
| 7        | 105         |                        |
| 8        | 102         |                        |
| 9        | 103         | Cheese                 |
| 10       | 104         | BBQ Sauce, Mushrooms   |

---

**-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**
[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
