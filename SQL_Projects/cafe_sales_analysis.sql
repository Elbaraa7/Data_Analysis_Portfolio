-- EDA 

-- Total Revenue
SELECT 
    SUM(total_spent) AS total_revenue
FROM
    sales2
;

-- Total Transactions
SELECT 
    COUNT(DISTINCT transaction_id) AS total_transactions
FROM
    sales2
;

-- Average transaction amount
SELECT 
    ROUND(AVG(total_spent), 2) AS average_spent
FROM
    sales2
;

-- Total revenue and quantity by item
SELECT 
    item, SUM(total_spent) AS total_revenue, SUM(quantity) AS total_quantity
FROM
    sales2
WHERE
    item IS NOT NULL
GROUP BY item
ORDER BY total_revenue DESC
;

-- Revenue by month
SELECT 
    SUBSTRING(transaction_date, 1, 7) AS `month`,
    SUM(total_spent) AS monthly_revenue
FROM
    sales2
WHERE
    MONTH(transaction_date) IS NOT NULL
GROUP BY `month`
ORDER BY `month`
;

-- Revenue by location
SELECT 
    location, SUM(total_spent) AS location_revenue
FROM
    sales2
WHERE
    location IS NOT NULL
GROUP BY location
ORDER BY location_revenue DESC
;


-- Payment method analysis
SELECT 
    payment_method,
    COUNT(DISTINCT transaction_id) AS total_transactions,
    SUM(total_spent) AS total_revenue,
    ROUND(AVG(total_spent), 2) AS avg_transaction
FROM
    sales2
WHERE
    payment_method IS NOT NULL
GROUP BY payment_method
ORDER BY total_transactions DESC
;


-- Top 3 sold items by location
WITH top_item AS 
(
SELECT 
    location, item, SUM(quantity) AS item_quantity,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY SUM(quantity) DESC) AS ranking
FROM
    sales2
WHERE
    location IS NOT NULL
        AND item IS NOT NULL
GROUP BY location , item
ORDER BY location , item_quantity DESC
)
SELECT * FROM top_item
WHERE ranking < 4
;

-- Revenue by weekday
SELECT 
    DAYNAME(transaction_date) AS weekday,
    SUM(total_spent) AS total_revenue, 
    COUNT(*) AS total_transactions
FROM
    sales2
WHERE
    transaction_date IS NOT NULL
GROUP BY weekday
ORDER BY total_revenue DESC
;

-- Month-over-month growth analysis
SELECT 
    SUBSTRING(transaction_date, 1, 7) AS `month`,
    SUM(total_spent) AS total_revenue,
    ROUND(
        (SUM(total_spent) - LAG(SUM(total_spent)) OVER (ORDER BY SUBSTRING(transaction_date, 1, 7))) /
        LAG(SUM(total_spent)) OVER (ORDER BY SUBSTRING(transaction_date, 1, 7)) * 100,
        2
    ) AS mom_growth_percentage
FROM sales2
WHERE SUBSTRING(transaction_date, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY `month`;







