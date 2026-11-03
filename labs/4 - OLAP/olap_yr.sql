--- tasks ---
-- Compare users by their share of assigned tasks in a workspace.
WITH assignee_workload AS (
    SELECT assignee_id,
       SUM(COUNT(*)) OVER () AS total_tasks,
       COUNT(*) AS assignee_tasks,
       COUNT(*)::float / (SUM(COUNT(*)) OVER ())::float AS assignee_ratio
    FROM tasks
    WHERE workspace_id = :workspace_id AND assignee_id IS NOT NULL
    GROUP BY assignee_id
    HAVING COUNT(*) IS NOT NULL
)
SELECT *, MAX(assignee_ratio) OVER () as max_ration, MIN(assignee_ratio) OVER () as min_ratio
FROM assignee_workload
ORDER BY assignee_ratio DESC
LIMIT :n_users;


--- workspace ---
-- Compare workspace sizes among workspaces with the same number of timezones.
WITH workspace_timezones AS (
    SELECT workspaces.id,
           workspaces.name,
           COUNT(DISTINCT timezone) as distinct_timezones,
           COUNT(*) as participants_count
    FROM workspace_members
    JOIN users on workspace_members.user_id = users.id
    JOIN workspaces ON workspaces.id = workspace_members.workspace_id
    GROUP BY workspaces.id, workspaces.name
)
SELECT workspace_timezones.name,
       distinct_timezones,
       ROUND(AVG(participants_count) OVER distinct_timezones_partition, 2) AS average_participants_by_distinct_number_of_timezones,
       participants_count
FROM workspace_timezones
WINDOW distinct_timezones_partition AS (PARTITION BY distinct_timezones)
ORDER BY distinct_timezones, participants_count DESC;

--- workspace_members --- 
-- Compare each workspace member's assigned tasks with the group average.
SELECT u.name, u.email,
       COUNT(*) assigned_tasks,
        (
            SELECT COUNT(*)
            FROM tasks
            WHERE tasks.workspace_id = :workspace_id
                AND tasks.creator_id = workspace_members.user_id
                AND tasks.workspace_id IS NOT NULL
                AND tasks.deleted_at IS NULL
        ) created_tasks,
        AVG(COUNT(*)) OVER () average_assigned_tasks,
        ABS(COUNT(*) - (AVG(COUNT(*)) OVER ())) deviation_from_avg_tasks_assigned
FROM workspace_members
LEFT JOIN users u ON workspace_members.user_id = u.id
JOIN tasks ON workspace_members.user_id = tasks.assignee_id
WHERE workspace_members.workspace_id = :workspace_id
      AND tasks.workspace_id IS NOT NULL
      AND workspace_members.user_id = tasks.assignee_id
      AND workspace_members.status != 'DEACTIVATED'
GROUP BY u.name, u.email, workspace_members.user_id;

--- habits_completions ---
-- Show how a user's habit completions are distributed by status.
SELECT completion_status,
       count(*) completions
FROM (
    SELECT hc.id, habit_id, hc.status completion_status
    FROM habit_completions hc
    INNER JOIN habits h ON hc.habit_id = h.id
    WHERE h.creator_id = :user_id
) completions
GROUP BY completion_status;