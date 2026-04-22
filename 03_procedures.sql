USE portfolio;

DELIMITER $$

DROP FUNCTION  IF EXISTS fn_years_experience$$
DROP PROCEDURE IF EXISTS sp_get_project_details$$
DROP PROCEDURE IF EXISTS sp_log_project_view$$
DROP PROCEDURE IF EXISTS sp_mark_messages_read$$
DROP PROCEDURE IF EXISTS sp_dashboard_summary$$
DROP TRIGGER  IF EXISTS tr_experience_before_insert$$
DROP TRIGGER  IF EXISTS tr_experience_before_update$$

CREATE FUNCTION fn_years_experience(
    p_start_date DATE,
    p_end_date   DATE
)
RETURNS DECIMAL(4, 1)
DETERMINISTIC
BEGIN
    RETURN ROUND(
        TIMESTAMPDIFF(MONTH, p_start_date, IFNULL(p_end_date, CURDATE())) / 12.0, 1
    );
END$$

CREATE PROCEDURE sp_get_project_details(IN p_id INT UNSIGNED)
BEGIN
    SELECT
        p.id,
        p.title,
        p.description,
        p.github_url,
        p.live_url,
        p.image_url,
        p.featured,
        GROUP_CONCAT(DISTINCT t.name ORDER BY t.name SEPARATOR ', ') AS tech_stack,
        COUNT(DISTINCT pv.id)          AS total_views,
        COUNT(DISTINCT pv.ip_address)  AS unique_visitors
    FROM projects p
    LEFT JOIN project_technologies pt ON p.id = pt.project_id
    LEFT JOIN technologies         t  ON pt.technology_id = t.id
    LEFT JOIN project_views        pv ON p.id = pv.project_id
    WHERE p.id = p_id
    GROUP BY
        p.id, p.title, p.description,
        p.github_url, p.live_url, p.image_url, p.featured;
END$$

-- silently skips if the same IP already viewed within the last hour
CREATE PROCEDURE sp_log_project_view(
    IN p_project_id INT UNSIGNED,
    IN p_ip         VARCHAR(45),
    IN p_referrer   VARCHAR(255)
)
BEGIN
    DECLARE already_viewed INT DEFAULT 0;

    SELECT COUNT(*) INTO already_viewed
    FROM project_views
    WHERE project_id = p_project_id
      AND ip_address = p_ip
      AND viewed_at  > DATE_SUB(NOW(), INTERVAL 1 HOUR);

    IF already_viewed = 0 THEN
        INSERT INTO project_views (project_id, ip_address, referrer)
        VALUES (p_project_id, p_ip, p_referrer);
    END IF;
END$$

CREATE PROCEDURE sp_mark_messages_read(IN p_email VARCHAR(150))
BEGIN
    UPDATE contact_messages
    SET    is_read = TRUE
    WHERE  email   = p_email
      AND  is_read = FALSE;

    SELECT ROW_COUNT() AS messages_updated;
END$$

CREATE PROCEDURE sp_dashboard_summary()
BEGIN
    SELECT COUNT(*) AS total_projects, SUM(featured) AS featured_projects
    FROM projects;

    SELECT p.title, COUNT(pv.id) AS views
    FROM projects p
    LEFT JOIN project_views pv ON p.id = pv.project_id
    GROUP BY p.id, p.title
    ORDER BY views DESC
    LIMIT 1;

    SELECT COUNT(*) AS unread_messages
    FROM contact_messages
    WHERE is_read = FALSE;

    SELECT COUNT(*) AS views_last_30_days
    FROM project_views
    WHERE viewed_at >= DATE_SUB(NOW(), INTERVAL 30 DAY);
END$$

-- keep is_current in sync with end_date automatically
CREATE TRIGGER tr_experience_before_insert
BEFORE INSERT ON experience
FOR EACH ROW
BEGIN
    SET NEW.is_current = (NEW.end_date IS NULL);
END$$

CREATE TRIGGER tr_experience_before_update
BEFORE UPDATE ON experience
FOR EACH ROW
BEGIN
    SET NEW.is_current = (NEW.end_date IS NULL);
END$$

DELIMITER ;
