CREATE TABLE Customer_Churn (
    customer_id VARCHAR(20) PRIMARY KEY,
    gender ENUM('Male', 'Female'),
    age INT,
    married ENUM('Yes', 'No'),
    number_of_dependents INT,
    city VARCHAR(100),
    zip_code VARCHAR(10),
    latitude DECIMAL(10, 6),
    longitude DECIMAL(10, 6),
    number_of_referrals INT,
    payment_method VARCHAR(50),
    monthly_charge DECIMAL(10, 2),
    total_charges DECIMAL(10, 2),
    total_refunds DECIMAL(10, 2),
    total_extra_data_charges INT,
    total_long_distance_charges DECIMAL(10, 2),
    total_revenue DECIMAL(10, 2),
    customer_status VARCHAR(20),
    churn_category VARCHAR(50),
    churn_reason VARCHAR(100)
);
SELECT * FROM customer_churn LIMIT 10;

# 1. Identify the number of churned customers by service type

SELECT 
    `Internet Service`, 
    `Phone Service`, 
    COUNT(`Customer ID`) AS `Churned Customers`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Internet Service`, `Phone Service`;
    
# 2. Analyze churn by tenure 

SELECT 
    CASE 
        WHEN `Tenure in Months` < 12 THEN '0-12 Months'
        WHEN `Tenure in Months` BETWEEN 12 AND 24 THEN '12-24 Months'
        ELSE '24+ Months'
    END AS `Tenure Range`, 
    COUNT(`Customer ID`) AS `Churned Customers`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Tenure Range`;
    
# 3. Find the Average monthly charges of churned vs. retained customers

SELECT 
    `Customer Status`, 
    AVG(`Monthly Charge`) AS `Avg Monthly Charge`
FROM 
    customer_churn
GROUP BY 
    `Customer Status`;

# 4. Analyze churn by contract type

SELECT 
    `Contract`, 
    COUNT(`Customer ID`) AS `Churned Customers`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Contract`;

# 5. Analyze churn by payment method

SELECT 
    `Payment Method`, 
    COUNT(`Customer ID`) AS `Churned Customers`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Payment Method`
ORDER BY 
    `Churned Customers` DESC;

# 6.  Identify High-Risk customers based on monthly charges and low tenure

SELECT 
    `Customer ID`, `Tenure in Months`, `Monthly Charge`, `Customer Status`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Stayed' 
    AND `Monthly Charge` > 80 
    AND `Tenure in Months` < 12;

# 7.  Find churned customers by reason and service type

SELECT 
    `Internet Service`, `Phone Service`, `Churn Reason`, 
    COUNT(`Customer ID`) AS `Churned Customers`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Internet Service`, `Phone Service`, `Churn Reason`;

# 8.  Find churn based on demographics (Gender, Age)

SELECT 
    Gender, 
    CASE 
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 50 THEN '30-50'
        ELSE 'Over 50'
    END AS Age_Group, 
    COUNT(`Customer ID`) AS `Churned Customers`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    Gender, Age_Group;
    
# 9.  Determine churn by data usage

SELECT 
    CASE 
        WHEN `Avg Monthly GB Download` < 10 THEN 'Low Usage (<10 GB)'
        WHEN `Avg Monthly GB Download` BETWEEN 10 AND 50 THEN 'Moderate Usage (10-50 GB)'
        ELSE 'High Usage (>50 GB)'
    END AS `Data Usage Group`, 
    COUNT(`Customer ID`) AS `Churned Customers`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Data Usage Group`;

# 10.  Analyze churn by streaming service usage

SELECT 
    CASE 
        WHEN `Streaming TV` = 'Yes' OR `Streaming Movies` = 'Yes' THEN 'Using Streaming Services'
        ELSE 'Not Using Streaming Services'
    END AS `Streaming Usage`, 
    COUNT(`Customer ID`) AS `Churned Customers`
FROM 
    customer_churn
WHERE 
    `Customer Status` = 'Churned'
GROUP BY 
    `Streaming Usage`;
    
# 11 Stored Procedure to Identify High-Value Customers at Risk of Churning.

SHOW CREATE PROCEDURE identify_high_value_customers_at_risk;
DROP PROCEDURE IF EXISTS identify_high_value_customers_at_risk;
DELIMITER //

CREATE PROCEDURE identify_high_value_customers_at_risk(
    IN p_revenue_threshold DECIMAL(10, 2),
    IN p_charge_threshold DECIMAL(10, 2)
)
BEGIN
    SELECT 
        `Customer ID` AS customer_id,
        Gender AS gender,
        Age AS age,
        City AS city,
        `Total Revenue` AS total_revenue,
        `Monthly Charge` AS monthly_charge,
        `Churn Category` AS churn_category,
        `Churn Reason` AS churn_reason
    FROM 
        customer_churn
    WHERE 
        (`Total Revenue` > p_revenue_threshold OR `Monthly Charge` > p_charge_threshold)
        AND (`Customer Status` = 'Churned' OR `Churn Category` IS NOT NULL);
END //

DELIMITER ;

CALL identify_high_value_customers_at_risk(10000.00, 80.00);
DESCRIBE customer_churn;



































  















