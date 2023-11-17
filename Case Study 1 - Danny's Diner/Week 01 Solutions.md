**Schema (PostgreSQL v13)**

    CREATE SCHEMA dannys_diner;
    SET search_path = dannys_diner;
    
    CREATE TABLE sales (
      "customer_id" VARCHAR(1),
      "order_date" DATE,
      "product_id" INTEGER
    );
    
    INSERT INTO sales
      ("customer_id", "order_date", "product_id")
    VALUES
      ('A', '2021-01-01', '1'),
      ('A', '2021-01-01', '2'),
      ('A', '2021-01-07', '2'),
      ('A', '2021-01-10', '3'),
      ('A', '2021-01-11', '3'),
      ('A', '2021-01-11', '3'),
      ('B', '2021-01-01', '2'),
      ('B', '2021-01-02', '2'),
      ('B', '2021-01-04', '1'),
      ('B', '2021-01-11', '1'),
      ('B', '2021-01-16', '3'),
      ('B', '2021-02-01', '3'),
      ('C', '2021-01-01', '3'),
      ('C', '2021-01-01', '3'),
      ('C', '2021-01-07', '3');
     
    
    CREATE TABLE menu (
      "product_id" INTEGER,
      "product_name" VARCHAR(5),
      "price" INTEGER
    );
    
    INSERT INTO menu
      ("product_id", "product_name", "price")
    VALUES
      ('1', 'sushi', '10'),
      ('2', 'curry', '15'),
      ('3', 'ramen', '12');
      
    
    CREATE TABLE members (
      "customer_id" VARCHAR(1),
      "join_date" DATE
    );
    
    INSERT INTO members
      ("customer_id", "join_date")
    VALUES
      ('A', '2021-01-07'),
      ('B', '2021-01-09');

---
### Case Study Questions
---
**Query #1 - What is the total amount each customer spent at the restaurant?**

    SELECT S.customer_id,SUM(M.price) as amount_spent FROM dannys_diner.sales S
    JOIN dannys_diner.menu M on S.product_id=M.product_id
    GROUP BY S.customer_id
    ORDER BY S.customer_id;

| customer_id | amount_spent |
| ----------- | ------------ |
| A           | 76           |
| B           | 74           |
| C           | 36           |

---
**Query #2 - How many days has each customer visited the restaurant?**

    SELECT customer_id, COUNT(DISTINCT order_date) as days_visited FROM dannys_diner.sales
    GROUP BY customer_id;

| customer_id | days_visited |
| ----------- | ------------ |
| A           | 4            |
| B           | 6            |
| C           | 2            |

---
**Query #3 - What was the first item from the menu purchased by each customer?**

    WITH CTE AS
    (
    	SELECT *,
      RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as rnk
      FROM dannys_diner.sales
    )
    SELECT C.customer_id,M.product_name FROM CTE C
    JOIN dannys_diner.menu M ON C.product_id=M.product_id
    WHERE rnk=1
    GROUP BY C.customer_id,M.product_name
    ORDER BY C.customer_id;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---
**Query #4 - What is the most purchased item on the menu and how many times was it purchased by all customers?**

    SELECT M.product_name,COUNT(S.product_id) as times_purchased FROM dannys_diner.sales S
    JOIN dannys_diner.menu M ON S.product_id=M.product_id
    GROUP BY M.product_name
    ORDER BY times_purchased DESC
    LIMIT 1;

| product_name | times_purchased |
| ------------ | --------------- |
| ramen        | 8               |

---
**Query #5 - Which item was the most popular for each customer?**

    WITH CTE AS
    (
    	SELECT S.customer_id,M.product_name,COUNT(M.product_name) AS order_count,
    	RANK() OVER(PARTITION BY S.customer_id ORDER BY COUNT(M.product_name) DESC) AS rnk
    	FROM dannys_diner.sales S
    	JOIN dannys_diner.menu M on S.product_id=M.product_id
    	GROUP BY S.customer_id,M.product_name
    )
    SELECT customer_id,product_name,order_count FROM CTE
    WHERE rnk=1;

| customer_id | product_name | order_count |
| ----------- | ------------ | ----------- |
| A           | ramen        | 3           |
| B           | ramen        | 2           |
| B           | curry        | 2           |
| B           | sushi        | 2           |
| C           | ramen        | 3           |

---
**Query #6 - Which item was purchased first by the customer after they became a member?**

    WITH CTE AS
    (
    	SELECT S.customer_id,S.product_id,
      	RANK() OVER(PARTITION BY S.customer_id ORDER BY S.order_date) as rnk
      	FROM dannys_diner.sales S
      	JOIN dannys_diner.members M on S.customer_id=M.customer_id
      	AND M.join_date<=S.order_date
    )
    SELECT C.customer_id,ME.product_name FROM CTE C
    JOIN dannys_diner.menu ME on C.product_id=ME.product_id
    WHERE rnk=1
    ORDER BY C.customer_id;

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| B           | sushi        |

---
**Query #7 - Which item was purchased just before the customer became a member?**

    WITH CTE AS
    (
    	SELECT S.customer_id,S.product_id,
      	ROW_NUMBER() OVER(PARTITION BY S.customer_id ORDER BY S.order_date DESC) as rnk
      	FROM dannys_diner.sales S
      	JOIN dannys_diner.members M on S.customer_id=M.customer_id
      	AND M.join_date>S.order_date
    )
    SELECT C.customer_id,ME.product_name FROM CTE C
    JOIN dannys_diner.menu ME on C.product_id=ME.product_id
    WHERE rnk=1
    ORDER BY C.customer_id;

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | sushi        |

---
**Query #8 - What is the total items and amount spent for each member before they became a member?**

    SELECT S.customer_id,COUNT(S.product_id) AS total_items,SUM(M.price) AS amount_spent FROM dannys_diner.sales S
    JOIN dannys_diner.menu M on S.product_id=M.product_id
    JOIN dannys_diner.members ME on S.customer_id=ME.customer_id
    AND S.order_date<ME.join_date
    GROUP BY S.customer_id
    ORDER BY S.customer_id;

| customer_id | total_items | amount_spent |
| ----------- | ----------- | ------------ |
| A           | 2           | 25           |
| B           | 3           | 40           |

---
**Query #9 - If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

    SELECT S.customer_id,
    SUM(
    	CASE WHEN M.product_name='sushi' THEN price*20 ELSE price*10 END
    ) as points
    FROM dannys_diner.sales S
    JOIN dannys_diner.menu M ON S.product_id=M.product_id
    GROUP BY S.customer_id
    ORDER BY S.customer_id;

| customer_id | points |
| ----------- | ------ |
| A           | 860    |
| B           | 940    |
| C           | 360    |

---
**Query #10 - In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

    SELECT S.customer_id,
    SUM(CASE 
        WHEN S.order_date BETWEEN M.join_date AND M.join_date+6 THEN ME.price*20
        WHEN ME.product_name='sushi' THEN ME.price*20
        ELSE price*10
        END
       ) as points
    FROM dannys_diner.sales S
    JOIN dannys_diner.menu ME ON S.product_id=ME.product_id
    JOIN dannys_diner.members M ON S.customer_id=M.customer_id
    WHERE S.order_date<'2021-02-01'
    GROUP BY S.customer_id;

| customer_id | points |
| ----------- | ------ |
| A           | 1370   |
| B           | 820    |

---
### Bonus Questions
**Query #11 - Join All The Things**

    SELECT S.customer_id,S.order_date,S.product_id,M.product_name,M.price,
    CASE WHEN ME.join_date>S.order_date THEN 'N'
    	 WHEN ME.join_date IS NULL THEN 'N'
         ELSE 'Y'
         END AS member
    FROM dannys_diner.sales S
    JOIN dannys_diner.menu M on S.product_id=M.product_id
    LEFT JOIN dannys_diner.members ME on S.customer_id=ME.customer_id
    ORDER BY S.customer_id,S.order_date;

| customer_id | order_date               | product_id | product_name | price | member |
| ----------- | ------------------------ | ---------- | ------------ | ----- | ------ |
| A           | 2021-01-01T00:00:00.000Z | 1          | sushi        | 10    | N      |
| A           | 2021-01-01T00:00:00.000Z | 2          | curry        | 15    | N      |
| A           | 2021-01-07T00:00:00.000Z | 2          | curry        | 15    | Y      |
| A           | 2021-01-10T00:00:00.000Z | 3          | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | 3          | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | 3          | ramen        | 12    | Y      |
| B           | 2021-01-01T00:00:00.000Z | 2          | curry        | 15    | N      |
| B           | 2021-01-02T00:00:00.000Z | 2          | curry        | 15    | N      |
| B           | 2021-01-04T00:00:00.000Z | 1          | sushi        | 10    | N      |
| B           | 2021-01-11T00:00:00.000Z | 1          | sushi        | 10    | Y      |
| B           | 2021-01-16T00:00:00.000Z | 3          | ramen        | 12    | Y      |
| B           | 2021-02-01T00:00:00.000Z | 3          | ramen        | 12    | Y      |
| C           | 2021-01-01T00:00:00.000Z | 3          | ramen        | 12    | N      |
| C           | 2021-01-01T00:00:00.000Z | 3          | ramen        | 12    | N      |
| C           | 2021-01-07T00:00:00.000Z | 3          | ramen        | 12    | N      |

---
**Query #12 - Rank All The Things**

    WITH CTE AS
    (
    	SELECT S.customer_id,S.order_date,S.product_id,M.product_name,M.price,
    	CASE WHEN ME.join_date>S.order_date THEN 'N'
    	 	 WHEN ME.join_date IS NULL THEN 'N'
             ELSE 'Y'
             END AS member
    	FROM dannys_diner.sales S
    	JOIN dannys_diner.menu M on S.product_id=M.product_id
    	LEFT JOIN dannys_diner.members ME on S.customer_id=ME.customer_id
    	ORDER BY S.customer_id,S.order_date	
    )
    SELECT *,
    	CASE WHEN member='N' THEN NULL
        ELSE RANK() OVER(PARTITION BY customer_id,member ORDER BY order_date)
        END AS ranking
    FROM CTE;

| customer_id | order_date               | product_id | product_name | price | member | ranking |
| ----------- | ------------------------ | ---------- | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01T00:00:00.000Z | 1          | sushi        | 10    | N      |         |
| A           | 2021-01-01T00:00:00.000Z | 2          | curry        | 15    | N      |         |
| A           | 2021-01-07T00:00:00.000Z | 2          | curry        | 15    | Y      | 1       |
| A           | 2021-01-10T00:00:00.000Z | 3          | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11T00:00:00.000Z | 3          | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11T00:00:00.000Z | 3          | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01T00:00:00.000Z | 2          | curry        | 15    | N      |         |
| B           | 2021-01-02T00:00:00.000Z | 2          | curry        | 15    | N      |         |
| B           | 2021-01-04T00:00:00.000Z | 1          | sushi        | 10    | N      |         |
| B           | 2021-01-11T00:00:00.000Z | 1          | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16T00:00:00.000Z | 3          | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01T00:00:00.000Z | 3          | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01T00:00:00.000Z | 3          | ramen        | 12    | N      |         |
| C           | 2021-01-01T00:00:00.000Z | 3          | ramen        | 12    | N      |         |
| C           | 2021-01-07T00:00:00.000Z | 3          | ramen        | 12    | N      |         |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138)
