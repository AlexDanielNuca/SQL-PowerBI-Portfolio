drop table if exists retail_sales;


create table retail_sales (
	invoice_number VARCHAR(20),
	stock_code VARCHAR(20),
	description TEXT,
	quantity INTEGER,
	invoice_date TIMESTAMP,
	unit_price NUMERIC(10,2),
	customer_id INTEGER,
	country VARCHAR(50)
);

copy retail_sales
from 'C:\Users\Noca\Desktop\Datasets\online_retail_II.csv'
DELIMITER ',' csv header;

select *
from retail_sales
limit 5;
DROP TABLE IF EXISTS rfm_analytics;

CREATE TABLE rfm_analytics AS
	with clean_data AS(
		select *
		from retail_sales
		where customer_id is not null
		and quantity > 0
),

rfm_base as (
	select 
		customer_id,
		MAX(invoice_date) as last_invoice_date,
		(select MAX(invoice_date) from clean_data) - MAX(invoice_date) as recency_interval,
		COUNT(distinct invoice_number) as frequency_count,
		SUM(quantity * unit_price) as monetary_total 
	from clean_data 
	group by customer_id
	),
	
rfm_scores as (
	select 
		customer_id,
		recency_interval,
		frequency_count,
		monetary_total,
		ntile(5) over (order by recency_interval DESC) as r_score,
		ntile(5) over (order by frequency_count ASC) as f_score,
		ntile(5) over (order by monetary_total ASC) as m_score
	from rfm_base 
	)
	
	SELECT 
    customer_id,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_profile,
    CASE
        WHEN r_score = 5 AND f_score = 5 AND m_score = 5 THEN 'Champions'
        WHEN f_score >= 4 AND m_score >= 4 AND r_score >= 4 THEN 'Loyalists'
        WHEN m_score = 5 AND r_score < 5 THEN 'Big Spenders'
        WHEN r_score <= 2 AND (f_score >= 4 OR m_score >= 4) THEN 'At Risk VIPs'
        WHEN r_score = 1 AND m_score = 1 THEN 'Hibernating'
        WHEN r_score = 5 AND f_score = 1 THEN 'New Customers'
        ELSE 'Regular Customers'
    END AS customer_segment
FROM rfm_scores
ORDER BY monetary_total DESC;

SELECT * 
FROM rfm_analytics 
LIMIT 5;

SELECT 
    customer_id, 
    rfm_profile, 
    customer_segment,
     m_score  
FROM rfm_analytics
ORDER BY m_score DESC;

DROP TABLE IF EXISTS rfm_analytics;

CREATE TABLE rfm_analytics AS
WITH clean_data AS (
    SELECT *
    FROM retail_sales
    WHERE customer_id IS NOT NULL 
      AND quantity > 0
),

rfm_base AS (
    SELECT 
        customer_id,
        MAX(invoice_date) AS last_purchase_date,
        ('2011-12-09'::DATE - MAX(invoice_date)::DATE) AS recency_days,
        COUNT(DISTINCT invoice_number) AS frequency_count,
        SUM(quantity * unit_price) AS monetary_total
    FROM clean_data
    GROUP BY customer_id
),

rfm_scores AS (
    SELECT 
        customer_id,
        recency_days,
        frequency_count,
        monetary_total,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency_count ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_total ASC) AS m_score
    FROM rfm_base
)

SELECT 
    customer_id,
    recency_days,
    frequency_count,
    monetary_total,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_profile,
    CASE 
        WHEN r_score = 5 AND f_score = 5 AND m_score = 5 THEN 'Champions'
        WHEN f_score >= 4 AND m_score >= 4 AND r_score >= 4 THEN 'Loyalists'
        WHEN m_score = 5 AND r_score < 5 THEN 'Big Spenders'
        WHEN r_score <= 2 AND (f_score >= 4 OR m_score >= 4) THEN 'At Risk VIPs'
        WHEN r_score = 1 AND m_score = 1 THEN 'Hibernating'
        WHEN r_score = 5 AND f_score = 1 THEN 'New Customers'
        ELSE 'Regular Customers'
    END AS customer_segment
FROM rfm_scores;

select *
from rfm_analytics
ORDER BY monetary_total DESC;

select 
	customer_segment,
	COUNT(customer_id) as total_customer,
	ROUND(COUNT(customer_id) * 100.0 / (select COUNT(*) from rfm_analytics), 1) as pct_of_total,
	TO_CHAR(SUM(monetary_total), 'FM$999,999,999.00') as total_revenue 
from rfm_analytics 
group by customer_segment 
order by SUM(monetary_total) desc;

	