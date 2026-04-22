USE portfolio;

INSERT INTO skill_categories (name) VALUES
('Frontend'),
('Backend'),
('Data'),
('Tools'),
('Design');

INSERT INTO technologies (name, color) VALUES
('React',       '#61DAFB'),
('Vite',        '#646CFF'),
('Tailwind CSS','#38BDF8'),
('JavaScript',  '#F7DF1E'),
('TypeScript',  '#3178C6'),
('Python',      '#3776AB'),
('FastAPI',     '#009688'),
('MySQL',       '#4479A1'),
('PostgreSQL',  '#336791'),
('Railway',     '#0B0D0E'),
('Vercel',      '#000000'),
('Git',         '#F05032'),
('REST API',    '#6DB33F');

INSERT INTO skills (skill_category_id, name, proficiency) VALUES
(1, 'React',         88),
(1, 'JavaScript',    87),
(1, 'Tailwind CSS',  82),
(1, 'HTML/CSS',      90),
(2, 'Python',        92),
(2, 'FastAPI',       83),
(2, 'REST APIs',     85),
(3, 'MySQL',         88),
(3, 'SQL',           90),
(3, 'Data Analysis', 85),
(4, 'Git',           86),
(4, 'Vercel',        82),
(4, 'Railway',       78),
(5, 'Figma',         70);

INSERT INTO projects (title, description, github_url, live_url, featured, display_order) VALUES
(
    'Viglore',
    'Market intelligence platform with real-time sentiment analysis, Stocktwits integration, live stock data, and rankings for 90+ cities. FastAPI backend deployed on Railway; React frontend on Vercel.',
    'https://github.com/nevafrazier/viglore',
    'https://viglore.com',
    TRUE,
    1
),
(
    'Portfolio Site',
    'Personal developer portfolio. Dark green themed, fully responsive, built with React and Vite.',
    NULL,
    'https://nevafrazier.com',
    FALSE,
    2
);

INSERT INTO project_technologies (project_id, technology_id)
SELECT 1, id FROM technologies WHERE name IN ('React','Python','FastAPI','MySQL','Railway','Vercel','REST API');

INSERT INTO project_technologies (project_id, technology_id)
SELECT 2, id FROM technologies WHERE name IN ('React','Vite','Tailwind CSS','JavaScript');

-- update these with real job history
INSERT INTO experience (company, role, location, start_date, end_date, display_order) VALUES
('Your Company', 'Your Role',  'City, State', '2024-01-01', NULL,         1),
('Previous Job', 'Prior Role', 'City, State', '2022-06-01', '2023-12-31', 2);

INSERT INTO experience_highlights (experience_id, highlight, display_order) VALUES
(1, 'Describe your biggest accomplishment here.',        1),
(1, 'Quantify impact where possible (e.g. 30% faster).', 2),
(2, 'What you built or improved at the previous role.',  1);

INSERT INTO contact_messages (name, email, subject, message) VALUES
('Demo User',   'demo@example.com',    'Collaboration',   'Would love to discuss a project with you.'),
('Recruiter A', 'recruiter@acme.com',  'Job Opportunity',  'We have a data analyst role that fits your profile.');

-- fake view history so the analytics queries have something to work with
INSERT INTO project_views (project_id, ip_address, referrer, viewed_at) VALUES
(1, '192.168.1.1', 'https://google.com',   DATE_SUB(NOW(), INTERVAL 1  DAY)),
(1, '10.0.0.2',    'https://linkedin.com', DATE_SUB(NOW(), INTERVAL 2  DAY)),
(1, '10.0.0.3',    'https://google.com',   DATE_SUB(NOW(), INTERVAL 3  DAY)),
(1, '10.0.0.4',    NULL,                   DATE_SUB(NOW(), INTERVAL 5  DAY)),
(1, '10.0.0.5',    'https://github.com',   DATE_SUB(NOW(), INTERVAL 7  DAY)),
(1, '10.0.0.6',    'https://google.com',   DATE_SUB(NOW(), INTERVAL 10 DAY)),
(1, '10.0.0.7',    'https://linkedin.com', DATE_SUB(NOW(), INTERVAL 12 DAY)),
(1, '10.0.0.8',    NULL,                   DATE_SUB(NOW(), INTERVAL 15 DAY)),
(1, '10.0.0.9',    'https://twitter.com',  DATE_SUB(NOW(), INTERVAL 20 DAY)),
(1, '10.0.0.10',   'https://google.com',   DATE_SUB(NOW(), INTERVAL 25 DAY)),
(2, '192.168.1.1', 'https://google.com',   DATE_SUB(NOW(), INTERVAL 1  DAY)),
(2, '10.0.0.2',    'https://linkedin.com', DATE_SUB(NOW(), INTERVAL 4  DAY)),
(2, '10.0.0.11',   NULL,                   DATE_SUB(NOW(), INTERVAL 8  DAY)),
(2, '10.0.0.12',   'https://google.com',   DATE_SUB(NOW(), INTERVAL 14 DAY)),
(2, '10.0.0.13',   'https://github.com',   DATE_SUB(NOW(), INTERVAL 22 DAY));
