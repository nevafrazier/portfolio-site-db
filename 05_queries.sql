USE portfolio;

-- featured projects with tech stack and view count
SELECT
    p.title,
    p.live_url,
    GROUP_CONCAT(DISTINCT t.name ORDER BY t.name SEPARATOR ' · ') AS tech_stack,
    COUNT(DISTINCT pv.id) AS total_views
FROM projects p
INNER JOIN project_technologies pt ON p.id = pt.project_id
INNER JOIN technologies         t  ON pt.technology_id = t.id
LEFT  JOIN project_views        pv ON p.id = pv.project_id
WHERE p.featured = TRUE
GROUP BY p.id, p.title, p.live_url
ORDER BY total_views DESC;


-- rank skills by proficiency within each category
WITH skill_rankings AS (
    SELECT
        sc.name                                                        AS category,
        s.name                                                         AS skill,
        s.proficiency,
        RANK() OVER (PARTITION BY sc.id ORDER BY s.proficiency DESC)  AS rank_in_category,
        ROUND(AVG(s.proficiency) OVER (PARTITION BY sc.id), 1)        AS avg_category_proficiency
    FROM skills s
    JOIN skill_categories sc ON s.skill_category_id = sc.id
)
SELECT * FROM skill_rankings
ORDER BY category, rank_in_category;


-- month over month view trend using LAG
WITH monthly_views AS (
    SELECT
        DATE_FORMAT(viewed_at, '%Y-%m') AS month,
        COUNT(*)                        AS views
    FROM project_views
    GROUP BY DATE_FORMAT(viewed_at, '%Y-%m')
),
view_trend AS (
    SELECT
        month,
        views,
        LAG(views) OVER (ORDER BY month) AS prev_month_views
    FROM monthly_views
)
SELECT
    month,
    views,
    prev_month_views,
    views - prev_month_views AS view_delta,
    CASE
        WHEN prev_month_views IS NULL THEN 'N/A'
        WHEN views > prev_month_views  THEN 'Up'
        WHEN views < prev_month_views  THEN 'Down'
        ELSE 'Flat'
    END AS trend
FROM view_trend
ORDER BY month;


-- technologies used across more than one project
SELECT
    t.name              AS technology,
    COUNT(pt.project_id) AS project_count
FROM technologies t
INNER JOIN project_technologies pt ON t.id = pt.technology_id
GROUP BY t.id, t.name
HAVING COUNT(pt.project_id) > 1
ORDER BY project_count DESC;


-- projects with above average views (correlated subquery)
SELECT p.title, COUNT(pv.id) AS views
FROM projects p
LEFT JOIN project_views pv ON p.id = pv.project_id
GROUP BY p.id, p.title
HAVING COUNT(pv.id) > (
    SELECT AVG(view_count)
    FROM (
        SELECT COUNT(*) AS view_count
        FROM project_views
        GROUP BY project_id
    ) sub
)
ORDER BY views DESC;


-- quartile ranking by views
WITH project_view_counts AS (
    SELECT
        p.title,
        COUNT(pv.id) AS views
    FROM projects p
    LEFT JOIN project_views pv ON p.id = pv.project_id
    GROUP BY p.id, p.title
)
SELECT
    title,
    views,
    ROW_NUMBER() OVER (ORDER BY views DESC) AS row_num,
    NTILE(4)     OVER (ORDER BY views DESC) AS quartile
FROM project_view_counts
ORDER BY views DESC;


-- where traffic is coming from
SELECT
    CASE
        WHEN referrer LIKE '%google%'   THEN 'Google'
        WHEN referrer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referrer LIKE '%github%'   THEN 'GitHub'
        WHEN referrer LIKE '%twitter%'  THEN 'Twitter'
        WHEN referrer IS NULL           THEN 'Direct'
        ELSE 'Other'
    END                  AS source,
    COUNT(*)             AS visits,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_visits
FROM project_views
GROUP BY source
ORDER BY visits DESC;


-- experience summary using the custom function + CTE
WITH tenure AS (
    SELECT
        id,
        company,
        role,
        fn_years_experience(start_date, end_date) AS years,
        is_current
    FROM experience
),
highlight_counts AS (
    SELECT experience_id, COUNT(*) AS num_highlights
    FROM experience_highlights
    GROUP BY experience_id
)
SELECT
    t.company,
    t.role,
    t.years AS years_tenure,
    hc.num_highlights,
    CASE WHEN t.is_current THEN 'Current' ELSE 'Past' END AS status
FROM tenure t
LEFT JOIN highlight_counts hc ON t.id = hc.experience_id
ORDER BY t.is_current DESC, t.years DESC;


-- rolling 7 day view count
SELECT
    DATE(viewed_at) AS day,
    COUNT(*)        AS daily_views,
    SUM(COUNT(*)) OVER (
        ORDER BY DATE(viewed_at)
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )               AS rolling_7d_views
FROM project_views
GROUP BY DATE(viewed_at)
ORDER BY day;


-- stored procedure calls
CALL sp_get_project_details(1);
CALL sp_log_project_view(1, '203.0.113.42', 'https://linkedin.com');
CALL sp_dashboard_summary();
