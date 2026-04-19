-- Step 1: Calculating total payment per order
WITH payment_per_order AS (
    SELECT 
        order_id, 
        SUM(payment_value) AS total_payment
    FROM payments
    GROUP BY order_id
    ),
-- Step 2: Building RFM base table
    rfm_base AS (
        SELECT 
            c.customer_unique_id, 
            MAX(o.order_purchase_timestamp) AS last_purchase_date, 
            COUNT(DISTINCT o.order_id) AS number_of_orders, 
            SUM(p.total_payment) AS total_spent,
            CURRENT_DATE - DATE(MAX(o.order_purchase_timestamp)) AS recency_days
        FROM customers AS c
        INNER JOIN orders AS o 
            ON o.customer_id = c.customer_id
        INNER JOIN payment_per_order AS p 
            ON p.order_id = o.order_id
        GROUP BY c.customer_unique_id
    ),
-- Step 3: Assigning RFM scores using NTILE
    rfm_scores AS(
    SELECT *,
        NTILE(5) OVER(ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER(ORDER BY number_of_orders DESC) AS f_score,
        NTILE(5) OVER(ORDER BY total_spent DESC) AS m_score
    FROM rfm_base
    )
-- Step 4: Creating RFM score and customer segments
    SELECT *, 
	r_score::text || f_score::text || m_score::text AS rfm_score,
    CASE 
        WHEN r_score = 5 AND f_score = 5 AND m_score = 5 THEN 'Champion'
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Loyal Customer'
        WHEN m_score = 5 THEN 'Big Spenders'
        WHEN r_score = 5 AND f_score <= 2 THEN 'New Customer'
        WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost Customer'
        ELSE 'Others'
    END AS customer_segment
    FROM rfm_scores