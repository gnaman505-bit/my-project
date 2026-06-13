
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;


SELECT
    r.region_name,
    COUNT(DISTINCT c.node_id) AS number_of_nodes
FROM customer_nodes c
JOIN regions r
ON c.region_id = r.region_id
GROUP BY r.region_name;


SELECT
    r.region_name,
    COUNT(DISTINCT c.customer_id) AS customer_count
FROM customer_nodes c
JOIN regions r
ON c.region_id = r.region_id
GROUP BY r.region_name;


SELECT
    AVG(DATEDIFF(DAY,start_date,end_date)*1.0) AS avg_days
FROM customer_nodes
WHERE end_date <> '9999-12-31';



WITH realloc AS
(
    SELECT
        r.region_name,
        DATEDIFF(DAY,c.start_date,c.end_date) AS days_allocated
    FROM customer_nodes c
    JOIN regions r
    ON c.region_id=r.region_id
    WHERE c.end_date <> '9999-12-31'
)
SELECT DISTINCT
    region_name,

    PERCENTILE_CONT(0.5)
    WITHIN GROUP (ORDER BY days_allocated)
    OVER(PARTITION BY region_name) AS median,

    PERCENTILE_CONT(0.8)
    WITHIN GROUP (ORDER BY days_allocated)
    OVER(PARTITION BY region_name) AS percentile_80,

    PERCENTILE_CONT(0.95)
    WITHIN GROUP (ORDER BY days_allocated)
    OVER(PARTITION BY region_name) AS percentile_95
FROM realloc;




SELECT
    txn_type,
    COUNT(*) AS transaction_count,
    SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;



WITH deposits AS
(
    SELECT
        customer_id,
        COUNT(*) AS deposit_count,
        SUM(txn_amount) AS deposit_amount
    FROM customer_transactions
    WHERE txn_type='deposit'
    GROUP BY customer_id
)

SELECT
    AVG(CAST(deposit_count AS FLOAT)) AS avg_deposit_count,
    AVG(CAST(deposit_amount AS FLOAT)) AS avg_deposit_amount
FROM deposits;




WITH monthly_summary AS
(
    SELECT
        MONTH(txn_date) AS month_num,
        customer_id,

        SUM(CASE WHEN txn_type='deposit'
                 THEN 1 ELSE 0 END) AS deposits,

        SUM(CASE WHEN txn_type='purchase'
                 THEN 1 ELSE 0 END) AS purchases,

        SUM(CASE WHEN txn_type='withdrawal'
                 THEN 1 ELSE 0 END) AS withdrawals

    FROM customer_transactions
    GROUP BY MONTH(txn_date), customer_id
)
SELECT
    month_num,
    COUNT(customer_id) AS customer_count
FROM monthly_summary
WHERE deposits > 1
AND (purchases >=1 OR withdrawals >=1)
GROUP BY month_num
ORDER BY month_num;






