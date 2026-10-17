USE startup_funding;

-- ==========================================================================================================================
-- Q1. Calculate the percentage of missing/zero values in a amount column. find the sector and cities of missing or zero values percentage.
-- ==========================================================================================================================
WITH sector_city_percentage AS (
    SELECT
        Industry_Vertical,
        City_Location,
        COUNT(*) AS total_rows,

        SUM(
            CASE 
                WHEN Amount IS NULL OR Amount<0 OR Amount=0 THEN 1
                ELSE 0
            END
        ) AS missing_zero_count,

        ROUND(
            SUM(
                CASE 
                    WHEN Amount IS NULL OR Amount<0 OR Amount=0 THEN 1
                    ELSE 0
                END
            ) * 100.0 / COUNT(*),
            2
        ) AS missing_zero_percentage
    FROM startup_funding
    GROUP BY Industry_Vertical,
        City_Location
)
SELECT
    *
FROM sector_city_percentage
ORDER BY missing_zero_count DESC;

-- =========
-- Insight: 
-- =========
-- ==========================================================================================================================
-- after seeing output of that query, i observe Amount column not have any zero or negative or null values, means in python cleaning is correct.
-- ==========================================================================================================================
-- SQLBook: Code
-- ==========================================================
-- Q2. SubVertical vs Industry Vertical – Consistency Check
-- ==========================================================
WITH count_sub_vertical AS (
    SELECT
        SubVertical,
        Industry_Vertical,
        COUNT(*) AS count 
    FROM startup_funding
    GROUP BY SubVertical,
        Industry_Vertical
    HAVING COUNT(*) > 1
) 
SELECT
    COUNT(*)
FROM count_sub_vertical
-- WHERE SubVertical != 'Unknown'

-- =========
-- Insight: 
-- =========
-- ==========================================================================================================================
-- SubVertical column was found to be highly inconsistent (140 values mapped to multiple Industry Verticals, and 'Unknown' spanned 39 Verticals). Hence, SubVertical was dropped from analysis, and Industry Vertical was used for all sector-level insights.
-- ==========================================================================================================================
-- SQLBook: Code
-- ============================================================================
-- Q3. Calculate the contribution of each Industry Verticle in overall Amount
-- ============================================================================
WITH industry_vertical_wise_amount AS (
    SELECT  
        Industry_Vertical,
        SUM(Amount) AS total_amount
    FROM startup_funding
    GROUP BY Industry_Vertical
),
overall_contribution AS (
    SELECT
        Industry_Vertical,
        total_amount,

        SUM(total_amount) OVER() AS overall_amount,

        ROUND(
            total_amount * 100.0 / SUM(total_amount) OVER(),
            8
        ) AS contribution
    FROM industry_vertical_wise_amount
)

SELECT
    *
FROM overall_contribution
ORDER BY total_amount DESC;

-- =========
-- Insight: 
-- =========
-- ==========================================================================================================================
-- This query output shows the highest contributer is E-commerce  with 20.65% contribution percentage. and some Industry Vertical is contributed very low like Coupon Aggregator Platform is 0.00005141% with  contribution rate. and i saw this output is only some Industry Vertical Contributed highest like Consumer Interenet 16.64%, E-commerce 20.65%, Transportation 10.06%, Technology 6.48 % and Finance 3.47% contributed. i observe one very interesting thing these are contributed amount 59% of overall amount.
-- ==========================================================================================================================
-- SQLBook: Code
-- =================================================
-- Q4. find the top 5 subvertical by total funding
-- =================================================
WITH top_subverticals AS (
    SELECT
        SubVertical,
        SUM(Amount) AS total_funding
    FROM startup_funding
    GROUP BY SubVertical
    ORDER BY total_funding DESC
    LIMIT 5
)
SELECT
    *
FROM top_subverticals;

-- =========
-- Insight: 
-- =========
-- ==========================================================================================================================
-- after seeing this query output, Unknown generate 139890575.93 highest total funding. Unknow not any subvertical it is default value filled where is null values in subvertical. then Bike Taxi generate 60000000.00 as second highest funding amount
-- ==========================================================================================================================

-- =====================================================================================
-- Q5. change YoY and month wise total funding. and find where amount was winter/boom.
-- =====================================================================================
WITH order_year_month AS (
    SELECT
        YEAR(Date) AS order_year,
        MONTH(Date) AS order_month,

        SUM(Amount) AS total_amount
    FROM startup_funding
    GROUP BY YEAR(Date),
        MONTH(Date)
),
previous_year_month AS (
    SELECT
        order_year,
        order_month,
        total_amount,

        LAG(total_amount) OVER(
            PARTITION BY order_year
            ORDER BY order_year, order_month
        ) AS previous_year_month 
    FROM order_year_month
),
growth_pct AS (
    SELECT
        order_year,
        order_month,
        total_amount,
        previous_year_month,

        ROUND(
            (total_amount - previous_year_month) * 100.0 / previous_year_month,
            2
        ) AS growth_pct
    FROM previous_year_month
)

SELECT  
    order_year,
    order_month,
    total_amount,
    previous_year_month,
    growth_pct
FROM growth_pct
ORDER BY total_amount ASC;

-- ===========
-- insight: 
-- ===========
-- ==============================================================================================
-- year 2019-08 in total amount is boom(highest). and growth pct is 1426.95%. winter(lowest) year is 2018-10, in this growth pct is -90.95%. this is indicates in some places total amount was very hign but in some places total amount was very low.
-- ==============================================================================================

-- ==================================================================
-- Q6. top 5 cities how much contributed % in overall total amount?
-- ==================================================================
WITH top_5_cities AS (
    SELECT
        City_Location AS City,
        SUM(Amount) AS total_amount
    FROM startup_funding
    GROUP BY City_Location 
),
overall_amount AS (
    SELECT
        City,
        total_amount,
        
        SUM(total_amount) OVER() AS overall_total_amount
    FROM top_5_cities
)

SELECT
    City,
    total_amount,
    overall_total_amount,

    ROUND(
        (total_amount * 100.0) / overall_total_amount,
        2
    ) AS city_wise_contribution
FROM overall_amount
ORDER BY city_wise_contribution DESC
LIMIT 5;
-- ============
-- insights:
-- ============
-- ==============================================================================================
-- i observe top 5 cities contributed ~80% of in overall total amount. but onw interesting thing only Banglore is contributed 48.60% in overall total amount. this idicated Banglore is the possible important city for startup location but i would not conlude only this is important.
-- ==============================================================================================

-- ==================================================================
-- Q7. which industry vertical attracts more funding and deal count
-- ==================================================================
SELECT
    Industry_Vertical,
    SUM(Amount) AS total_amount,
    COUNT(*) AS deal_count
FROM startup_funding
GROUP BY Industry_Vertical
ORDER BY SUM(Amount) DESC,
    COUNT(*) DESC;
-- =========
-- insight: 
-- =========
-- ==============================================================================================
-- The Consumer Internet Industry Vertical attracts highest total amount ~105.58 Million and also highest deal count total 935 deal counts. Consumer Internet Industry sector are the highest contributer and also highest deal generator. but i would not conclude this sector are better for new startup on the basis of only this information.
-- ==============================================================================================

-- ==============================================================================================
-- Q8. drill down into vertical and find which sub-vertical is the highest total amount and deal count generator?
-- ==============================================================================================
SELECT
    Industry_Vertical,
    SubVertical,
    SUM(Amount) AS total_amount,
    COUNT(*) AS deal_count
FROM startup_funding
GROUP BY Industry_Vertical,
    SubVertical
ORDER BY 
    COUNT(*) DESC

-- ==========
-- insight:
-- ==========
-- ====================================================================================================================
-- after seeing output, i observe that Transportation sector in Bike Taxi is generated highest total amount 60.0 Million. and most interesting thing is Transport Sector in Bake Taxi subvertical deal count is only 1. in data cleaning phase i assign the default value in industry vertical and subvertical both are unknown and their deal count are highest 169, and their contribution in ~20.01 Million total amount.
-- ====================================================================================================================

-- ===============================================================
-- Q9. Find the vertical whose funding declining over the time?
-- ===============================================================
WITH vertical_funding AS (
    SELECT
        Industry_Vertical,

        SUM(CASE 
            WHEN YEAR(Date) = 2015 THEN Amount 
            ELSE 0
        END) AS `2015`,

        SUM(CASE 
            WHEN YEAR(Date) = 2016 THEN Amount 
            ELSE 0
        END) AS `2016`,

        SUM(CASE 
            WHEN YEAR(Date) = 2017 THEN Amount 
            ELSE 0
        END) AS `2017`,

        SUM(CASE 
            WHEN YEAR(Date) = 2018 THEN Amount 
            ELSE 0
        END) AS `2018`,

        SUM(CASE 
            WHEN YEAR(Date) = 2019 THEN Amount 
            ELSE 0
        END) AS `2019`,

        SUM(CASE 
            WHEN YEAR(Date) = 2020 THEN Amount 
            ELSE 0
        END) AS `2020`

    FROM startup_funding
    GROUP BY Industry_Vertical
)

SELECT *
FROM vertical_funding
WHERE `2015` > `2016`
  AND `2016` > `2017`
  AND `2017` > `2018`
  AND `2018` > `2019`
  AND `2019` > `2020`;

-- ================================================
-- Q10. find the top 10 startups by total amount.
-- ================================================
SELECT
    Startup_Name,
    SUM(Amount) AS total_amount
FROM startup_funding
GROUP BY Startup_Name
ORDER BY total_amount DESC
LIMIT 10;

-- ===========================================================
-- Q11. Check the most active vs biggest investors are same?
-- ===========================================================
SELECT
    Investors_Name,
    SUM(Amount) AS total_amount,
    COUNT(*) AS deal_counts
FROM startup_funding
GROUP BY Investors_Name
ORDER BY deal_counts DESC;
-- =========
-- Insight
-- =========
-- ====================================================================================================================
-- Investors are different on the basis of total amount and deal counts. i observe that Westbridge Capital Investor is the highest amount and his total deal count is 2. Undisclosed Investors have the highest deal counts 80. not the highest amount. this indicates low total amount investors doing many times deals. but the highest total amount investors are doing very low deal.
-- ====================================================================================================================

-- =============================================================================================================
-- Q12. top 5 investors how much contributed in overall total amount? and which city/vertical they focused on?
-- =============================================================================================================
WITH top_5_investors AS (
    SELECT
        Investors_Name,
        SUM(Amount) AS total_amount
    FROM startup_funding
    GROUP BY Investors_Name
    ORDER BY total_amount DESC
    LIMIT 5
)
SELECT
    ROUND(
        SUM(total_amount) * 100.0 /
        (SELECT SUM(Amount) FROM startup_funding),
        2
    ) AS top_5_contribution
FROM top_5_investors;
-- =====
-- AND
-- =====
WITH top_5_investors AS (
    SELECT
        Investors_Name,
        SUM(Amount) AS total_amount
    FROM startup_funding
    GROUP BY Investors_Name
    ORDER BY total_amount DESC
    LIMIT 5
)
SELECT
    sf.Investors_Name,
    sf.City_Location,
    sf.Industry_Vertical,
    SUM(sf.Amount) AS funding_amount
FROM startup_funding sf
JOIN top_5_investors t5
    ON sf.Investors_Name = t5.Investors_Name
GROUP BY
    sf.Investors_Name,
    sf.City_Location,
    sf.Industry_Vertical
ORDER BY
    sf.Investors_Name,
    funding_amount DESC;


