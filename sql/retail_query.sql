SELECT 
    region,
    category,
    ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct,
    ROUND(AVG(discount) * 100, 1) AS avg_discount_pct,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM orders
GROUP BY region, category
ORDER BY region, category;

WITH benchmark AS (
    SELECT 
        category,
        SUM(sales * discount) / SUM(sales) AS benchmark_discount_pct
    FROM orders
    WHERE region <> 'Central'
      AND category IN ('Furniture', 'Office Supplies')
    GROUP BY category
),
central_actual AS (
    SELECT 
        category,
        SUM(sales) AS central_sales,
        SUM(sales * discount) / SUM(sales) AS central_discount_pct
    FROM orders
    WHERE region = 'Central'
      AND category IN ('Furniture', 'Office Supplies')
    GROUP BY category
)
SELECT 
    c.category,
    ROUND(c.central_discount_pct * 100, 1) AS central_discount_pct,
    ROUND(b.benchmark_discount_pct * 100, 1) AS network_benchmark_pct,
    ROUND(c.central_sales, 0) AS central_sales,
    ROUND(c.central_sales * (c.central_discount_pct - b.benchmark_discount_pct), 0) AS estimated_profit_recovered
FROM central_actual c
JOIN benchmark b ON c.category = b.category;

SELECT 
    sub_category,
    ship_mode,
    COUNT(*) AS num_orders,
    ROUND(AVG(discount) * 100, 1) AS avg_discount_pct,
    ROUND(SUM(sales), 0) AS total_sales,
    ROUND(SUM(profit), 0) AS total_profit
FROM orders
WHERE region = 'Central'
  AND category IN ('Furniture', 'Office Supplies')
  AND discount > 0
GROUP BY sub_category, ship_mode
ORDER BY total_profit ASC;

SELECT 
    region,
    sub_category,
    COUNT(*) AS num_orders,
    ROUND(AVG(discount) * 100, 1) AS avg_discount_pct,
    ROUND(SUM(profit), 0) AS total_profit
FROM orders
WHERE sub_category = 'Binders'
GROUP BY region, sub_category
ORDER BY total_profit ASC;

WITH network_benchmark AS (
    SELECT 
        SUM(sales * discount) / SUM(sales) AS benchmark_discount_pct
    FROM orders
    WHERE sub_category = 'Binders'
      AND region <> 'Central'
),
central_binders AS (
    SELECT 
        SUM(sales) AS central_sales,
        SUM(sales * discount) / SUM(sales) AS central_discount_pct
    FROM orders
    WHERE sub_category = 'Binders'
      AND region = 'Central'
)
SELECT 
    ROUND(c.central_discount_pct * 100, 1) AS central_discount_pct,
    ROUND(b.benchmark_discount_pct * 100, 1) AS network_benchmark_pct,
    ROUND(c.central_sales, 0) AS central_sales,
    ROUND(c.central_sales * (c.central_discount_pct - b.benchmark_discount_pct), 0) AS estimated_profit_recovered
FROM central_binders c, network_benchmark b;

SELECT 
    o.sub_category,
    COUNT(DISTINCT o.order_id) AS returned_orders,
    SUM(o.profit) AS profit_lost_to_returns,
    SUM(o.sales) AS sales_lost_to_returns
FROM orders o
JOIN returns r ON o.order_id = r.order_id
GROUP BY o.sub_category
ORDER BY profit_lost_to_returns ASC;

SELECT 
    o.sub_category,
    SUM(o.profit) AS profit_before_shipping,
    SUM(s.shipping_cost_per_unit * o.quantity) AS total_shipping_cost,
    SUM(o.profit - (s.shipping_cost_per_unit * o.quantity)) AS profit_after_shipping
FROM orders o
JOIN shipping_rate s ON o.state = s.state
GROUP BY o.sub_category
ORDER BY profit_after_shipping ASC;


WITH yearly_category AS (
    SELECT 
        YEAR(order_date_clean) AS yr,
        category,
        SUM(sales) AS category_sales
    FROM orders
    GROUP BY yr, category
),
yearly_total AS (
    SELECT yr, SUM(category_sales) AS total_sales
    FROM yearly_category
    GROUP BY yr
)
SELECT 
    yc.yr,
    yc.category,
    ROUND(yc.category_sales, 0) AS category_sales,
    ROUND(yc.category_sales / yt.total_sales * 100, 1) AS pct_of_yearly_revenue,
    ROUND(
        yc.category_sales / yt.total_sales * 100 
        - LAG(yc.category_sales / yt.total_sales * 100) OVER (PARTITION BY yc.category ORDER BY yc.yr), 
        1
    ) AS change_vs_prior_year_pts
FROM yearly_category yc
JOIN yearly_total yt ON yc.yr = yt.yr
ORDER BY yc.category, yc.yr;