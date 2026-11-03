--- users --- 
-- COUNT -- 
SELECT COUNT(timezone)
	FROM users;

-- DISTINCT --
SELECT DISTINCT(timezone)
	FROM users;

-- HAVING --
SELECT COUNT(id), timezone 
	FROM users
	GROUP BY timezone 
	HAVING COUNT (id) > 1;

-- ORDER BY --
SELECT id, name, timezone 
    FROM users
    ORDER BY timezone ASC;


--- tasks ---
-- COUNT --
SELECT COUNT (DISTINCT priority)
	FROM tasks;

SELECT COUNT(priority)
	FROM tasks
	WHERE priority = 1;

-- MIN --
SELECT MIN(priority)
	FROM tasks;

-- MAX -- 
SELECT MAX(priority)
	FROM tasks;

-- GROUP BY --
SELECT COUNT(id), status
	FROM tasks
	GROUP BY status;

-- HAVING --
SELECT COUNT(id), status
	FROM tasks
	GROUP BY status
	HAVING COUNT(id) > 2;

-- LEFT JOIN --
SELECT tasks.id, tasks.name, priority, tasks.category_id
	FROM tasks 
	LEFT JOIN task_categories ON tasks.category_id = task_categories.id
	ORDER BY tasks.category_id;

-- RIGHT JOIN -- 
SELECT task_categories.id, task_categories.name
	FROM task_categories
	RIGHT JOIN tasks ON task_categories.id = tasks.category_id
	ORDER BY tasks.category_id;

SELECT DISTINCT task_categories.id, task_categories.name 
	FROM task_categories
	RIGHT JOIN tasks ON task_categories.id = tasks.category_id;

-- FULL JOIN --
SELECT tasks.id, tasks.name, tasks.priority, tasks.category_id
	FROM tasks
	FULL JOIN task_categories ON tasks.category_id = task_categories.id;


--- task_categories --- 
-- COUNT -- 
SELECT COUNT(workspace_id)
	FROM task_categories;

SELECT COUNT(DISTINCT user_id)
	FROM task_categories;

-- ORDER BY --
SELECT DISTINCT name
	FROM task_categories
	ORDER BY name ASC;

-- INNER JOIN --
SELECT task_categories.id, task_categories.name, user_id -- user_id == task_categories.creator_id
	FROM task_categories
	INNER JOIN tasks ON task_categories.user_id = tasks.creator_id
	ORDER BY user_id ASC;

SELECT *
	FROM task_categories
	INNER JOIN tasks ON task_categories.workspace_id = tasks.workspace_id;

-- LEFT JOIN --
SELECT *
	FROM task_categories
	LEFT JOIN tasks ON task_categories.workspace_id = tasks.workspace_id;

-- RIGHT JOIN --
SELECT *
	FROM task_categories
	RIGHT JOIN tasks ON task_categories.workspace_id = tasks.workspace_id;

-- FULL JOIN --
SELECT *
	FROM task_categories
	FULL JOIN tasks ON task_categories.workspace_id = tasks.workspace_id;

-- CROSS JOIN -- 
SELECT *
	FROM task_categories
	CROSS JOIN tasks;