CREATE VIEW v_base_flags AS
SELECT
    Order_Date,
    Region,
    total_sales,
    total_profit,
    total_quantity,

    CASE 
        WHEN Region = 'West' THEN 1
        ELSE 0
    END AS is_treatment,

    CASE 
        WHEN [Order_Date] >= '2016-01-01' THEN 1
        ELSE 0
    END AS is_post

FROM monthly_sales_by_region;
SELECT * FROM v_base_flags

CREATE VIEW v_group_averages AS
SELECT
    is_treatment,
    is_post,
    AVG(total_sales) AS avg_monthly_sales
FROM v_base_flags
GROUP BY is_treatment, is_post;
SELECT * FROM v_group_averages

CREATE VIEW v_did_impact AS
SELECT
    MAX(CASE WHEN is_treatment = 1 AND is_post = 0 THEN avg_monthly_sales END) AS treatment_pre,
    MAX(CASE WHEN is_treatment = 1 AND is_post = 1 THEN avg_monthly_sales END) AS treatment_post,
    MAX(CASE WHEN is_treatment = 0 AND is_post = 0 THEN avg_monthly_sales END) AS control_pre,
    MAX(CASE WHEN is_treatment = 0 AND is_post = 1 THEN avg_monthly_sales END) AS control_post,

    (MAX(CASE WHEN is_treatment = 1 AND is_post = 1 THEN avg_monthly_sales END)
     - MAX(CASE WHEN is_treatment = 1 AND is_post = 0 THEN avg_monthly_sales END))
    -
    (MAX(CASE WHEN is_treatment = 0 AND is_post = 1 THEN avg_monthly_sales END)
     - MAX(CASE WHEN is_treatment = 0 AND is_post = 0 THEN avg_monthly_sales END))
    AS did_impact_monthly

FROM v_group_averages;
SELECT * FROM v_did_impact

CREATE VIEW v_roi_business_impact AS
SELECT
    d.did_impact_monthly,
    p.post_months,
    d.did_impact_monthly * p.post_months AS incremental_revenue,
    CAST(10000 AS FLOAT) AS campaign_cost,
    (d.did_impact_monthly * p.post_months) - 10000 AS net_benefit,
    ((d.did_impact_monthly * p.post_months) - 10000) / 10000 AS roi
FROM v_did_impact d
CROSS JOIN (
    SELECT COUNT(DISTINCT [Order_Date]) AS post_months
    FROM monthly_sales_by_region
    WHERE [Order_Date] >= '2016-01-01'
) p;
SELECT * FROM v_roi_business_impact
 

 CREATE VIEW v_roi_scenarios AS
SELECT
    s.scenario,
    r.did_impact_monthly,
    r.post_months,
    r.incremental_revenue,
    s.campaign_cost,
    r.incremental_revenue - s.campaign_cost AS net_benefit,
    (r.incremental_revenue - s.campaign_cost) / s.campaign_cost AS roi,
    ((r.incremental_revenue - s.campaign_cost) / s.campaign_cost) * 100 AS roi_percentage
FROM v_roi_business_impact r
CROSS JOIN (
    SELECT 'Low Cost' AS scenario, 7000 AS campaign_cost
    UNION ALL
    SELECT 'Base Case', 10000
    UNION ALL
    SELECT 'High Cost', 15000
) s;
SELECT * FROM v_roi_scenarios