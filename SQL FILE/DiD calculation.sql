 SELECT TOP 3 * FROM [dbo].[monthly_sales_by_region]
--DiD calculation
 WITH base AS (
    SELECT
        [Order_Date] AS order_date,
        Region,
        total_sales,

        -- Treatment flag
        CASE 
            WHEN Region = 'West' THEN 1
            ELSE 0
        END AS is_treatment,

        -- Post-intervention flag
        CASE 
            WHEN [Order_Date] >= '2016-01-01' THEN 1
            ELSE 0
        END AS is_post

    FROM monthly_sales_by_region
)
, group_averages AS (
    SELECT
        is_treatment,
        is_post,
        AVG(total_sales) AS avg_monthly_sales
    FROM base
    GROUP BY is_treatment, is_post
)
, pivoted AS (
    SELECT
        MAX(CASE WHEN is_treatment = 1 AND is_post = 0 THEN avg_monthly_sales END) AS treatment_pre,
        MAX(CASE WHEN is_treatment = 1 AND is_post = 1 THEN avg_monthly_sales END) AS treatment_post,
        MAX(CASE WHEN is_treatment = 0 AND is_post = 0 THEN avg_monthly_sales END) AS control_pre,
        MAX(CASE WHEN is_treatment = 0 AND is_post = 1 THEN avg_monthly_sales END) AS control_post
    FROM group_averages
)
SELECT
    treatment_pre,
    treatment_post,
    control_pre,
    control_post,

    -- Changes
    (treatment_post - treatment_pre) AS treatment_change,
    (control_post - control_pre) AS control_change,

    -- Difference-in-Differences impact
    (treatment_post - treatment_pre)
      - (control_post - control_pre) AS did_impact

FROM pivoted;

--monthly DiD trend

SELECT
    [Order_Date],
    SUM(CASE WHEN Region = 'West' THEN total_sales ELSE 0 END) AS treatment_sales,
    SUM(CASE WHEN Region <> 'West' THEN total_sales ELSE 0 END) AS control_sales
FROM monthly_sales_by_region
GROUP BY [Order_Date]
ORDER BY [Order_Date];

