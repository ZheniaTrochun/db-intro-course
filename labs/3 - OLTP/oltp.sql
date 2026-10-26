--- INSERT --- 

	-- users --
INSERT INTO users (
	name, nickname, phone_number, password, email
) VALUES
	(Null, 'User_nickname_1', '+1234567', 'hashed_password', 'user1@example.com'),
	(Null, 'User_nickname_2', Null, 'hashed_password', 'user2@example.com'),
	('User3', 'User_nickname_3', '018349439', 'hashed_password', 'user3@example.com');

SELECT * FROM users; -- Inspect the changes --

	-- workspaces --
INSERT INTO workspaces (owner_id,name)
VALUES (1 , 'STUDY');

INSERT INTO workspaces (owner_id,name,description,status)
VALUES (2, 'Ivan','Text','ACTIVE');

	-- task_categories --
INSERT INTO task_categories (
    user_id, workspace_id, name, color
) VALUES 
	(2, 1, 'New_task_category', DEFAULT),
	(3, 2, 'User3_category', '#ffe4e1'),
	(3, Null, 'Work_category', DEFAULT);

SELECT * FROM task_categories; -- Inspect the changes --

	-- tasks --
INSERT INTO tasks (
	name, description, status, priority, creator_id, 
    assignee_id, workspace_id, category_id, deadline
) VALUES
	('New_workspace_1', NULL, DEFAULT, 1, 2, 3, 1, NULL, NULL),
	('New_workspace_2', 'Some text', 'done', NULL, 3, NULL, 1, NULL, NULL),
	('New_workspace_3', NULL, DEFAULT, NULL, 2, 3, 1, 1, NULL);

SELECT * FROM tasks; -- Inspect the changes --

	-- workspace_members --
INSERT INTO workspace_members (user_id, workspace_id, role, status)
    VALUES (2, 1, 'ADMIN', 'ACTIVE');

	-- habits_categories --
INSERT INTO habits_categories (user_id, name, color)
VALUES
    (1, 'Health', '#2ecc71'),
    (1, 'Learning', '#3498db'),
    (2, 'Productivity', '#f39c12');

SELECT * FROM habits_categories; -- Inspect the changes --

    -- habits --
INSERT INTO habits (
    name, description, creator_id, category_id,
    timezone, frequency_days, status, start_day
)
VALUES
    (
        'Morning Run',
        'Run for at least 30 minutes',
        1, 1,
        'Europe/Berlin', ARRAY[1, 3, 5]::SMALLINT[], 'ACTIVE', CURRENT_DATE
    ),
    (
        'Read a Book',
        'Read at least 20 pages per day',
        1, 2,
        'Europe/Berlin', ARRAY[1, 2, 3, 4, 5, 6, 7]::SMALLINT[], 'ACTIVE', CURRENT_DATE
    ),
    (
        'Plan the Day',
        'Write down the most important tasks for the day',
        2, 3,
        'Europe/Berlin', ARRAY[1, 2, 3, 4, 5]::SMALLINT[], 'PAUSED', CURRENT_DATE
    );

SELECT * FROM habits ;

	-- habit_completions --
INSERT INTO habit_completions (
    habit_id, local_timestamp, completed_at, actual_value, note, status
)
VALUES
    (
        3, CURRENT_DATE + TIME '07:30:00',
        CURRENT_TIMESTAMP, 35, 'Ran 5 kilometers', 'COMPLETED'
    ),
    (
        2, CURRENT_DATE + TIME '21:00:00',
        CURRENT_TIMESTAMP, 25, 'Read 25 pages', 'COMPLETED'
    ),
    (
        3, CURRENT_DATE + TIME '09:00:00',
        CURRENT_TIMESTAMP, NULL, 'Skipped daily planning', 'COMPLETED'
    );

SELECT * FROM habit_completions ;


--- UPDATE --- 

	-- users --
UPDATE users
	SET name = 'User_name_updated'
	WHERE id = 1 AND name IS NULL;

UPDATE users
	SET timezone = 'Europe/Kyiv'
	WHERE id = 2;

UPDATE users
	SET phone_number = '029876234'
	WHERE id = 2 AND phone_number IS NULL;

SELECT * FROM users; -- Inspect the changes --

	-- workspaces -- 
-- UPDATE workspaces
--     SET name = 'KIRILL'
--     WHERE id = 2;

	-- task_categories --
UPDATE task_categories
	SET workspace_id = Null
	WHERE id = 1;

UPDATE task_categories 
	SET color = '#a3b899'
	WHERE color = '#f8f8f8'; -- DEFAULT '#f8f8f8'

UPDATE task_categories
	SET name = 'Sport' 
	WHERE id = 3;
	
SELECT * FROM task_categories;

	-- tasks --
UPDATE tasks
	SET name = 'Homework'
	WHERE id = 1;

SELECT * FROM tasks;

	-- workspace_members --
-- UPDATE workspace_members
--     SET role = 'GUEST'
--     WHERE id = 1;

UPDATE workspace_members 
    SET role = 'OWNER' 
    WHERE user_id = 2 AND workspace_id = 1;

	-- habits_categories --
UPDATE habits_categories
    SET color = '#27ae60', updated_at = CURRENT_TIMESTAMP
    WHERE user_id = 1 AND name = 'Health'
    RETURNING *;

SELECT * FROM habits_categories; -- Inspect the changes --

    -- habits --
UPDATE habits
    SET timezone = 'Europe/London', frequency_days = ARRAY[1, 3, 5], status = 'ACTIVE'
    WHERE name = 'Plan the Day' AND status = 'PAUSED'
    RETURNING *;

UPDATE habits
    SET status = 'PAUSED'
    WHERE creator_id = 1;

SELECT * FROM habits; -- Inspect the changes --

	-- habit_completions --
UPDATE habit_completions
    SET actual_value = 40, note = 'Ran 6 kilometers'
    WHERE habit_id = 3 AND local_timestamp = CURRENT_DATE + TIME '07:30:00'
    RETURNING *;

-- UPDATE habit_completions
--     SET status = 'SKIPPED', actual_value = NULL, note = 'Skipped today'
--     WHERE habit_id = 6 AND local_timestamp = CURRENT_DATE + TIME '07:30:00'
--     RETURNING *;

SELECT * FROM habit_completions; -- Inspect the changes --

--- DELETE --- 

	-- users --
DELETE FROM users
	WHERE name is NULL;

SELECT * FROM users;

	-- workspaces --
-- DELETE FROM workspaces
--     WHERE id = 1;

	-- task_categories --
DELETE FROM task_categories
	WHERE id > 3;

SELECT * FROM task_categories;

	-- tasks --
DELETE FROM tasks
	WHERE id > 3;

SELECT * FROM tasks;

	-- workspace_members --
DELETE FROM workspace_members 
    WHERE user_id = 1 AND workspace_id = 3;

	-- habits_categories --
DELETE FROM habits_categories
    WHERE user_id = 2 AND name = 'Productivity'
    RETURNING *;

SELECT * FROM habits_categories;

    -- habits --
DELETE FROM habits
    WHERE status = 'PAUSED'
    RETURNING *;

SELECT * FROM habits; -- Inspect the changes --

	-- habit_completions --
SELECT habit_id, local_timestamp, completed_at, actual_value, note, status
    FROM habit_completions
    ORDER BY local_timestamp DESC;

SELECT * FROM habit_completions
    WHERE habit_id = 1 AND status = 'COMPLETED';

--- SELECT --- 

	-- users --
SELECT * FROM users;

SELECT name, nickname, phone_number, email
	FROM users
	ORDER BY id 
	LIMIT 3;

SELECT name, nickname 
	FROM users
	WHERE id = 2;
	
	-- workspaces --
SELECT * FROM workspaces;

SELECT * FROM workspace_members WHERE user_id = 3; 

	-- task_categories --
SELECT * FROM task_categories;

SELECT user_id, workspace_id, name, color 
	FROM task_categories
	WHERE workspace_id IS NOT NULL;

SELECT user_id, name, color 
	FROM task_categories
	WHERE color = '#3498db';

	-- tasks --
SELECT * FROM tasks;

SELECT name, status, assignee_id 
	FROM tasks
	WHERE creator_id = 1;

	-- workspace_members --
SELECT * FROM workspace_members;

SELECT user_id, workspace_id, role, status, joined_at 
    FROM workspace_members;

SELECT user_id, role, status FROM workspace_members; 

	-- habits_categories --
SELECT * FROM habits_categories;

SELECT id, user_id, name, color
    FROM habits_categories
    WHERE user_id = 1;

    -- habits --
SELECT name, description, timezone, status, start_day
    FROM habits
    ORDER BY id
    LIMIT 2;

SELECT *
    FROM habits
    WHERE name = 'Plan the Day';

	-- habit_completions --
DELETE FROM habit_completions
    WHERE habit_id = 3 AND local_timestamp = CURRENT_DATE + TIME '07:30:00'
    RETURNING *;