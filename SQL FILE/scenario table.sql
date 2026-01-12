 WITH base AS (
    SELECT
        Order_Date,  
        Region,
        total_sales,
        CASE WHEN Region = 'West' THEN 1 ELSE 0 END AS is_treatment,
        CASE WHEN [Order_Date] >= '2016-01-01' THEN 1 ELSE 0 END AS is_post
    FROM monthly_sales_by_region
),

group_averages AS (
    SELECT
        is_treatment,
        is_post,
        AVG(total_sales) AS avg_monthly_sales
    FROM base
    GROUP BY is_treatment, is_post
),

pivoted AS (
    SELECT
        MAX(CASE WHEN is_treatment = 1 AND is_post = 0 THEN avg_monthly_sales END) AS treatment_pre,
        MAX(CASE WHEN is_treatment = 1 AND is_post = 1 THEN avg_monthly_sales END) AS treatment_post,
        MAX(CASE WHEN is_treatment = 0 AND is_post = 0 THEN avg_monthly_sales END) AS control_pre,
        MAX(CASE WHEN is_treatment = 0 AND is_post = 1 THEN avg_monthly_sales END) AS control_post
    FROM group_averages
),

did_calc AS (
    SELECT
        (treatment_post - treatment_pre)
        - (control_post - control_pre) AS did_impact_monthly
    FROM pivoted
),

post_period_length AS (
    SELECT
        COUNT(DISTINCT [Order_Date]) AS post_months
    FROM monthly_sales_by_region
    WHERE [Order_Date] >= '2016-01-01'
),

incremental_revenue_calc AS (
    SELECT
        d.did_impact_monthly,
        p.post_months,
        d.did_impact_monthly * p.post_months AS incremental_revenue
    FROM did_calc d
    CROSS JOIN post_period_length p
),

scenario_costs AS (
    SELECT 'Low Cost' AS scenario, 7000 AS campaign_cost
    UNION ALL
    SELECT 'Base Case', 10000
    UNION ALL
    SELECT 'High Cost', 15000
)

SELECT
    s.scenario,
    i.did_impact_monthly AS incremental_monthly_sales,
    i.post_months,
    i.incremental_revenue,
    s.campaign_cost,
    (i.incremental_revenue - s.campaign_cost) AS net_benefit,
    (i.incremental_revenue - s.campaign_cost) / s.campaign_cost AS roi,
    ((i.incremental_revenue - s.campaign_cost) / s.campaign_cost) * 100 AS roi_percentage
FROM incremental_revenue_calc i
CROSS JOIN scenario_costs s
ORDER BY s.campaign_cost;

