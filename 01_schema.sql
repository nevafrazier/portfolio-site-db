CREATE DATABASE IF NOT EXISTS portfolio
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE portfolio;

CREATE TABLE skill_categories (
    id   TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT uq_skill_categories_name UNIQUE (name)
);

CREATE TABLE skills (
    id                 INT UNSIGNED     AUTO_INCREMENT PRIMARY KEY,
    skill_category_id  TINYINT UNSIGNED NOT NULL,
    name               VARCHAR(60)      NOT NULL,
    proficiency        TINYINT UNSIGNED NOT NULL DEFAULT 80,
    CONSTRAINT uq_skills_name         UNIQUE (name),
    CONSTRAINT chk_skills_proficiency CHECK (proficiency BETWEEN 1 AND 100),
    CONSTRAINT fk_skills_category
        FOREIGN KEY (skill_category_id)
        REFERENCES skill_categories(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE INDEX idx_skills_category    ON skills (skill_category_id);
CREATE INDEX idx_skills_proficiency ON skills (proficiency DESC);

-- separate table so the same tech can link to multiple projects
CREATE TABLE technologies (
    id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(60) NOT NULL,
    color VARCHAR(7)  DEFAULT NULL,
    CONSTRAINT uq_technologies_name UNIQUE (name)
);

CREATE TABLE projects (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(100) NOT NULL,
    description   TEXT         NOT NULL,
    github_url    VARCHAR(255) DEFAULT NULL,
    live_url      VARCHAR(255) DEFAULT NULL,
    image_url     VARCHAR(255) DEFAULT NULL,
    featured      BOOLEAN      NOT NULL DEFAULT FALSE,
    display_order INT UNSIGNED NOT NULL DEFAULT 0,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_projects_featured      ON projects (featured);
CREATE INDEX idx_projects_display_order ON projects (display_order);

CREATE TABLE project_technologies (
    project_id    INT UNSIGNED NOT NULL,
    technology_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (project_id, technology_id),
    CONSTRAINT fk_pt_project FOREIGN KEY (project_id)
        REFERENCES projects(id)     ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pt_technology FOREIGN KEY (technology_id)
        REFERENCES technologies(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_pt_technology ON project_technologies (technology_id);

CREATE TABLE experience (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company       VARCHAR(100) NOT NULL,
    role          VARCHAR(100) NOT NULL,
    location      VARCHAR(100) DEFAULT NULL,
    start_date    DATE         NOT NULL,
    end_date      DATE         DEFAULT NULL,
    is_current    BOOLEAN      NOT NULL DEFAULT FALSE,
    display_order INT UNSIGNED NOT NULL DEFAULT 0,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_experience_display_order ON experience (display_order);
CREATE INDEX idx_experience_is_current    ON experience (is_current);

-- one row per bullet point so i can reorder them easily
CREATE TABLE experience_highlights (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    experience_id INT UNSIGNED NOT NULL,
    highlight     VARCHAR(255) NOT NULL,
    display_order INT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_eh_experience FOREIGN KEY (experience_id)
        REFERENCES experience(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_eh_experience ON experience_highlights (experience_id, display_order);

CREATE TABLE contact_messages (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL,
    subject    VARCHAR(150) DEFAULT NULL,
    message    TEXT         NOT NULL,
    is_read    BOOLEAN      NOT NULL DEFAULT FALSE,
    ip_address VARCHAR(45)  DEFAULT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_unread ON contact_messages (is_read, created_at DESC);
CREATE INDEX idx_messages_email  ON contact_messages (email);

-- tracks which projects people are actually clicking on
CREATE TABLE project_views (
    id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    project_id INT UNSIGNED NOT NULL,
    ip_address VARCHAR(45)  DEFAULT NULL,
    referrer   VARCHAR(255) DEFAULT NULL,
    viewed_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pv_project FOREIGN KEY (project_id)
        REFERENCES projects(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_pv_project_date ON project_views (project_id, viewed_at);
CREATE INDEX idx_pv_date         ON project_views (viewed_at);
