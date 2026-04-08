/* SUMMARY:
This SQL report integrates global sales performance with user engagement data to provide a holistic 
view of market dynamics across different continents. The query enables a comparative analysis of 
regional profitability and audience verification trends.

KEY METRICS:
- Total revenue and market share
- Revenue by device
- Account counts and verification rates
- Session activity

SQL TECHNIQUES USED: 
- CTEs
- Window Functions
- Conditional Aggregation
- Set Operations (UNION, JOIN)
*/

WITH continent_revenue AS (
    -- Calculating revenue segmented by device type
    SELECT
        sp.continent,
        SUM(CASE WHEN sp.device = 'mobile' THEN pr.price END) AS revenue_from_mobile,
        SUM(CASE WHEN sp.device = 'desktop' THEN pr.price END) AS revenue_from_desktop
    FROM `DA.session_params` sp
    JOIN `DA.order` o ON sp.ga_session_id = o.ga_session_id
    JOIN `DA.product` pr ON o.item_id = pr.item_id
    GROUP BY 1 
),

revenue_total AS (
    -- Calculating total revenue for market share percentage
    SELECT DISTINCT 
        sp.continent,
        SUM(pr.price) OVER(PARTITION BY sp.continent) AS revenue_pr,
        SUM(pr.price) OVER() AS revenue_total_usd
    FROM `DA.session_params` sp
    JOIN `DA.order` o ON sp.ga_session_id = o.ga_session_id
    JOIN `DA.product` pr ON o.item_id = pr.item_id
),

account_features AS (
    -- Aggregating user-level engagement metrics
    SELECT
        sp.continent,
        COUNT(DISTINCT ac.id) AS account_cnt,
        COUNT(DISTINCT CASE WHEN ac.is_verified = 1 THEN ac.id END) AS verified_account,
        COUNT(DISTINCT sp.ga_session_id) AS session_cnt
    FROM `DA.session_params` sp
    LEFT JOIN `DA.account_session` acs ON sp.ga_session_id = acs.ga_session_id
    LEFT JOIN `DA.account` ac ON acs.account_id = ac.id
    GROUP BY 1
),

final AS (
    -- Consolidating all metrics via UNION ALL
    SELECT continent, 0 AS revenue_pr, revenue_from_mobile, revenue_from_desktop, 0 AS revenue_total_usd, 0 AS account_cnt, 0 AS verified_account, 0 AS session_cnt
    FROM continent_revenue
    UNION ALL
    SELECT continent, revenue_pr, 0, 0, revenue_total_usd, 0, 0, 0
    FROM revenue_total
    UNION ALL
    SELECT continent, 0, 0, 0, 0, account_cnt, verified_account, session_cnt
    FROM account_features 
)

-- Final Output with Market Share calculation
SELECT
    continent,
    SUM(revenue_pr) AS total_revenue,
    SUM(revenue_from_mobile) AS mobile_revenue,
    SUM(revenue_from_desktop) AS desktop_revenue,
    ROUND(SUM(revenue_pr) / NULLIF(SUM(revenue_total_usd), 0) * 100, 2) AS market_share_percent,
    SUM(account_cnt) AS total_accounts,
    SUM(verified_account) AS verified_accounts_cnt,
    SUM(session_cnt) AS total_sessions
FROM final
GROUP BY continent
ORDER BY total_revenue DESC;
