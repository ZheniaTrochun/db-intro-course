-- =====================================================================
-- Randomized, correlated seed data
-- Helper functions public.rnd/public.dil and table seed_topics are created and dropped by this script.
-- To regenerate from scratch, uncomment:
-- TRUNCATE habit_completions, habits, tasks, task_categories, habits_categories,
--          workspace_members, workspaces, users RESTART IDENTITY CASCADE;
-- =====================================================================


-- Deterministic pseudo-random in [0,1) from a text key
CREATE OR REPLACE FUNCTION public.rnd(key text) RETURNS double precision
LANGUAGE sql IMMUTABLE AS $$
    SELECT (hashtextextended(key, 7) & 2147483647) / 2147483648.0
$$;

-- Hidden per-user "diligence" factor in ~[0.1, 0.95]
CREATE OR REPLACE FUNCTION public.dil(nick text) RETURNS double precision
LANGUAGE sql IMMUTABLE AS $$
    SELECT 0.1 + 0.85 * (0.55 * public.rnd('dA' || nick) + 0.45 * power(public.rnd('dB' || nick), 2))
$$;

-- Text pools
DROP TABLE IF EXISTS seed_topics;
CREATE TABLE seed_topics (topic int, kind text, txt text);
INSERT INTO seed_topics (topic, kind, txt) VALUES
 (0,'ws_desc','Product development and planning'),
 (1,'ws_desc','University tasks and assignments'),
 (2,'ws_desc','Personal projects and goals'),
 (3,'ws_desc','Research and technical investigations'),

 (0,'task_name','Implement authentication'),(0,'task_name','Fix login bug'),(0,'task_name','Prepare release notes'),
 (0,'task_name','Optimize database queries'),(0,'task_name','Add unit tests'),(0,'task_name','Collect user feedback'),
 (0,'task_name','Refactor payment module'),(0,'task_name','Set up CI pipeline'),(0,'task_name','Review pull request'),
 (0,'task_name','Design onboarding flow'),(0,'task_name','Update API documentation'),(0,'task_name','Investigate memory leak'),
 (1,'task_name','Complete database lab report'),(1,'task_name','Prepare for midterm exam'),(1,'task_name','Write course essay'),
 (1,'task_name','Submit group project milestone'),(1,'task_name','Review lecture notes'),(1,'task_name','Solve problem set'),
 (1,'task_name','Prepare presentation slides'),(1,'task_name','Read assigned paper'),
 (2,'task_name','Practice technical interviews'),(2,'task_name','Update resume'),(2,'task_name','Plan trip itinerary'),
 (2,'task_name','Organize home finances'),(2,'task_name','Learn a new framework'),(2,'task_name','Write blog post'),
 (2,'task_name','Refresh portfolio website'),(2,'task_name','Book medical checkup'),
 (3,'task_name','Benchmark query performance'),(3,'task_name','Survey related work'),(3,'task_name','Reproduce experiment results'),
 (3,'task_name','Analyze collected metrics'),(3,'task_name','Draft research summary'),(3,'task_name','Evaluate indexing strategies'),
 (3,'task_name','Validate dataset quality'),(3,'task_name','Compare caching approaches'),

 (0,'task_desc','Add and test the requested functionality'),(0,'task_desc','Coordinate changes with the project team'),
 (0,'task_desc','Validate behavior and update related documentation'),(0,'task_desc','Review the current implementation and document findings'),
 (1,'task_desc','Follow the course requirements and submit before the deadline'),(1,'task_desc','Collect materials and structure the final answer'),
 (1,'task_desc','Check the work against the grading rubric'),(1,'task_desc','Discuss open questions with the study group'),
 (2,'task_desc','Break the goal into small steps and schedule them'),(2,'task_desc','Set aside focused time during the week'),
 (2,'task_desc','Track progress and adjust the plan'),(2,'task_desc','Keep the result simple and finish it'),
 (3,'task_desc','Document methodology and record the observations'),(3,'task_desc','Compare results against the baseline'),
 (3,'task_desc','Collect measurements and note anomalies'),(3,'task_desc','Summarize findings for the team'),

 (0,'cat_name','Backend'),(0,'cat_name','Frontend'),(0,'cat_name','QA'),(0,'cat_name','DevOps'),(0,'cat_name','Design'),(0,'cat_name','Planning'),
 (1,'cat_name','Lectures'),(1,'cat_name','Labs'),(1,'cat_name','Exams'),(1,'cat_name','Essays'),(1,'cat_name','Group work'),(1,'cat_name','Reading'),
 (2,'cat_name','Career'),(2,'cat_name','Finance'),(2,'cat_name','Travel'),(2,'cat_name','Home'),(2,'cat_name','Self-study'),(2,'cat_name','Health admin'),
 (3,'cat_name','Experiments'),(3,'cat_name','Literature'),(3,'cat_name','Data'),(3,'cat_name','Analysis'),(3,'cat_name','Writing'),(3,'cat_name','Tooling'),

 (10,'habit_desc','Run for at least 30 minutes'),(10,'habit_desc','Drink enough water'),(10,'habit_desc','Do a short stretching routine'),
 (10,'habit_desc','Walk at least 8000 steps'),(10,'habit_desc','Go to bed before midnight'),
 (11,'habit_desc','Read at least 20 pages'),(11,'habit_desc','Practice a new skill'),(11,'habit_desc','Review flashcards for a language'),
 (11,'habit_desc','Watch one lecture or course video'),(11,'habit_desc','Solve a coding exercise'),
 (12,'habit_desc','Meditate and reflect'),(12,'habit_desc','Plan the day and set priorities'),(12,'habit_desc','Write a short journal entry'),
 (12,'habit_desc','Spend an hour without screens'),(12,'habit_desc','Call a friend or relative'),

 (0,'note_done','Completed the full routine'),(0,'note_done','Felt good today'),(0,'note_done','Did a bit more than planned'),
 (0,'note_done','Finished early'),(0,'note_done','Kept the streak going'),
 (0,'note_part','Completed part of the planned routine'),(0,'note_part','Ran out of time'),(0,'note_part','Low energy, did the minimum'),
 (0,'note_part','Got interrupted halfway'),
 (0,'note_skip','Skipped due to schedule conflict'),(0,'note_skip','Traveling today'),(0,'note_skip','Not feeling well'),
 (0,'note_skip','Deadline at work'),(0,'note_skip','Rest day');

-- =====================================================================
-- USERS (120)
-- =====================================================================
INSERT INTO users (name, nickname, phone_number, password, email, timezone, created_at)
SELECT
    (CASE WHEN rnd('un0' || n) < (CASE WHEN tz.zone = 'Europe/Kyiv' THEN 0.85 ELSE 0.15 END)
          THEN (ARRAY['Dmitry','Olena','Ivan','Nazar','Iryna','Oleh','Kateryna','Taras','Yulia','Andrii'])[1 + floor(rnd('un1' || n) * 10)::int]
          ELSE (ARRAY['Alex','Maria','Sofia','Emma','Mark','Leo','Anna','Daniel','Julia','Noah'])[1 + floor(rnd('un2' || n) * 10)::int]
     END)
    || ' ' ||
    (ARRAY['Kovalenko','Shevchenko','Bondar','Mueller','Jansen','Tanaka','Smith','Nowak','Brown','Melnyk','Kravets','Lee'])[1 + floor(rnd('un3' || n) * 12)::int],
    'user_' || lpad(n::text, 4, '0'),
    CASE tz.zone
        WHEN 'Europe/Kyiv'      THEN '+380' || (ARRAY['50','67','63','93','66'])[1 + floor(rnd('uo' || n) * 5)::int]
        WHEN 'Europe/Berlin'    THEN '+49151'
        WHEN 'Europe/Amsterdam' THEN '+316'
        WHEN 'Europe/Warsaw'    THEN '+4850'
        WHEN 'Europe/London'    THEN '+447'
        WHEN 'Asia/Tokyo'       THEN '+8190'
        ELSE '+1'
    END || lpad(n::text, 4, '0') || lpad(floor(rnd('up' || n) * 1000)::int::text, 3, '0'),
    'seeded_password_hash_not_for_login',
    'user_' || lpad(n::text, 4, '0') || '@example.test',
    tz.zone,
    CURRENT_TIMESTAMP
        - (CASE WHEN rnd('uc0' || n) < 0.35 THEN rnd('uc1' || n) * 220 ELSE rnd('uc2' || n) * 1200 END) * INTERVAL '1 day'
        - rnd('uc3' || n) * INTERVAL '1 day'
FROM generate_series(1, 120) AS g(n)
CROSS JOIN LATERAL (
    SELECT (ARRAY['Europe/Kyiv','Europe/Kyiv','Europe/Kyiv','Europe/Kyiv','Europe/Berlin','Europe/Berlin',
                  'Europe/Amsterdam','America/Toronto','America/New_York','America/New_York','Asia/Tokyo',
                  'Europe/Warsaw','Europe/London'])[1 + floor(rnd('utz' || n) * 13)::int] AS zone
) tz
ON CONFLICT DO NOTHING;

-- =====================================================================
-- WORKSPACES (15)
-- =====================================================================
INSERT INTO workspaces (owner_id, name, description, status, created_at)
SELECT
    o.id,
    'Workspace ' || lpad(n::text, 3, '0'),
    d.txt,
    CASE
        WHEN rnd('ws1' || n) < 0.03 + 0.15 * af.v THEN 'ARCHIVED'
        WHEN rnd('ws1' || n) < 0.08 + 0.15 * af.v THEN 'SUSPENDED'
        ELSE 'ACTIVE'
    END,
    c.created_at
FROM generate_series(1, 15) AS g(n)
CROSS JOIN LATERAL (
    SELECT u.id, u.created_at
    FROM users u
    WHERE u.nickname ~ '^user_[0-9]{4}$' AND u.created_at < CURRENT_TIMESTAMP - INTERVAL '30 days'
    ORDER BY rnd('wo' || g.n || '_' || u.id::text) * (0.25 + dil(u.nickname)) DESC
    LIMIT 1
) o
CROSS JOIN LATERAL (
    SELECT o.created_at + (CURRENT_TIMESTAMP - o.created_at) * (0.05 + 0.8 * rnd('wc' || g.n)) AS created_at
) c
CROSS JOIN LATERAL (
    SELECT (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - c.created_at)) / 86400.0 / 1200.0)::double precision AS v
) af
CROSS JOIN LATERAL (
    SELECT s.txt FROM seed_topics s WHERE s.kind = 'ws_desc' ORDER BY rnd('wd' || g.n || s.txt) LIMIT 1
) d
WHERE NOT EXISTS (
    SELECT 1 FROM workspaces e WHERE e.name = 'Workspace ' || lpad(n::text, 3, '0')
);

-- =====================================================================
-- WORKSPACE MEMBERS (random size per workspace, owner always included)
-- =====================================================================
INSERT INTO workspace_members (user_id, workspace_id, role, status, joined_at)
SELECT
    u.id,
    w.id,
    CASE WHEN u.id = w.owner_id THEN 'OWNER'
         WHEN rnd('mr' || w.id::text || '_' || u.id::text) < 0.10 THEN 'ADMIN'
         WHEN rnd('mr' || w.id::text || '_' || u.id::text) < 0.70 THEN 'MEMBER'
         ELSE 'GUEST' END,
    CASE WHEN u.id = w.owner_id THEN 'ACTIVE'
         WHEN rnd('ms' || w.id::text || '_' || u.id::text) < 0.06 THEN 'DEACTIVATED'
         WHEN rnd('ms' || w.id::text || '_' || u.id::text) < 0.14 THEN 'INVITED'
         ELSE 'ACTIVE' END,
    CASE WHEN u.id = w.owner_id THEN w.created_at
         ELSE j.since + (CURRENT_TIMESTAMP - j.since) * power(rnd('mj' || w.id::text || '_' || u.id::text), 2)
    END
FROM workspaces w
CROSS JOIN generate_series(1, 120) AS un(n)
JOIN users u ON u.nickname = 'user_' || lpad(un.n::text, 4, '0')
CROSS JOIN LATERAL (SELECT GREATEST(w.created_at, u.created_at) AS since) j
WHERE w.name ~ '^Workspace [0-9]{3}$'
  AND (u.id = w.owner_id
       OR rnd('m' || w.id::text || '_' || u.id::text) < 0.04 + 0.13 * rnd('wsz' || w.id::text))
ON CONFLICT (user_id, workspace_id) DO NOTHING;

-- =====================================================================
-- TASK CATEGORIES: workspace categories + personal categories
-- =====================================================================
INSERT INTO task_categories (user_id, workspace_id, name, color, created_at, deleted_at, updated_at)
SELECT
    w.owner_id,
    w.id,
    s.txt || ' (WS' || right(w.name, 3) || ')',
    (ARRAY['#3498db','#2ecc71','#e74c3c','#f39c12','#9b59b6','#1abc9c','#e67e22','#34495e'])[1 + floor(rnd('cl' || w.id::text || s.txt) * 8)::int],
    cr.created_at,
    dl.deleted_at,
    COALESCE(dl.deleted_at, cr.created_at + (CURRENT_TIMESTAMP - cr.created_at) * rnd('cu' || w.id::text || s.txt))
FROM workspaces w
JOIN seed_topics s
  ON s.kind = 'cat_name'
 AND s.topic = COALESCE((SELECT t.topic FROM seed_topics t WHERE t.kind = 'ws_desc' AND t.txt = w.description LIMIT 1), 0)
CROSS JOIN LATERAL (
    SELECT w.created_at + (CURRENT_TIMESTAMP - w.created_at) * 0.15 * rnd('cc' || w.id::text || s.txt) AS created_at
) cr
CROSS JOIN LATERAL (
    SELECT CASE WHEN rnd('cd' || w.id::text || s.txt) < 0.07
                THEN cr.created_at + (CURRENT_TIMESTAMP - cr.created_at) * (0.3 + 0.6 * rnd('cd2' || w.id::text || s.txt)) END AS deleted_at
) dl
WHERE w.name ~ '^Workspace [0-9]{3}$'
  AND rnd('ci' || w.id::text || s.txt) < 0.6
  AND NOT EXISTS (
      SELECT 1 FROM task_categories e
      WHERE e.workspace_id = w.id AND e.name = s.txt || ' (WS' || right(w.name, 3) || ')'
  );

INSERT INTO task_categories (user_id, workspace_id, name, color, created_at, deleted_at, updated_at)
SELECT
    u.id,
    NULL,
    s.txt || ' (' || u.nickname || ')',
    (ARRAY['#3498db','#2ecc71','#e74c3c','#f39c12','#9b59b6','#1abc9c','#e67e22','#34495e'])[1 + floor(rnd('pl' || u.id::text || s.txt) * 8)::int],
    cr.created_at,
    dl.deleted_at,
    COALESCE(dl.deleted_at, cr.created_at + (CURRENT_TIMESTAMP - cr.created_at) * rnd('pu' || u.id::text || s.txt))
FROM users u
JOIN seed_topics s ON s.kind = 'cat_name' AND s.topic = 2
CROSS JOIN LATERAL (
    SELECT u.created_at + (CURRENT_TIMESTAMP - u.created_at) * 0.3 * rnd('pc' || u.id::text || s.txt) AS created_at
) cr
CROSS JOIN LATERAL (
    SELECT CASE WHEN rnd('pd' || u.id::text || s.txt) < 0.06
                THEN cr.created_at + (CURRENT_TIMESTAMP - cr.created_at) * (0.3 + 0.6 * rnd('pd2' || u.id::text || s.txt)) END AS deleted_at
) dl
WHERE u.nickname ~ '^user_[0-9]{4}$'
  AND rnd('pi' || u.id::text || s.txt) < 0.10 + 0.22 * dil(u.nickname)
  AND NOT EXISTS (
      SELECT 1 FROM task_categories e
      WHERE e.user_id = u.id AND e.workspace_id IS NULL AND e.name = s.txt || ' (' || u.nickname || ')'
  );

-- =====================================================================
-- HABIT CATEGORIES
-- =====================================================================
INSERT INTO habits_categories (user_id, name, color, created_at, deleted_at, updated_at)
SELECT
    u.id,
    c.name,
    c.color,
    cr.created_at,
    dl.deleted_at,
    COALESCE(dl.deleted_at, cr.created_at + (CURRENT_TIMESTAMP - cr.created_at) * rnd('hcu' || un.n || c.name))
FROM generate_series(1, 120) AS un(n)
CROSS JOIN (VALUES ('Health','#2ecc71',0.85), ('Learning','#3498db',0.65), ('Wellbeing','#f39c12',0.55)) AS c(name, color, p)
JOIN users u ON u.nickname = 'user_' || lpad(un.n::text, 4, '0')
CROSS JOIN LATERAL (
    SELECT u.created_at + (CURRENT_TIMESTAMP - u.created_at) * 0.3 * rnd('hcc' || un.n || c.name) AS created_at
) cr
CROSS JOIN LATERAL (
    SELECT CASE WHEN rnd('hcd' || un.n || c.name) < 0.05
                THEN cr.created_at + (CURRENT_TIMESTAMP - cr.created_at) * (0.3 + 0.6 * rnd('hcd2' || un.n || c.name)) END AS deleted_at
) dl
WHERE rnd('hci' || un.n || c.name) < c.p + 0.1 * (dil(u.nickname) - 0.5)
  AND NOT EXISTS (
      SELECT 1 FROM habits_categories e WHERE e.user_id = u.id AND e.name = c.name
  );

-- =====================================================================
-- TASKS (2500)
-- =====================================================================
INSERT INTO tasks (
    name, description, status, priority, creator_id, assignee_id, workspace_id, category_id,
    created_at, deadline, deleted_at, updated_at
)
WITH base AS (
    SELECT n, (rnd('tp' || n) < 0.18) AS personal
    FROM generate_series(1, 2500) AS g(n)
),
wp AS (
    SELECT b.n, b.personal, w.id AS workspace_id, w.created_at AS w_created, w.topic
    FROM base b
    LEFT JOIN LATERAL (
        SELECT ws.id, ws.created_at,
               COALESCE((SELECT st.topic FROM seed_topics st WHERE st.kind = 'ws_desc' AND st.txt = ws.description LIMIT 1), 0) AS topic
        FROM workspaces ws
        WHERE NOT b.personal AND ws.name ~ '^Workspace [0-9]{3}$'
        ORDER BY rnd('tw' || b.n || '_' || ws.id::text) * (0.3 + rnd('ww' || ws.id::text)) DESC
        LIMIT 1
    ) w ON true
),
people AS (
    SELECT wp.*,
        COALESCE(cm.id, pu.id)            AS creator_id,
        COALESCE(cm.nick, pu.nickname)    AS creator_nick,
        COALESCE(cm.since, pu.created_at) AS creator_since,
        CASE WHEN rnd('tan' || wp.n) < 0.11 THEN NULL WHEN wp.personal THEN pu.id ELSE am.id END AS assignee_id,
        CASE WHEN rnd('tan' || wp.n) < 0.11 THEN NULL WHEN wp.personal THEN pu.nickname ELSE am.nick END AS assignee_nick,
        CASE WHEN rnd('tan' || wp.n) < 0.11 THEN NULL WHEN wp.personal THEN pu.created_at ELSE am.since END AS assignee_since
    FROM wp
    LEFT JOIN LATERAL (
        SELECT u.id, u.nickname AS nick, m.joined_at AS since
        FROM workspace_members m JOIN users u ON u.id = m.user_id
        WHERE m.workspace_id = wp.workspace_id AND m.status = 'ACTIVE'
        ORDER BY rnd('tcr' || wp.n || '_' || u.id::text)
                 * (CASE m.role WHEN 'OWNER' THEN 1.0 WHEN 'ADMIN' THEN 1.2 WHEN 'MEMBER' THEN 1.0 ELSE 0.35 END)
                 * (0.4 + dil(u.nickname)) DESC
        LIMIT 1
    ) cm ON true
    LEFT JOIN LATERAL (
        SELECT u.id, u.nickname AS nick, m.joined_at AS since
        FROM workspace_members m JOIN users u ON u.id = m.user_id
        WHERE m.workspace_id = wp.workspace_id AND m.status = 'ACTIVE'
        ORDER BY rnd('tas' || wp.n || '_' || u.id::text)
                 * (CASE m.role WHEN 'OWNER' THEN 0.7 WHEN 'ADMIN' THEN 0.9 WHEN 'MEMBER' THEN 1.0 ELSE 0.2 END)
                 * (0.3 + dil(u.nickname)) DESC
        LIMIT 1
    ) am ON true
    LEFT JOIN users pu
        ON wp.personal
       AND pu.nickname = 'user_' || lpad((1 + floor(rnd('tpu' || wp.n) * 120))::int::text, 4, '0')
),
timed AS (
    SELECT p.*,
        bs.base + (CURRENT_TIMESTAMP - bs.base) * (0.6 * rnd('tc1' || p.n) + 0.4 * power(rnd('tc2' || p.n), 2)) AS created_at,
        CASE WHEN p.personal THEN (CASE WHEN rnd('tpt' || p.n) < 0.7 THEN 2 ELSE 1 END)
             ELSE COALESCE(p.topic, 0) END AS tp
    FROM people p
    CROSS JOIN LATERAL (SELECT GREATEST(p.creator_since, p.assignee_since) AS base) bs
    WHERE p.creator_id IS NOT NULL
),
s1 AS (
    SELECT t.*, x.age, x.d,
        CASE WHEN x.pr < 0.09 + x.sft THEN 1
             WHEN x.pr < 0.31 + x.sft THEN 2
             WHEN x.pr < 0.68 + x.sft THEN 3
             WHEN x.pr < 0.88 + x.sft THEN 4
             ELSE 5 END AS prio
    FROM timed t
    CROSS JOIN LATERAL (
        SELECT (EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - t.created_at)) / 86400.0)::double precision AS age,
               dil(COALESCE(t.assignee_nick, t.creator_nick)) AS d,
               (rnd('wp' || COALESCE(t.workspace_id::text, 'p')) - 0.5) * 0.2 AS sft,
               rnd('tpr' || t.n) AS pr
    ) x
),
s2 AS (
    SELECT s.*,
        LEAST(0.97, (s.age / (s.age + 25 + 95 * (1 - s.d))) * (0.7 + 0.3 * s.d) * (0.9 + 0.04 * s.prio)) AS fp,
        s.created_at + (((2 + 40 * power(rnd('td' || s.n), 1.3)) * (1.35::double precision - 0.17 * s.prio)
                         + 4 * rnd('td2' || s.n)) * INTERVAL '1 day') AS deadline
    FROM s1 s
),
s3 AS (
    SELECT s.*,
        CASE
            WHEN rnd('ts' || s.n) < s.fp * 0.82 THEN 'done'
            WHEN rnd('ts' || s.n) < s.fp        THEN 'closed'
            WHEN rnd('tx' || s.n) < 0.06        THEN 'cancelled'
            WHEN s.assignee_id IS NOT NULL
                 AND rnd('ty' || s.n) < 0.15 + 0.55 * exp(-s.age / 80.0) THEN 'in_progress'
            ELSE 'open'
        END AS status
    FROM s2 s
),
fin AS (
    SELECT s.*, nm.task_name, dl.deleted_at,
        COALESCE(dl.deleted_at,
            CASE WHEN s.status = 'done'
                 THEN s.created_at + LEAST(CURRENT_TIMESTAMP - s.created_at,
                                           (s.deadline - s.created_at) * (0.25 + 0.95 * rnd('tu1' || s.n)))
                 ELSE s.created_at + (CURRENT_TIMESTAMP - s.created_at) * (0.1 + 0.9 * rnd('tu2' || s.n))
            END) AS updated_at
    FROM s3 s
    CROSS JOIN LATERAL (
        SELECT (SELECT s2.txt FROM seed_topics s2
                WHERE s2.kind = 'task_name' AND s2.topic = s.tp
                ORDER BY rnd('tn' || s.n || '_' || s2.txt) LIMIT 1) || ' #' || s.n AS task_name
    ) nm
    CROSS JOIN LATERAL (
        SELECT CASE WHEN (s.status IN ('cancelled', 'closed') AND rnd('tdl1' || s.n) < 0.85)
                      OR rnd('tdl2' || s.n) < 0.012
                    THEN s.created_at + (CURRENT_TIMESTAMP - s.created_at) * (0.5 + 0.5 * rnd('tdl3' || s.n))
               END AS deleted_at
    ) dl
)
SELECT
    f.task_name,
    (SELECT s4.txt FROM seed_topics s4 WHERE s4.kind = 'task_desc' AND s4.topic = f.tp
     ORDER BY rnd('tdd' || f.n || '_' || s4.txt) LIMIT 1),
    f.status,
    f.prio,
    f.creator_id,
    f.assignee_id,
    f.workspace_id,
    CASE WHEN rnd('tcn' || f.n) < (CASE WHEN f.workspace_id IS NULL THEN 0.55 ELSE 0.10 END)
         THEN NULL ELSE cat.id END,
    f.created_at,
    f.deadline,
    f.deleted_at,
    f.updated_at
FROM fin f
LEFT JOIN LATERAL (
    SELECT tc.id
    FROM task_categories tc
    WHERE tc.deleted_at IS NULL
      AND ((f.workspace_id IS NOT NULL AND tc.workspace_id = f.workspace_id)
        OR (f.workspace_id IS NULL AND tc.workspace_id IS NULL AND tc.user_id = f.creator_id))
    ORDER BY rnd('tcat' || f.n || '_' || tc.id::text) DESC
    LIMIT 1
) cat ON true
WHERE NOT EXISTS (SELECT 1 FROM tasks e WHERE e.name = f.task_name);

-- =====================================================================
-- HABITS (400)
-- =====================================================================
INSERT INTO habits (
    name, description, creator_id, category_id, timezone, frequency_days, status,
    start_day, end_day, created_at, deleted_at, updated_at
)
WITH pick AS (
    SELECT g.n, c.id AS category_id, c.user_id, c.cat_name, c.timezone, c.nickname, c.u_created
    FROM generate_series(1, 400) AS g(n)
    CROSS JOIN LATERAL (
        SELECT hc.id, hc.user_id, hc.name AS cat_name, u.timezone, u.nickname, u.created_at AS u_created
        FROM habits_categories hc JOIN users u ON u.id = hc.user_id
        WHERE hc.deleted_at IS NULL
          AND hc.name IN ('Health', 'Learning', 'Wellbeing')
          AND u.nickname ~ '^user_[0-9]{4}$'
        ORDER BY rnd('hp' || g.n || '_' || hc.id::text) * (0.15 + dil(u.nickname))
                 * (CASE hc.name WHEN 'Health' THEN 1.2 WHEN 'Learning' THEN 1.0 ELSE 0.8 END) DESC
        LIMIT 1
    ) c
),
h1 AS (
    SELECT p.*,
        CASE p.cat_name WHEN 'Health' THEN 0 WHEN 'Learning' THEN 1 ELSE 2 END AS ci,
        dil(p.nickname) AS d,
        CURRENT_DATE - floor(LEAST(800, CURRENT_DATE - p.u_created::date)
                             * (0.75 * rnd('hs1' || p.n) + 0.25 * power(rnd('hs2' || p.n), 3)))::int AS start_day
    FROM pick p
),
h2 AS (
    SELECT h.*,
        CASE WHEN r.v < 0.04                       THEN 'DRAFT'
             WHEN r.v < 0.04 + 0.20 * (1 - h.d)    THEN 'DROPPED'
             WHEN r.v < 0.10 + 0.20 * (1 - h.d)    THEN 'PAUSED'
             WHEN r.v < 0.15 + 0.20 * (1 - h.d)    THEN 'ARCHIVED'
             ELSE 'ACTIVE' END AS status,
        1 + floor(8 * LEAST(0.999, GREATEST(0.0, rnd('hf' || h.n) + (h.ci - 1) * 0.1)))::int AS fidx
    FROM h1 h
    CROSS JOIN LATERAL (SELECT rnd('hst' || h.n) AS v) r
),
h3 AS (
    SELECT h.*,
        CASE WHEN h.status IN ('DROPPED', 'ARCHIVED')
             THEN LEAST(CURRENT_DATE, h.start_day + 20 + floor(rnd('he' || h.n) * 220)::int) END AS end_day,
        GREATEST(h.u_created, h.start_day::timestamptz - rnd('hcr' || h.n) * INTERVAL '4 days'
                              + rnd('hch' || h.n) * INTERVAL '10 hours') AS created_raw
    FROM h2 h
)
SELECT
    'Habit ' || lpad(h.n::text, 4, '0'),
    (SELECT s.txt FROM seed_topics s WHERE s.kind = 'habit_desc' AND s.topic = 10 + h.ci
     ORDER BY rnd('hd' || h.n || '_' || s.txt) LIMIT 1),
    h.user_id,
    h.category_id,
    h.timezone,
    CASE h.fidx
        WHEN 1 THEN ARRAY[1,2,3,4,5,6,7]::SMALLINT[]
        WHEN 2 THEN ARRAY[1,2,3,4,5,6,7]::SMALLINT[]
        WHEN 3 THEN ARRAY[1,2,3,4,5]::SMALLINT[]
        WHEN 4 THEN ARRAY[1,3,5]::SMALLINT[]
        WHEN 5 THEN ARRAY[2,4,6]::SMALLINT[]
        WHEN 6 THEN ARRAY[1,2,3,4,5,6]::SMALLINT[]
        WHEN 7 THEN ARRAY[6,7]::SMALLINT[]
        ELSE ARRAY[1,2,4,5]::SMALLINT[]
    END,
    h.status,
    h.start_day,
    h.end_day,
    LEAST(CURRENT_TIMESTAMP, h.created_raw),
    dl.deleted_at,
    COALESCE(dl.deleted_at, cr.created_at + (CURRENT_TIMESTAMP - cr.created_at) * (0.2 + 0.8 * rnd('hu' || h.n)))
FROM h3 h
CROSS JOIN LATERAL (SELECT LEAST(CURRENT_TIMESTAMP, h.created_raw) AS created_at) cr
CROSS JOIN LATERAL (
    SELECT CASE WHEN (h.status IN ('ARCHIVED', 'DROPPED') AND rnd('hdl1' || h.n) < 0.14)
                  OR rnd('hdl2' || h.n) < 0.015
                THEN cr.created_at + (CURRENT_TIMESTAMP - cr.created_at) * (0.4 + 0.6 * rnd('hdl3' || h.n))
           END AS deleted_at
) dl
WHERE NOT EXISTS (
    SELECT 1 FROM habits e
    WHERE e.creator_id = h.user_id AND e.name = 'Habit ' || lpad(h.n::text, 4, '0')
);

-- =====================================================================
-- HABIT COMPLETIONS (streaky, user/habit-dependent, respects frequency_days)
-- =====================================================================
INSERT INTO habit_completions (habit_id, local_timestamp, completed_at, actual_value, note, status)
SELECT
    h.id,
    ev.local_ts,
    CASE WHEN ev.status = 'MISSED' THEN NULL
         ELSE ev.local_ts + (2 + 85 * power(rnd('cc' || h.id::text || '_' || days.day_offset), 2)) * INTERVAL '1 minute' END,
    CASE ev.status
        WHEN 'MISSED' THEN NULL
        WHEN 'COMPLETED' THEN round(m1.target * (0.9 + 0.45 * rnd('hv' || h.id::text || '_' || days.day_offset)))::int
        WHEN 'PARTIALLY_COMPLETED' THEN GREATEST(1, round(m1.target * (0.25 + 0.5 * rnd('hv' || h.id::text || '_' || days.day_offset))))::int
        ELSE GREATEST(1, round(m1.target * 0.12 * rnd('hv' || h.id::text || '_' || days.day_offset)))::int
    END,
    CASE ev.status
        WHEN 'COMPLETED' THEN
            CASE WHEN rnd('hn1' || h.id::text || '_' || days.day_offset) < 0.12
                 THEN (SELECT s.txt FROM seed_topics s WHERE s.kind = 'note_done'
                       ORDER BY rnd('hnd' || h.id::text || '_' || days.day_offset || s.txt) LIMIT 1) END
        WHEN 'PARTIALLY_COMPLETED' THEN
            CASE WHEN rnd('hn2' || h.id::text || '_' || days.day_offset) < 0.5
                 THEN (SELECT s.txt FROM seed_topics s WHERE s.kind = 'note_part'
                       ORDER BY rnd('hnp' || h.id::text || '_' || days.day_offset || s.txt) LIMIT 1) END
        WHEN 'SKIPPED' THEN
            CASE WHEN rnd('hn3' || h.id::text || '_' || days.day_offset) < 0.7
                 THEN (SELECT s.txt FROM seed_topics s WHERE s.kind = 'note_skip'
                       ORDER BY rnd('hns' || h.id::text || '_' || days.day_offset || s.txt) LIMIT 1) END
        ELSE NULL
    END,
    ev.status
FROM habits h
JOIN users u ON u.id = h.creator_id
CROSS JOIN LATERAL generate_series(0, LEAST(239, CURRENT_DATE - h.start_day)) AS days(day_offset)
CROSS JOIN LATERAL (SELECT CURRENT_DATE - days.day_offset AS d) dd
CROSS JOIN LATERAL (
    SELECT
        dil(u.nickname) AS dl,
        EXTRACT(ISODOW FROM dd.d)::int AS isodow,
        floor((days.day_offset + floor(rnd('hsh' || h.id::text) * 20))::numeric
              / (4 + floor(rnd('hbl' || h.id::text) * 7)))::int AS blk,
        (dd.d - h.start_day) AS since,
        10 + floor(rnd('ht' || h.id::text) * 50)::int AS target
) m1
CROSS JOIN LATERAL (
    SELECT LEAST(0.97, GREATEST(0.03,
        (0.25 + 0.7 * m1.dl)
        * (0.7 + 0.6 * rnd('hw' || h.id::text || '_' || m1.blk))
        * (1 - 0.3 * (1 - m1.dl) * LEAST(1.0, m1.since / 300.0))
        * (CASE WHEN m1.isodow >= 6 THEN 0.88 ELSE 1.0 END)
    )) AS p
) m2
CROSS JOIN LATERAL (
    SELECT
        ((dd.d::timestamp
          + ((360 + floor(rnd('hm' || h.id::text) * 840) + floor(rnd('hj' || h.id::text || '_' || days.day_offset) * 91) - 45)::int)
            * INTERVAL '1 minute') AT TIME ZONE h.timezone) AS local_ts,
        CASE
            WHEN rnd('hr' || h.id::text || '_' || days.day_offset) < m2.p * 0.88 THEN 'COMPLETED'
            WHEN rnd('hr' || h.id::text || '_' || days.day_offset) < m2.p        THEN 'PARTIALLY_COMPLETED'
            WHEN (rnd('hr' || h.id::text || '_' || days.day_offset) - m2.p) / (1 - m2.p)
                 < 0.32 + (CASE WHEN m1.isodow >= 6 THEN 0.15 ELSE 0.0 END) THEN 'SKIPPED'
            ELSE 'MISSED'
        END AS status
) ev
WHERE h.name ~ '^Habit [0-9]{4}$'
  AND h.status <> 'DRAFT'
  AND dd.d >= h.start_day
  AND (h.end_day IS NULL OR dd.d <= h.end_day)
  AND m1.isodow = ANY (h.frequency_days)
  AND (h.status <> 'PAUSED' OR days.day_offset > 14 + (abs(hashtext(h.id::text)) % 40))
  AND NOT EXISTS (
      SELECT 1 FROM habit_completions e
      WHERE e.habit_id = h.id AND e.local_timestamp = ev.local_ts
  );

DROP TABLE IF EXISTS seed_topics;

DROP FUNCTION IF EXISTS public.dil(text);
DROP FUNCTION IF EXISTS public.rnd(text);