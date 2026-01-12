 WITH base AS (
    SELECT
        Order_Date,
        Region,
        total_sales,

        CASE 
            WHEN Region = 'West' THEN 1
            ELSE 0
        END AS is_treatment,

        CASE 
            WHEN [Order_Date] >= '2016-01-01' THEN 1
            ELSE 0
        END AS is_post
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
        treatment_pre,
        treatment_post,
        control_pre,
        control_post,

        (treatment_post - treatment_pre) AS treatment_change,
        (control_post - control_pre) AS control_change,

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

business_impact AS (
    SELECT
        d.did_impact_monthly,
        p.post_months,

        -- Incremental revenue caused by intervention
        d.did_impact_monthly * p.post_months AS incremental_revenue,

        -- Assumed campaign cost
        CAST(1000000 AS FLOAT) AS campaign_cost
    FROM did_calc d
    CROSS JOIN post_period_length p
)

SELECT
    did_impact_monthly AS incremental_monthly_sales,
    post_months,
    incremental_revenue,
    campaign_cost,

    -- Net business benefit
    (incremental_revenue - campaign_cost) AS net_benefit,

    -- ROI
    (incremental_revenue - campaign_cost) / campaign_cost AS roi,

    -- ROI percentage
    ((incremental_revenue - campaign_cost) / campaign_cost) * 100 AS roi_percentage

FROM business_impact;
