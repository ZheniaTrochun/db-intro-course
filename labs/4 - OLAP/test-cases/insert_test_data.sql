-- ============================================================================
-- OLAP TEST DATA SEED SCRIPT
-- Purpose: Populate all database tables with structured test data to verify
--          analytical SQL queries:
--          - Aggregate functions: COUNT, COUNT(DISTINCT), SUM, AVG, MIN, MAX
--          - Grouping and filtering: GROUP BY, HAVING
--          - Joins: INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN, CROSS JOIN
--          - Edge cases: NULL values, zero-count relations, various data types
-- ============================================================================

-- 0. CLEANUP (Restart identity counters so primary keys consistently start from 1)
TRUNCATE TABLE 
    habit_completions, 
    habits, 
    habits_categories, 
    tasks, 
    task_categories, 
    workspace_members, 
    workspaces, 
    users 
RESTART IDENTITY CASCADE;


-- ============================================================================
-- 1. USERS
-- Tests:
-- - Standalone user without workspaces/tasks (User 6: Anna Novak) -> tests LEFT/RIGHT JOINs
-- - Users with NULL phone_number (Users 5 and 6) -> tests COUNT(phone_number) vs COUNT(*)
-- - Grouping by timezone (Kyiv, Berlin, Paris, Warsaw, UTC)
-- ============================================================================
INSERT INTO users (name, nickname, phone_number, password, email, timezone, created_at)
VALUES
    (
        'Dmitry Bondarenko', 'dmitry42', '+380501112233', 
        '$2b$12$e8YkZJ3wXQ4n8aT4Fk1Z6uK8dO5Lp8YnFk9zZ0wW1q2r3t4y5u6i7', 
        'dmitry@example.com', 'Europe/Kyiv', CURRENT_TIMESTAMP - INTERVAL '60 days'
    ),
    (
        'Alex Miller', 'alex_dev', '+491512345678', 
        '$2b$12$k8YkZJ3wXQ4n8aT4Fk1Z6uK8dO5Lp8YnFk9zZ0wW1q2r3t4y5u6i8', 
        'alex@example.com', 'Europe/Berlin', CURRENT_TIMESTAMP - INTERVAL '45 days'
    ),
    (
        'Maria Kovalenko', 'maria_k', '+380671234567', 
        '$2b$12$m8YkZJ3wXQ4n8aT4Fk1Z6uK8dO5Lp8YnFk9zZ0wW1q2r3t4y5u6i9', 
        'maria@example.com', 'Europe/Kyiv', CURRENT_TIMESTAMP - INTERVAL '30 days'
    ),
    (
        'Sophie Dubois', 'sophie_d', '+33612345678', 
        '$2b$12$s8YkZJ3wXQ4n8aT4Fk1Z6uK8dO5Lp8YnFk9zZ0wW1q2r3t4y5u6j0', 
        'sophie@example.com', 'Europe/Paris', CURRENT_TIMESTAMP - INTERVAL '20 days'
    ),
    (
        'Liam Smith', 'liam_s', NULL, 
        '$2b$12$l8YkZJ3wXQ4n8aT4Fk1Z6uK8dO5Lp8YnFk9zZ0wW1q2r3t4y5u6j1', 
        'liam@example.com', 'Etc/UTC', CURRENT_TIMESTAMP - INTERVAL '10 days'
    ),
    (
        'Anna Novak', 'anna_n', NULL, 
        '$2b$12$a8YkZJ3wXQ4n8aT4Fk1Z6uK8dO5Lp8YnFk9zZ0wW1q2r3t4y5u6j2', 
        'anna@example.com', 'Europe/Warsaw', CURRENT_TIMESTAMP - INTERVAL '5 days'
    );


-- ============================================================================
-- 2. WORKSPACES
-- Tests:
-- - Multiple workspaces per owner (Owner 1 has 2 workspaces)
-- - Owners with 1 workspace (Users 2 and 3)
-- - Users with 0 workspaces (Users 4, 5, 6)
-- - Multiple statuses: ACTIVE and ARCHIVED
-- ============================================================================
INSERT INTO workspaces (owner_id, name, description, status, created_at)
VALUES
    (
        1, 'Trackly Core Team', 
        'Main collaborative workspace for Trackly platform development', 
        'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '55 days'
    ),
    (
        1, 'KPI University 2026', 
        'Computer Science coursework, laboratories, and team assignments', 
        'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '40 days'
    ),
    (
        2, 'DevOps & Infrastructure', 
        'CI/CD automation, cloud deployment, and database administration', 
        'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '25 days'
    ),
    (
        3, 'Marketing & Outreach', 
        'Archived marketing initiatives and user acquisition campaigns', 
        'ARCHIVED', CURRENT_TIMESTAMP - INTERVAL '15 days'
    );


-- ============================================================================
-- 3. WORKSPACE MEMBERS
-- Tests:
-- - Different roles: OWNER, ADMIN, MEMBER, GUEST
-- - Different statuses: ACTIVE, INVITED
-- - Many-to-many relationship aggregations (count of members per workspace, count of workspaces per user)
-- ============================================================================
INSERT INTO workspace_members (user_id, workspace_id, role, status, joined_at)
VALUES
    (1, 1, 'OWNER',  'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '55 days'),
    (2, 1, 'ADMIN',  'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '50 days'),
    (3, 1, 'MEMBER', 'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '48 days'),
    (4, 1, 'GUEST',  'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '30 days'),
    
    (1, 2, 'OWNER',  'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '40 days'),
    (3, 2, 'ADMIN',  'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '38 days'),
    (4, 2, 'MEMBER', 'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '25 days'),
    
    (2, 3, 'OWNER',  'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '25 days'),
    (1, 3, 'MEMBER', 'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '20 days'),
    (5, 3, 'MEMBER', 'INVITED', CURRENT_TIMESTAMP - INTERVAL '8 days'),
    
    (3, 4, 'OWNER',  'ACTIVE',  CURRENT_TIMESTAMP - INTERVAL '15 days');


-- ============================================================================
-- 4. TASK CATEGORIES
-- Tests:
-- - Categories with multiple tasks (Category 1: 4 tasks, Category 3: 3 tasks, Category 2: 2 tasks)
-- - Category with 1 task (Category 4: 1 task)
-- - Category with ZERO tasks (Category 5: 'Market Research') -> tests RIGHT JOIN / FULL JOIN
-- - Category with NULL workspace_id (Category 6: Personal general tasks)
-- ============================================================================
INSERT INTO task_categories (user_id, workspace_id, name, color, created_at)
VALUES
    (1, 1,    'Backend Development', '#3498db', CURRENT_TIMESTAMP - INTERVAL '50 days'), -- id: 1
    (1, 1,    'Frontend & UI',       '#9b59b6', CURRENT_TIMESTAMP - INTERVAL '45 days'), -- id: 2
    (1, 2,    'Lab Works',           '#2ecc71', CURRENT_TIMESTAMP - INTERVAL '35 days'), -- id: 3
    (2, 3,    'DevOps & Cloud',      '#e67e22', CURRENT_TIMESTAMP - INTERVAL '20 days'), -- id: 4
    (3, 4,    'Market Research',     '#e74c3c', CURRENT_TIMESTAMP - INTERVAL '10 days'), -- id: 5 (0 tasks assigned!)
    (1, NULL, 'Personal & General',  '#f8f8f8', CURRENT_TIMESTAMP - INTERVAL '5 days');  -- id: 6 (0 tasks assigned!)


-- ============================================================================
-- 5. TASKS
-- Tests:
-- - Aggregate functions:
--     * COUNT(*), COUNT(priority), COUNT(category_id), COUNT(DISTINCT priority)
--     * SUM(priority), AVG(priority), MIN(priority), MAX(priority)
--     * MIN(deadline), MAX(deadline), MIN(LENGTH(name)), MAX(LENGTH(name))
-- - GROUP BY & HAVING:
--     * GROUP BY status (open: 4, in_progress: 3, done: 3, closed: 1, cancelled: 1)
--     * HAVING COUNT(*) >= 3 returns only ('open', 'in_progress', 'done')
-- - JOINs:
--     * Tasks WITH category vs Tasks WITHOUT category (category_id IS NULL -> IDs 11, 12)
--     * Tasks WITH assignee vs Tasks WITHOUT assignee (assignee_id IS NULL -> IDs 11, 12)
--     * Assignees with multiple tasks (User 1, User 2) vs Assignees with 0 tasks (User 5, User 6)
-- ============================================================================
INSERT INTO tasks (
    name, description, status, priority, 
    creator_id, assignee_id, workspace_id, category_id, 
    created_at, deadline
)
VALUES
    -- Category 1 (Backend Development)
    (
        'Implement JWT authentication service', 
        'Add JWT access and refresh token authentication middleware to API gateway', 
        'in_progress', 1, 
        1, 2, 1, 1, 
        CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_TIMESTAMP + INTERVAL '5 days'
    ),
    (
        'Refactor database connection pool', 
        'Optimize connection pooling and implement health-check endpoint', 
        'in_progress', 2, 
        2, 1, 1, 1, 
        CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP + INTERVAL '3 days'
    ),
    (
        'Write service integration tests', 
        'Cover user registration and authentication flows with end-to-end tests', 
        'open', 3, 
        1, 2, 1, 1, 
        CURRENT_TIMESTAMP - INTERVAL '12 days', CURRENT_TIMESTAMP + INTERVAL '8 days'
    ),
    (
        'Deploy release v1.0 to staging', 
        'Prepare docker images and deploy staging cluster with migrations', 
        'closed', 1, 
        2, 2, 1, 1, 
        CURRENT_TIMESTAMP - INTERVAL '25 days', CURRENT_TIMESTAMP - INTERVAL '2 days'
    ),

    -- Category 2 (Frontend & UI)
    (
        'Build analytics dashboard page', 
        'Implement metric cards, chart widgets and responsive layout in React', 
        'open', 3, 
        1, 4, 1, 2, 
        CURRENT_TIMESTAMP - INTERVAL '8 days', CURRENT_TIMESTAMP + INTERVAL '12 days'
    ),
    (
        'Fix mobile header navigation bar', 
        'Mobile hamburger menu toggle issue on Safari iOS', 
        'cancelled', 4, 
        1, 4, 1, 2, 
        CURRENT_TIMESTAMP - INTERVAL '6 days', CURRENT_TIMESTAMP + INTERVAL '1 day'
    ),

    -- Category 3 (Lab Works)
    (
        'Design database ER diagram for Lab 1', 
        'Create entity relationship diagram in Mermaid format with all relations', 
        'done', 1, 
        1, 1, 2, 3, 
        CURRENT_TIMESTAMP - INTERVAL '35 days', CURRENT_TIMESTAMP - INTERVAL '30 days'
    ),
    (
        'Create PostgreSQL DDL scripts for Lab 2', 
        'Implement table definitions, keys, and foreign constraints', 
        'done', 1, 
        1, 3, 2, 3, 
        CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '24 days'
    ),
    (
        'Write OLAP analytical queries for Lab 4', 
        'Implement aggregation queries, GROUP BY, HAVING, and multi-table JOINs', 
        'in_progress', 2, 
        1, 1, 2, 3, 
        CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP + INTERVAL '4 days'
    ),

    -- Category 4 (DevOps & Cloud)
    (
        'Configure PostgreSQL Docker container', 
        'Setup docker-compose with persistent volume and env credentials', 
        'done', 2, 
        2, 2, 3, 4, 
        CURRENT_TIMESTAMP - INTERVAL '22 days', CURRENT_TIMESTAMP - INTERVAL '18 days'
    ),

    -- Uncategorized & Unassigned Tasks (Crucial for LEFT/RIGHT/FULL JOIN and NULL handling)
    (
        'Create weekly automated database backup script', 
        'Backup automation using pg_dump and cron schedule', 
        'open', NULL, 
        1, NULL, 1, NULL, 
        CURRENT_TIMESTAMP - INTERVAL '4 days', NULL
    ),
    (
        'Organize team retrospective meeting', 
        'Discuss sprint results and plan upcoming technical milestones', 
        'open', 5, 
        3, NULL, 1, NULL, 
        CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP + INTERVAL '6 days'
    );


-- ============================================================================
-- 6. HABITS CATEGORIES
-- Tests:
-- - Categories with habits (Categories 1, 2, 3)
-- - Category with ZERO habits (Category 4: 'Mindfulness & Wellbeing') -> tests JOINs
-- ============================================================================
INSERT INTO habits_categories (user_id, name, color, created_at)
VALUES
    (1, 'Fitness & Health',           '#2ecc71', CURRENT_TIMESTAMP - INTERVAL '50 days'), -- id: 1
    (1, 'Education & Reading',        '#3498db', CURRENT_TIMESTAMP - INTERVAL '45 days'), -- id: 2
    (2, 'Productivity & Deep Work',   '#f39c12', CURRENT_TIMESTAMP - INTERVAL '30 days'), -- id: 3
    (3, 'Mindfulness & Wellbeing',    '#9b59b6', CURRENT_TIMESTAMP - INTERVAL '15 days'); -- id: 4 (0 habits assigned!)


-- ============================================================================
-- 7. HABITS
-- Tests:
-- - Habits with completions (Habits 1, 2, 3)
-- - Habits with ZERO completions (Habits 4, 5) -> tests LEFT JOIN and count = 0
-- - Habit WITHOUT category (Habit 5 has category_id = NULL) -> tests NULL categories
-- - Different statuses: ACTIVE, PAUSED
-- - Array operations on frequency_days
-- ============================================================================
INSERT INTO habits (
    name, description, creator_id, category_id, 
    timezone, frequency_days, status, start_day, created_at
)
VALUES
    (
        'Morning 5km Jogging', 
        'Outdoor jogging for stamina and cardiovascular health', 
        1, 1, 
        'Europe/Kyiv', ARRAY[1, 3, 5]::SMALLINT[], 'ACTIVE', 
        CURRENT_DATE - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days'
    ),
    (
        'Read Technical Literature', 
        'Read software engineering and database architecture books', 
        1, 2, 
        'Europe/Kyiv', ARRAY[1, 2, 3, 4, 5, 6, 7]::SMALLINT[], 'ACTIVE', 
        CURRENT_DATE - INTERVAL '20 days', CURRENT_TIMESTAMP - INTERVAL '20 days'
    ),
    (
        'Solve Algorithm Problem', 
        'Solve at least one LeetCode problem every weekday', 
        2, 3, 
        'Europe/Berlin', ARRAY[1, 2, 3, 4, 5]::SMALLINT[], 'ACTIVE', 
        CURRENT_DATE - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '15 days'
    ),
    (
        'Drink 2 Liters of Water', 
        'Maintain daily body hydration level', 
        1, 1, 
        'Europe/Kyiv', ARRAY[1, 2, 3, 4, 5, 6, 7]::SMALLINT[], 'ACTIVE', 
        CURRENT_DATE - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '10 days'
    ),
    (
        'Evening Guided Meditation', 
        '15 minutes relaxation and breathing mindfulness', 
        3, NULL, 
        'Europe/Kyiv', ARRAY[6, 7]::SMALLINT[], 'PAUSED', 
        CURRENT_DATE - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days'
    );


-- ============================================================================
-- 8. HABIT COMPLETIONS
-- Tests:
-- - Quantitative numerical aggregations on actual_value:
--     * SUM(actual_value), AVG(actual_value), MIN(actual_value), MAX(actual_value)
--     * Habit 1: 5km, 6km, 7km, NULL (skipped) -> SUM=18, AVG=6.0, MIN=5, MAX=7
--     * Habit 2: 20, 25, 30, 15, 35 pages     -> SUM=125, AVG=25.0, MIN=15, MAX=35
--     * Habit 3: 2, 1 problems solved, NULL missed
-- - NULL value handling in actual_value and note
-- - Multiple completion statuses: COMPLETED, PARTIALLY_COMPLETED, SKIPPED, MISSED
-- ============================================================================
INSERT INTO habit_completions (
    habit_id, local_timestamp, completed_at, actual_value, note, status
)
VALUES
    -- Habit 1: Morning 5km Jogging (measure in km)
    (
        1, CURRENT_DATE - INTERVAL '6 days' + TIME '07:30:00',
        CURRENT_TIMESTAMP - INTERVAL '6 days', 5, 'Ran 5 km in the local park', 'COMPLETED'
    ),
    (
        1, CURRENT_DATE - INTERVAL '4 days' + TIME '07:30:00',
        CURRENT_TIMESTAMP - INTERVAL '4 days', 6, 'Paced tempo run 6 km', 'COMPLETED'
    ),
    (
        1, CURRENT_DATE - INTERVAL '2 days' + TIME '07:30:00',
        CURRENT_TIMESTAMP - INTERVAL '2 days', 7, 'Long distance jog 7 km', 'COMPLETED'
    ),
    (
        1, CURRENT_DATE + TIME '07:30:00',
        CURRENT_TIMESTAMP, NULL, 'Heavy rain outside, morning run skipped', 'SKIPPED'
    ),

    -- Habit 2: Read Technical Literature (measure in pages)
    (
        2, CURRENT_DATE - INTERVAL '5 days' + TIME '21:00:00',
        CURRENT_TIMESTAMP - INTERVAL '5 days', 20, 'PostgreSQL query optimization chapter', 'COMPLETED'
    ),
    (
        2, CURRENT_DATE - INTERVAL '4 days' + TIME '21:00:00',
        CURRENT_TIMESTAMP - INTERVAL '4 days', 25, 'B-Tree and Hash indexing internals', 'COMPLETED'
    ),
    (
        2, CURRENT_DATE - INTERVAL '3 days' + TIME '21:00:00',
        CURRENT_TIMESTAMP - INTERVAL '3 days', 30, 'OLAP architectures and aggregation pipelines', 'COMPLETED'
    ),
    (
        2, CURRENT_DATE - INTERVAL '2 days' + TIME '21:00:00',
        CURRENT_TIMESTAMP - INTERVAL '2 days', 15, 'Tired in the evening, read only 15 pages', 'PARTIALLY_COMPLETED'
    ),
    (
        2, CURRENT_DATE - INTERVAL '1 day'  + TIME '21:00:00',
        CURRENT_TIMESTAMP - INTERVAL '1 day',  35, 'Transactions isolation and MVCC mechanism', 'COMPLETED'
    ),

    -- Habit 3: Solve Algorithm Problem (measure in problems solved)
    (
        3, CURRENT_DATE - INTERVAL '3 days' + TIME '18:00:00',
        CURRENT_TIMESTAMP - INTERVAL '3 days', 2, 'Solved Two Sum and Valid Anagram', 'COMPLETED'
    ),
    (
        3, CURRENT_DATE - INTERVAL '2 days' + TIME '18:00:00',
        CURRENT_TIMESTAMP - INTERVAL '2 days', 1, 'Solved Binary Search problem', 'COMPLETED'
    ),
    (
        3, CURRENT_DATE - INTERVAL '1 day'  + TIME '18:00:00',
        CURRENT_TIMESTAMP - INTERVAL '1 day', NULL, 'Work deadline overload, missed daily challenge', 'MISSED'
    );
