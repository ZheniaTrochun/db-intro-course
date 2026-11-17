--- workspaces ---
-- COUNT --
SELECT COUNT(*)
FROM workspaces;

SELECT COUNT(DISTINCT owner_id)
FROM workspaces;

-- DISTINCT + ORDER BY --
SELECT DISTINCT status
FROM workspaces
ORDER BY status ASC;

-- WHERE --
SELECT id, name, status --
FROM workspaces-- 
WHERE deleted_at IS NULL; -- исправить 

-- GROUP BY --
SELECT status, COUNT(*) AS total
FROM workspaces
GROUP BY status
ORDER BY total DESC;

-- INNER JOIN --
SELECT w.id, w.name, u.nickname AS owner
FROM workspaces w
INNER JOIN users u ON u.id = w.owner_id
ORDER BY w.id ASC;

-- LEFT JOIN --
SELECT u.nickname, w.name
FROM users u
LEFT JOIN workspaces w ON w.owner_id = u.id;

-- RIGHT JOIN --
SELECT u.nickname, w.name
FROM users u
RIGHT JOIN workspaces w ON w.owner_id = u.id;

-- FULL JOIN --
SELECT w.name, wm.user_id, wm.role
FROM workspaces w
FULL JOIN workspace_members wm ON wm.workspace_id = w.id;

-- CROSS JOIN --
SELECT u.nickname, w.name
FROM users u
CROSS JOIN workspaces w;

--- workspace_members ---
-- COUNT --
SELECT COUNT(*)
FROM workspace_members;

SELECT COUNT(DISTINCT user_id)
FROM workspace_members;

-- DISTINCT + ORDER BY --
SELECT DISTINCT role
FROM workspace_members
ORDER BY role ASC;

-- WHERE --
SELECT *
FROM workspace_members
WHERE status = 'ACTIVE';

-- GROUP BY --
SELECT workspace_id, COUNT(*) AS members_count
FROM workspace_members
GROUP BY workspace_id
ORDER BY workspace_id ASC;

-- HAVING --
SELECT workspace_id, COUNT(*) AS members_count
FROM workspace_members
GROUP BY workspace_id
HAVING COUNT(*) > 1;

-- INNER JOIN --
SELECT wm.workspace_id, u.nickname, wm.role
FROM workspace_members wm
INNER JOIN users u ON u.id = wm.user_id
ORDER BY wm.workspace_id ASC;

-- LEFT JOIN --
SELECT u.nickname, wm.workspace_id, wm.role
FROM users u
LEFT JOIN workspace_members wm ON wm.user_id = u.id;

-- RIGHT JOIN --
SELECT u.nickname, wm.workspace_id, wm.role
FROM users u
RIGHT JOIN workspace_members wm ON wm.user_id = u.id;

-- FULL JOIN --
SELECT u.nickname, wm.workspace_id, wm.role
FROM users u
FULL JOIN workspace_members wm ON wm.user_id = u.id;

-- CROSS JOIN --
SELECT u.nickname, wm.workspace_id
FROM users u
CROSS JOIN workspace_members wm;