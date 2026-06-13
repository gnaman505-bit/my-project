use msdb;
SELECT TOP 1
    m.product_name,
    COUNT(*) AS purchase_count
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_count desc;

WITH item_counts AS
(
    SELECT
        s.customer_id,
        m.product_name,
        COUNT(*) AS total_orders,
        ROW_NUMBER() OVER
        (
            PARTITION BY s.customer_id
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM sales s
    JOIN menu m
    ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT
    customer_id,
    product_name,
    total_orders
FROM item_counts
WHERE rn = 1;









