DROP TABLE IF EXISTS telco_churn;

CREATE TABLE telco_churn (
    customer_id VARCHAR(50) PRIMARY KEY,
    gender VARCHAR(20),
    senior_citizen INTEGER,
    partner VARCHAR(5),
    dependents VARCHAR(5),
    tenure INTEGER,
    phone_service VARCHAR(5),
    multiple_lines VARCHAR(50),
    internet_service VARCHAR(50),
    online_security VARCHAR(50),
    online_backup VARCHAR(50),
    device_protection VARCHAR(50),
    tech_support VARCHAR(50),
    streaming_tv VARCHAR(50),
    streaming_movies VARCHAR(50),
    contract VARCHAR(50),
    paperless_billing VARCHAR(5),
    payment_method VARCHAR(50),
    monthly_charges NUMERIC(10,2),
    total_charges VARCHAR(50),
    churn_status VARCHAR(5)
);

COPY telco_churn 
FROM 'C:\Users\Noca\Desktop\Datasets\WA_Fn-UseC_-Telco-Customer-Churn.csv' 
WITH (FORMAT CSV, HEADER);

SELECT 
    contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN churn_status = 'Yes' THEN 1 ELSE 0 END) AS churn_count,
    ROUND(SUM(CASE WHEN churn_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    TO_CHAR(SUM(CASE WHEN churn_status = 'Yes' THEN monthly_charges ELSE 0 END), 'FM$999,999') AS revenue_lost
FROM telco_churn
GROUP BY contract
ORDER BY SUM(CASE WHEN churn_status = 'Yes' THEN monthly_charges ELSE 0 END) DESC;

select *
from telco_churn 
limit 5;

SELECT 
    payment_method,
    COUNT(*) AS total_customers,
    ROUND(SUM(CASE WHEN churn_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS churn_rate_pct
FROM telco_churn
GROUP BY payment_method
ORDER BY churn_rate_pct DESC;

SELECT 
    CASE 
        WHEN payment_method LIKE '%automatic%' THEN 'Auto-Pay'
        ELSE 'Manual Pay'
    END AS payment_type,
    COUNT(*) AS total_customers,
    ROUND(AVG(tenure), 1) AS avg_tenure_months,
    ROUND(SUM(CASE WHEN churn_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS churn_rate
FROM telco_churn
GROUP BY 1
ORDER BY avg_tenure_months DESC;

