USE portfolio;

CREATE OR REPLACE VIEW v_projects_with_tech AS
SELECT
    p.id,
    p.title,
    p.description,
    p.github_url,
    p.live_url,
    p.image_url,
    p.featured,
    p.display_order,
    GROUP_CONCAT(DISTINCT t.name ORDER BY t.name SEPARATOR ', ') AS tech_stack,
    COUNT(DISTINCT pv.id)                                        AS total_views,
    p.created_at
FROM projects p
LEFT JOIN project_technologies pt ON p.id = pt.project_id
LEFT JOIN technologies         t  ON pt.technology_id = t.id
LEFT JOIN project_views        pv ON p.id = pv.project_id
GROUP BY
    p.id, p.title, p.description, p.github_url,
    p.live_url, p.image_url, p.featured,
    p.display_order, p.created_at;

-- rank skills within each category, also shows avg so you can see where you're above/below
CREATE OR REPLACE VIEW v_skills_ranked AS
SELECT
    sc.name                                                            AS category,
    s.name                                                             AS skill,
    s.proficiency,
    RANK() OVER (PARTITION BY sc.id ORDER BY s.proficiency DESC)      AS rank_in_category,
    ROUND(AVG(s.proficiency) OVER (PARTITION BY sc.id), 1)            AS avg_category_proficiency
FROM skills s
JOIN skill_categories sc ON s.skill_category_id = sc.id;

CREATE OR REPLACE VIEW v_experience_full AS
SELECT
    e.id,
    e.company,
    e.role,
    e.location,
    e.start_date,
    IFNULL(e.end_date, CURDATE())                                   AS effective_end_date,
    e.is_current,
    TIMESTAMPDIFF(MONTH, e.start_date, IFNULL(e.end_date, CURDATE())) AS months_tenure,
    ROUND(
        TIMESTAMPDIFF(MONTH, e.start_date, IFNULL(e.end_date, CURDATE())) / 12.0, 1
    )                                                               AS years_tenure,
    GROUP_CONCAT(eh.highlight ORDER BY eh.display_order SEPARATOR ' | ') AS highlights,
    e.display_order
FROM experience e
LEFT JOIN experience_highlights eh ON e.id = eh.experience_id
GROUP BY
    e.id, e.company, e.role, e.location,
    e.start_date, e.end_date, e.is_current, e.display_order;

CREATE OR REPLACE VIEW v_unread_messages AS
SELECT
    id,
    name,
    email,
    subject,
    LEFT(message, 120) AS preview,
    created_at
FROM contact_messages
WHERE is_read = FALSE
ORDER BY created_at DESC;

CREATE OR REPLACE VIEW v_project_view_stats AS
SELECT
    p.id,
    p.title,
    p.featured,
    COUNT(pv.id)                                       AS total_views,
    COUNT(DISTINCT pv.ip_address)                      AS unique_visitors,
    MAX(pv.viewed_at)                                  AS last_viewed,
    RANK() OVER (ORDER BY COUNT(pv.id) DESC)           AS popularity_rank,
    ROUND(
        COUNT(pv.id) * 100.0 / NULLIF(SUM(COUNT(pv.id)) OVER (), 0), 2
    )                                                  AS pct_of_total_views
FROM projects p
LEFT JOIN project_views pv ON p.id = pv.project_id
GROUP BY p.id, p.title, p.featured;
