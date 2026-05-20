# portfolio-site-db

MySQL database behind [nevafrazier.com](https://nevafrazier.com).

Handles projects, skills, work experience, contact messages, and project view analytics.

## Schema

```
skill_categories  ──< skills
technologies      ──< project_technologies >── projects
experience        ──< experience_highlights
contact_messages
project_views     >── projects
```

## Files

| File | Description |
|------|-------------|
| `01_schema.sql` | Tables, foreign keys, indexes, constraints |
| `02_views.sql` | Views including window functions and aggregations |
| `03_procedures.sql` | Stored procedures, custom function, triggers |
| `04_seed.sql` | Seed data |
| `05_queries.sql` | Advanced query showcase — CTEs, window functions, subqueries |

## Stack

MySQL 8.0+

## Setup

```bash
mysql -u root -p < 01_schema.sql
mysql -u root -p < 02_views.sql
mysql -u root -p < 03_procedures.sql
mysql -u root -p < 04_seed.sql
```
