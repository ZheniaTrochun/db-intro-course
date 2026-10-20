INSERT INTO users (name, nickname, phone_number, password, email, timezone)
VALUES
        ('Dmitry', 'dmitry42', '+123123', 'hashed_password_1', 'dmitry@example.com', 'Europe/Kyiv'),
    ('Alex', 'alex_dev', '+29357923398', 'hashed_password_2', 'alex@example.com', 'Europe/Berlin'),
    ('Maria', 'maria_k', '+39058239300', 'hashed_password_3', 'maria@example.com', 'Europe/Amsterdam');


INSERT INTO workspaces (owner_id, name, description, status)
VALUES
    (1, 'Personal Projects', 'Workspace for personal projects', 'ACTIVE'),
    (1, 'University', 'University tasks and assignments', 'ACTIVE'),
    (2, 'Development Team', 'Collaborative software development', 'ACTIVE');


INSERT INTO task_categories (user_id, workspace_id, name, color)
VALUES
    (1, 1, 'Development', '#3498db'),
    (1, 2, 'Study', '#2ecc71'),
    (2, 3, 'Bug Fixes', '#e74c3c');


INSERT INTO tasks (
    name, description, status, priority,
    creator_id, assignee_id, workspace_id, category_id, deadline
)
VALUES
    (
        'Implement authentication',
        'Add JWT authentication to the application',
        'in_progress', 1,
        1, 1, 1, 1, CURRENT_TIMESTAMP + INTERVAL '7 days'
    ),
    (
        'Complete mathematics assignment',
        'Solve the assigned exercises',
        'open', 2,
        1, 1, 2, 2, CURRENT_TIMESTAMP + INTERVAL '3 days'
    ),
    (
        'Fix login bug',
        'Investigate and fix the login issue',
        'done', 1,
        2, 1, 3, 3, CURRENT_TIMESTAMP + INTERVAL '1 day'
    );

INSERT INTO workspace_members (user_id, workspace_id, role, status)
VALUES
    (1, 1, 'OWNER', 'ACTIVE'),
    (1, 2, 'OWNER', 'ACTIVE'),
    (2, 3, 'OWNER', 'ACTIVE'),
    (1, 3, 'MEMBER', 'ACTIVE'),
    (3, 3, 'MEMBER', 'INVITED');


INSERT INTO habits_categories (user_id, name, color)
VALUES
    (1, 'Health', '#2ecc71'),
    (1, 'Learning', '#3498db'),
    (2, 'Productivity', '#f39c12');


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

INSERT INTO habit_completions (
    habit_id, local_timestamp, completed_at, actual_value, note, status
)
VALUES
    (
        1, CURRENT_DATE + TIME '07:30:00',
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
