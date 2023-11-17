# Case Study #2 - Pizza Runner

![Logo](https://8weeksqlchallenge.com/images/case-study-designs/2.png)

[Link to webpage](https://8weeksqlchallenge.com/case-study-2/)

## Introduction

Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Available Data

Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

All datasets exist within the *pizza_runner* database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

## Entity Relationship Diagram

![Schema](https://github.com/Dheeraj-Budhlakoti/8_week_sql_challenge_data_with_danny/assets/122223189/3094d7fc-ab81-41c8-8e6d-d2c8dd7cb49f)

### Table 1: runners

The *runners* table shows the *registration_date* for each new runner

<table>
  <thead>
    <tr>
      <th>runner_id</th>
      <th>registration_date</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>1</td>
      <td>2021-01-01</td>
    </tr>
    <tr>
      <td>2</td>
      <td>2021-01-03</td>
    </tr>
    <tr>
      <td>3</td>
      <td>2021-01-08</td>
    </tr>
    <tr>
      <td>4</td>
      <td>2021-01-15</td>
    </tr>
  </tbody>
</table>

### Table 2: customer_orders

Customer pizza orders are captured in the *customer_orders* table with 1 row for each individual pizza that is part of the order.

The *pizza_id* relates to the type of pizza which was ordered whilst the *exclusions* are the *ingredient_id* values which should be removed from the pizza and the *extras* are the *ingredient_id* values which need to be added to the pizza.

Note that customers can order multiple pizzas in a single order with varying *exclusions* and *extras* values even if the pizza is the same type!

The *exclusions* and *extras* columns will need to be cleaned up before using them in your queries.

  <table>
    <thead>
      <tr>
        <th>order_id</th>
        <th>customer_id</th>
        <th>pizza_id</th>
        <th>exclusions</th>
        <th>extras</th>
        <th>order_time</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>1</td>
        <td>101</td>
        <td>1</td>
        <td> </td>
        <td> </td>
        <td>2021-01-01 18:05:02</td>
      </tr>
      <tr>
        <td>2</td>
        <td>101</td>
        <td>1</td>
        <td> </td>
        <td> </td>
        <td>2021-01-01 19:00:52</td>
      </tr>
      <tr>
        <td>3</td>
        <td>102</td>
        <td>1</td>
        <td> </td>
        <td> </td>
        <td>2021-01-02 23:51:23</td>
      </tr>
      <tr>
        <td>3</td>
        <td>102</td>
        <td>2</td>
        <td> </td>
        <td>NaN</td>
        <td>2021-01-02 23:51:23</td>
      </tr>
      <tr>
        <td>4</td>
        <td>103</td>
        <td>1</td>
        <td>4</td>
        <td> </td>
        <td>2021-01-04 13:23:46</td>
      </tr>
      <tr>
        <td>4</td>
        <td>103</td>
        <td>1</td>
        <td>4</td>
        <td> </td>
        <td>2021-01-04 13:23:46</td>
      </tr>
      <tr>
        <td>4</td>
        <td>103</td>
        <td>2</td>
        <td>4</td>
        <td> </td>
        <td>2021-01-04 13:23:46</td>
      </tr>
      <tr>
        <td>5</td>
        <td>104</td>
        <td>1</td>
        <td>null</td>
        <td>1</td>
        <td>2021-01-08 21:00:29</td>
      </tr>
      <tr>
        <td>6</td>
        <td>101</td>
        <td>2</td>
        <td>null</td>
        <td>null</td>
        <td>2021-01-08 21:03:13</td>
      </tr>
      <tr>
        <td>7</td>
        <td>105</td>
        <td>2</td>
        <td>null</td>
        <td>1</td>
        <td>2021-01-08 21:20:29</td>
      </tr>
      <tr>
        <td>8</td>
        <td>102</td>
        <td>1</td>
        <td>null</td>
        <td>null</td>
        <td>2021-01-09 23:54:33</td>
      </tr>
      <tr>
        <td>9</td>
        <td>103</td>
        <td>1</td>
        <td>4</td>
        <td>1, 5</td>
        <td>2021-01-10 11:22:59</td>
      </tr>
      <tr>
        <td>10</td>
        <td>104</td>
        <td>1</td>
        <td>null</td>
        <td>null</td>
        <td>2021-01-11 18:34:49</td>
      </tr>
      <tr>
        <td>10</td>
        <td>104</td>
        <td>1</td>
        <td>2, 6</td>
        <td>1, 4</td>
        <td>2021-01-11 18:34:49</td>
      </tr>
    </tbody>
  </table>

### Table 3: runner_orders

After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.

The *pickup_time* is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The *distance* and *duration* fields are related to how far and long the runner had to travel to deliver the order to the respective customer.

There are some known data issues with this table so be careful when using this in your queries - make sure to check the data types for each column in the schema SQL!

  <table>
    <thead>
      <tr>
        <th>order_id</th>
        <th>runner_id</th>
        <th>pickup_time</th>
        <th>distance</th>
        <th>duration</th>
        <th>cancellation</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>1</td>
        <td>1</td>
        <td>2021-01-01 18:15:34</td>
        <td>20km</td>
        <td>32 minutes</td>
        <td> </td>
      </tr>
      <tr>
        <td>2</td>
        <td>1</td>
        <td>2021-01-01 19:10:54</td>
        <td>20km</td>
        <td>27 minutes</td>
        <td> </td>
      </tr>
      <tr>
        <td>3</td>
        <td>1</td>
        <td>2021-01-03 00:12:37</td>
        <td>13.4km</td>
        <td>20 mins</td>
        <td>NaN</td>
      </tr>
      <tr>
        <td>4</td>
        <td>2</td>
        <td>2021-01-04 13:53:03</td>
        <td>23.4</td>
        <td>40</td>
        <td>NaN</td>
      </tr>
      <tr>
        <td>5</td>
        <td>3</td>
        <td>2021-01-08 21:10:57</td>
        <td>10</td>
        <td>15</td>
        <td>NaN</td>
      </tr>
      <tr>
        <td>6</td>
        <td>3</td>
        <td>null</td>
        <td>null</td>
        <td>null</td>
        <td>Restaurant Cancellation</td>
      </tr>
      <tr>
        <td>7</td>
        <td>2</td>
        <td>2020-01-08 21:30:45</td>
        <td>25km</td>
        <td>25mins</td>
        <td>null</td>
      </tr>
      <tr>
        <td>8</td>
        <td>2</td>
        <td>2020-01-10 00:15:02</td>
        <td>23.4 km</td>
        <td>15 minute</td>
        <td>null</td>
      </tr>
      <tr>
        <td>9</td>
        <td>2</td>
        <td>null</td>
        <td>null</td>
        <td>null</td>
        <td>Customer Cancellation</td>
      </tr>
      <tr>
        <td>10</td>
        <td>1</td>
        <td>2020-01-11 18:50:20</td>
        <td>10km</td>
        <td>10minutes</td>
        <td>null</td>
      </tr>
    </tbody>
  </table>

### Table 4: pizza_names

At the moment - Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!

  <table>
    <thead>
      <tr>
        <th>pizza_id</th>
        <th>pizza_name</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>1</td>
        <td>Meat Lovers</td>
      </tr>
      <tr>
        <td>2</td>
        <td>Vegetarian</td>
      </tr>
    </tbody>
  </table>

### Table 5: pizza_recipes

Each *pizza_id* has a standard set of *toppings* which are used as part of the pizza recipe.

  <table>
    <thead>
      <tr>
        <th>pizza_id</th>
        <th>toppings</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>1</td>
        <td>1, 2, 3, 4, 5, 6, 8, 10</td>
      </tr>
      <tr>
        <td>2</td>
        <td>4, 6, 7, 9, 11, 12</td>
      </tr>
    </tbody>
  </table>

### Table 6: pizza_toppings

This table contains all of the *topping_name* values with their corresponding *topping_id* value.

<table>
    <thead>
      <tr>
        <th>topping_id</th>
        <th>topping_name</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>1</td>
        <td>Bacon</td>
      </tr>
      <tr>
        <td>2</td>
        <td>BBQ Sauce</td>
      </tr>
      <tr>
        <td>3</td>
        <td>Beef</td>
      </tr>
      <tr>
        <td>4</td>
        <td>Cheese</td>
      </tr>
      <tr>
        <td>5</td>
        <td>Chicken</td>
      </tr>
      <tr>
        <td>6</td>
        <td>Mushrooms</td>
      </tr>
      <tr>
        <td>7</td>
        <td>Onions</td>
      </tr>
      <tr>
        <td>8</td>
        <td>Pepperoni</td>
      </tr>
      <tr>
        <td>9</td>
        <td>Peppers</td>
      </tr>
      <tr>
        <td>10</td>
        <td>Salami</td>
      </tr>
      <tr>
        <td>11</td>
        <td>Tomatoes</td>
      </tr>
      <tr>
        <td>12</td>
        <td>Tomato Sauce</td>
      </tr>
    </tbody>
  </table>

## Case Study Questions

This case study has **LOTS** of questions - they are broken up by area of focus including:

* Pizza Metrics
* Runner and Customer Experience
* Ingredient Optimisation
* Pricing and Ratings
* Bonus DML Challenges (DML = Data Manipulation Language)

Each of the following case study questions can be answered using a single SQL statement.

Again, there are many questions in this case study - please feel free to pick and choose which ones you’d like to try!

Before you start writing your SQL queries however - you might want to investigate the data, you may want to do something with some of those *null* values and data types in the *customer_orders* and *runner_orders* tables!

## A. Pizza Metrics
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

You can find the solution [here](https://github.com/Dheeraj-Budhlakoti/8_week_sql_challenge_data_with_danny/blob/main/Case%20Study%202%20-%20Pizza%20Runner/Week%2002_A%20Solutions.md)

## B. Runner and Customer Experience

1. How many runners signed up for each 1 week period? (i.e. week starts *2021-01-01*)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

## C. Ingredient Optimisation

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the *customers_orders* table in the format of one of the following:
* *Meat Lovers*
* *Meat Lovers - Exclude Beef*
* *Meat Lovers - Extra Bacon*
* *Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the *customer_orders* table and add a *2x* in front of any relevant ingredients
* For example: *"Meat Lovers: 2xBacon, Beef, ... , Salami"*
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

## D. Pricing and Ratings

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
* Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
* *customer_id*
* *order_id*
* *runner_id*
* *rating*
* *order_time*
* *pickup_time*
* Time between order and pickup
* Delivery duration
* Average speed
* Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
  
## E. Bonus Questions
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an *INSERT* statement to demonstrate what would happen if a new *Supreme* pizza with all the toppings was added to the Pizza Runner menu?

## Conclusion

Week 02 Completed! I'd like to extend my appreciation to Danny Ma for creating this fantastic challenge and providing a platform for SQL enthusiasts to enhance their skills. In this repository, you'll find my detailed solutions for Week 02, which include SQL queries. Feel free to explore these solutions to see how I approached the tasks, and use them as a reference for your own learning journey.
If you have any questions or feedback about my Week 02 solutions, please don't hesitate to reach out. I'm open to constructive criticism and eager to engage in discussions about SQL and data analysis.

Ready for the next 8 Week SQL challenge case study? Click [here](https://github.com/Dheeraj-Budhlakoti/8_week_sql_challenge_data_with_danny/tree/main/Case%20Study%203%20-%20Foodie-Fi) to get started with case study #3!
