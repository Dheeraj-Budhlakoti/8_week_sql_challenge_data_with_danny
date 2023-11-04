/* -------------------- Case Study Questions --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT S.customer_id,SUM(M.price) as amount_spent FROM dannys_diner.sales S
JOIN dannys_diner.menu M on S.product_id=M.product_id
GROUP BY S.customer_id
ORDER BY S.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) as days_visited FROM dannys_diner.sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

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

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT M.product_name,COUNT(S.product_id) as times_purchased FROM dannys_diner.sales S
JOIN dannys_diner.menu M ON S.product_id=M.product_id
GROUP BY M.product_name
ORDER BY times_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

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

-- 6. Which item was purchased first by the customer after they became a member?

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

-- 7. Which item was purchased just before the customer became a member?

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

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT S.customer_id,COUNT(S.product_id) AS total_items,SUM(M.price) AS amount_spent FROM dannys_diner.sales S
JOIN dannys_diner.menu M on S.product_id=M.product_id
JOIN dannys_diner.members ME on S.customer_id=ME.customer_id
AND S.order_date<ME.join_date
GROUP BY S.customer_id
ORDER BY S.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT S.customer_id,
SUM(
	CASE WHEN M.product_name='sushi' THEN price*20 ELSE price*10 END
) as points
FROM dannys_diner.sales S
JOIN dannys_diner.menu M ON S.product_id=M.product_id
GROUP BY S.customer_id
ORDER BY S.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

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

-- Bonus Questions
  
-- Join All The Things

SELECT S.customer_id,S.order_date,S.product_id,M.product_name,M.price,
CASE WHEN ME.join_date>S.order_date THEN 'N'
	 WHEN ME.join_date IS NULL THEN 'N'
     ELSE 'Y'
     END AS member
FROM dannys_diner.sales S
JOIN dannys_diner.menu M on S.product_id=M.product_id
LEFT JOIN dannys_diner.members ME on S.customer_id=ME.customer_id
ORDER BY S.customer_id,S.order_date;

-- Rank All The Things

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
