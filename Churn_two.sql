SELECT * FROM churn
LIMIT 100;
-- Checking to see if the data was imported correctly

SELECT COUNT(*)
FROM Churn;
--10000 rows counted 

SELECT 
	key as column_name,
	COUNT(*) as total_rows,
	COUNT(*) FILTER(WHERE value IS NULL) AS null_count,
	ROUND(100 * COUNT(*) FILTER(WHERE value IS NULL) / NULLIF(COUNT(*),0),2) AS pct_null
FROM Churn t 
CROSS JOIN LATERAL jsonb_each_text(to_jsonb(t))
GROUP BY KEY 
ORDER BY pct_null;
-- Checking the missing values across each column
-- No missing values across each columm

SELECT 
	COUNT(Exited) FILTER(WHERE Exited = 1) AS left,
	COUNT(Exited) FILTER(WHERE Exited = 0) AS stayed
FROM Churn;
--Exactly 2037 Custmomers left the bank in this period

SELECT
	ROUND(100 * COUNT(*) FILTER(WHERE Exited = 1) / COUNT(*),2)
FROM Churn;
--Calculating the Churn rate for the bank. Calculated at exactly 20%.


SELECT
	Gender,
	ROUND(
	COUNT(Exited) FILTER(WHERE Exited = 1) :: numeric / COUNT(*)
	* 100,2) AS Churn_rate,
	COUNT(Exited) FILTER(WHERE Exited = 1) AS Churn_num
FROM Churn
GROUP BY Gender;
--Churn distribution by Gender(To be Tested for Significance)


SELECT 
	Geography,
	COUNT(*) FILTER(WHERE Exited = 1) AS Totals,
	ROUND(100 * COUNT(Exited) FILTER(WHERE Exited = 1) /
	SUM(COUNT(Exited) FILTER(wHERE Exited = 1)) OVER(),2) AS pct_of_geography_total
FROM Churn
GROUP BY Geography
ORDER BY Totals DESC
;
--Churn Distribution by geography

SELECT
	NumOfProducts,
	COUNT(*) AS count_of_products,
	ROUND(100 * 
	COUNT(*) FILTER (WHERE Exited = 1) :: numeric / COUNT(*),2)AS Churn_rate,
	ROUND( 100 * COUNT(NumOfProducts) FILTER(WHERE Exited = 1)
	/ SUM(COUNT(NumOfProducts) FILTER (WHERE Exited = 1)) OVER(),2) AS churn_rate_pct
FROM 
	Churn
GROUP BY NumOfProducts
ORDER BY churn_rate_pct DESC;
--Churn Distribution by Number of Products Owned(Will test for significance, Customers with 1 item have a really high chance of churning


SELECT 
	IsActivemember,
	COUNT(Exited) FILTER(WHERE Exited = 1) AS churn_count,
	ROUND(100 * 
	COUNT(*) FILTER (WHERE Exited = 1) :: numeric / COUNT(*),2)AS Chrn_rate,
	ROUND( 100 * COUNT(isactivemember) FILTER(WHERE Exited = 1)
	/ SUM(COUNT(isactivemember) FILTER (WHERE Exited = 1)) OVER(),2) AS churn_rate_pct
FROM Churn
GROUP BY isactivemember;
--Churn Distribution by Active membership(Will be tested for significance, Customers who arent active have a high chrn rate of over 63.92% )

SELECT 
	CASE 
		WHEN Balance = 0 THEN 'Zero Balance' ELSE 'Has Balance' END AS balance_flag,
	COUNT(*) FILTER(WHERE Exited = 1) as balance_count
FROM 
	Churn
GROUP BY balance_flag
ORDER BY balance_count DESC;
--Churn Distribution by Balance Specifically between customers that have a Balance of 0

WITH testing AS (
	SELECT
		 CASE 
		 	WHEN Balance = 0 THEN 'Zero Balance' ELSE 'Has Balance' END AS balance_flag,
		Exited
	FROM Churn
)
SELECT 
	balance_flag,
	COUNT(*) FILTER(WHERE Exited = 1) as churn_rate,
	ROUND( 100 * COUNT(*) FILTER(WHERE Exited = 1) /
	SUM(COUNT(balance_flag) FILTER (WHERE Exited = 1)) OVER(), 2) AS balance_pct
FROM testing
GROUP BY balance_flag
ORDER BY churn_rate DESC;
--Percentage of Churn Customers between customers that have a balance of 0 

SELECT 
	MIN(Balance) AS min_balance,
	Max(Balance) AS max_balance,
	ROUND(AVG(Balance),2) AS Avg_balace,
	ROUND(SUM(Balance),2) AS total_balance
FROM 
	Churn;

WITH income AS(
	SELECT 
		CASE 
			WHEN Balance = 0 THEN '0'
			WHEN Balance <= 50000 THEN '1-50K'
			WHEN Balance <= 100000 THEN '50-100K'
			WHEN Balance <= 150000 THEN  '100-150K'
			ELSE '150K+'  
			END AS income_dist,
		Exited 
		FROM Churn
)
SELECT 
	income_dist,
	COUNT(*) FILTER(WHERE Exited = 1) AS income_count
FROM income
GROUP BY income_dist
ORDER BY income_count DESC;
--Income Distribution by churn count

WITH income AS(
	SELECT 
		CASE 
			WHEN Balance = 0 THEN '0'
			WHEN Balance <= 50000 THEN '1-50K'
			WHEN Balance <= 100000 THEN '50-100K'
			WHEN Balance <= 150000 THEN  '100-150K'
			ELSE '150K+'  
			END AS income_dist,
		Exited,
		Geography
		FROM Churn
)
SELECT 
	income_dist,
	Geography,
	COUNT(*) FILTER(WHERE Exited = 1) AS income_count
FROM income
GROUP BY income_dist,Geography
ORDER BY income_count DESC;
--Income distributin cross referenced with Geography

WITH Age_income AS (
	SELECT 
		CASE
			WHEN Age < 30 THEN 'Under 30'
			WHEN Age < 45 THEN '30-44'
			WHEN Age < 60 THEN '45-59'
			ELSE '60+'
			END AS Age_brand,
			CASE 
			WHEN Balance = 0 THEN '0'
			WHEN Balance <= 50000 THEN '1-50K'
			WHEN Balance <= 100000 THEN '50-100K'
			WHEN Balance <= 150000 THEN  '100-150K'
			ELSE '150K+'  
			END AS income_dist,
		Exited
	FROM 
		Churn
)
SELECT 
	Age_brand,
	income_dist,
	COUNT(*) FILTER (WHERE Exited = 1) churn_count
FROM 
	Age_income 
GROUP BY Age_brand,income_dist
ORDER BY Age_brand ASC;

WITH Ages AS (
	SELECT 
		CASE
			WHEN Age < 30 THEN 'Under 30'
			WHEN Age < 45 THEN '30-44'
			WHEN Age < 60 THEN '45-59'
			ELSE '60+'
			END AS Age_brand,
			Exited
	FROM 
		Churn
)
SELECT 
	Age_brand,
	COUNT(*) FILTER (WHERE Exited = 1) AS Age_count,
	ROUND(100 * COUNT(*) FILTER (WHERE Exited =1 )/
	SUM(COUNT(*) FILTER (WHERE Exited = 1)) OVER(),2) AS pct_age_count
FROM Ages 
GROUP BY Age_brand
ORDER BY age_counT DESC;
--Churn Count distributed with age over 44% of customers who left were between 45-59, while the least likely to leave were poeple under 30

WITH Age_income AS (
	SELECT 
		CASE
			WHEN Age < 30 THEN 'Under 30'
			WHEN Age < 45 THEN '30-44'
			WHEN Age < 60 THEN '45-59'
			ELSE '60+'
			END AS Age_brand,
			CASE 
			WHEN Balance = 0 THEN '0'
			WHEN Balance <= 50000 THEN '1-50K'
			WHEN Balance <= 100000 THEN '50-100K'
			WHEN Balance <= 150000 THEN  '100-150K'
			ELSE '150K+'  
			END AS income_dist,
		Exited
	FROM 
		Churn
)
SELECT 
	Age_brand,
	income_dist,
	COUNT(*) FILTER (WHERE Exited = 1) churn_count
FROM 
	Age_income 
GROUP BY Age_brand,income_dist
ORDER BY churn_count DESC;

SELECT
    CASE WHEN balance = 0 THEN 'Zero Balance' ELSE 'Has Balance' END AS balance_flag,
    COUNT(*) AS customer_count,
    SUM(exited) AS churned_count,
    ROUND(AVG(exited) * 100, 2) AS churn_rate_pct
FROM Churn
GROUP BY balance_flag
ORDER BY balance_flag;

SELECT
	Geography,
	ROUND (
	100 * COUNT(*) FILTER(WHERE Exited = 1) :: numeric / COUNT(*) ,2) AS Churn_rate_pct
FROM Churn
GROUP BY GeogRaphy
ORDER BY Churn_rate_pct DESC;
--Churn composiotion by geography segment

SELECT 
	Geography,
	COUNT(*) AS total_count,
	ROUND (100 * 
	COUNT(*) FILTER (WHERE Exited = 1) :: numeric / COUNT(*),2
	) AS churn_rate,
	COUNT(*) FILTER(WHERE Exited = 1) AS churn_count,
	ROUND(
	100 * COUNT(*) FILTER (WHERE Exited  =1 ) :: numeric /
	SUM(COUNT(*) FILTER(WHERE Exited = 1)) OVER (),2) AS pct_of_churners
FROM Churn
GROUP BY Geography
ORDER BY total_count DESC, churn_count DESC;

SELECT 
	Tenure,
	COUNT(*) AS tenure_count,
	ROUND( 100 * COUNT(*) FILTER (WHERE Exited = 1) :: numeric /
	COUNT(*),2) as churn_rate,
	COUNT(*) FILTER (WHERE Exited = 1) AS churn_count,
	ROUND( 100 * 
	COUNT(*) FILTER (WHERE Exited = 1) :: numeric / 
	SUM(COUNT(*) FILTER (WHERE Exited = 1))  OVER (),2) AS pct_of_churners
FROM Churn
GROUP BY tenure
ORDER BY churn_rate DESC;
--Churn rate by customer tenure

SELECT
	MIN(creditscore) as min_score,
	MAX(creditscore) AS max_score,
	AVG(creditscore) AS avg_score
FROM Churn;

SELECT
    CASE
        WHEN creditscore < 580 THEN '1. Poor (<580)'
        WHEN creditscore BETWEEN 580 AND 669 THEN '2. Fair (580-669)'
        WHEN creditscore BETWEEN 670 AND 739 THEN '3. Good (670-739)'
        WHEN creditscore BETWEEN 740 AND 799 THEN '4. Very Good (740-799)'
        ELSE '5. Excellent (800+)'
    END AS credit_score_band,
    COUNT(*) AS band_count,
    COUNT(*) FILTER (WHERE exited = 1) AS churned_count,
    ROUND(
        COUNT(*) FILTER (WHERE exited = 1)::numeric / COUNT(*) * 100,
        2
    ) AS churn_rate_pct,
    ROUND(
        COUNT(*) FILTER (WHERE exited = 1)::numeric
        / SUM(COUNT(*) FILTER (WHERE exited = 1)) OVER () * 100,
        2
    ) AS pct_of_all_churners
FROM CHurn
GROUP BY credit_score_band
ORDER BY credit_score_band;
--Churn rate by cutomer credit score

SELECT
    CASE
        WHEN hascrcard = 1 THEN 'Has Credit Card'
        ELSE 'No Credit Card'
    END AS credit_card_status,
    COUNT(*) AS group_count,
    COUNT(*) FILTER (WHERE exited = 1) AS churned_count,
    ROUND(
        COUNT(*) FILTER (WHERE exited = 1)::numeric / COUNT(*) * 100,
        2
    ) AS churn_rate_pct,
    ROUND(
        COUNT(*) FILTER (WHERE exited = 1)::numeric
        / SUM(COUNT(*) FILTER (WHERE exited = 1)) OVER () * 100,
        2
    ) AS pct_of_all_churners
FROM Churn
GROUP BY credit_card_status
ORDER BY credit_card_status;
--Churn rate by if the customer has a credit card with the bank


copy Churn TO 'C:\Users\User\Desktop\Customer_Churn_dataset.csv' WITH CSV HEADER
