-- Top 5 customers by spending
SELECT c.customer_unique_id, SUM(p.payment_value) AS total_spendings
FROM customers As c
INNER JOIN orders AS o ON o.customer_id = c.customer_id
INNER JOIN payments AS p ON  p.order_id = o.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spendings DESC
LIMIT 5;

-- Top 5 product categories by revenue
SELECT c.product_category_name_english, ROUND(SUM(o.price)::NUMERIC, 2) AS total_revenue      
FROM category_translation AS c
INNER JOIN products AS p ON p.product_category_name = c.product_category_name
INNER JOIN order_items AS o ON o.product_id = p.product_id
GROUP BY c.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 5;

-- Monthly revenue trend --
SELECT TO_CHAR(orders.order_purchase_timestamp, 'Mon YYYY') AS month, 	ROUND(SUM(payments.payment_value)::NUMERIC, 2) AS monthly_revenue
FROM orders
INNER JOIN payments ON payments.order_id = orders.order_id
GROUP BY month
ORDER BY MIN(orders.order_purchase_timestamp);

-- Customers with more than 1 order --
SELECT customer_unique_id, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
HAVING COUNT(o.order_id) > 1;