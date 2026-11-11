-- =====================================================
-- Завдання 3. OLAP запити
-- =====================================================

-- 1. Середній бюджет проєкту за категорією
SELECT cat.name                      AS category,
       COUNT(p.project_id)           AS projects_count,
       ROUND(AVG(p.budget), 2)       AS avg_budget
FROM categories cat
LEFT JOIN projects p ON p.category_id = cat.category_id
GROUP BY cat.category_id, cat.name
ORDER BY avg_budget DESC NULLS LAST;

-- 2. Середній час завершення проєкту (у днях) - загалом і за категоріями
SELECT cat.name                                   AS category,
       COUNT(*)                                   AS completed_contracts,
       ROUND(AVG(ct.end_date - ct.start_date), 1) AS avg_days_to_complete
FROM contracts ct
JOIN proposals pr  ON pr.proposal_id = ct.proposal_id
JOIN projects p    ON p.project_id = pr.project_id
JOIN categories cat ON cat.category_id = p.category_id
WHERE ct.status = 'completed'
GROUP BY ROLLUP (cat.name)
ORDER BY cat.name NULLS LAST;

-- 3. Ранжування фрілансерів за рейтингом успішності контрактів (віконні функції)
SELECT f.full_name,
       COUNT(ct.contract_id)                                          AS total_contracts,
       COUNT(*) FILTER (WHERE ct.status = 'completed')                AS completed_contracts,
       ROUND(AVG(ct.rating), 2)                                       AS avg_rating,
       RANK() OVER (
           ORDER BY AVG(ct.rating) DESC NULLS LAST,
                    COUNT(*) FILTER (WHERE ct.status = 'completed') DESC
       )                                                              AS success_rank
FROM freelancers f
JOIN proposals pr ON pr.freelancer_id = f.freelancer_id
JOIN contracts ct ON ct.proposal_id = pr.proposal_id
GROUP BY f.freelancer_id, f.full_name
ORDER BY success_rank;

-- 4. Проєкти без пропозицій за певний період (CTE)
WITH period AS (
    SELECT CURRENT_DATE - 60 AS date_from,
           CURRENT_DATE      AS date_to
),
period_projects AS (
    SELECT p.project_id, p.title, p.budget, p.created_at, p.category_id
    FROM projects p
    CROSS JOIN period
    WHERE p.created_at BETWEEN period.date_from AND period.date_to
),
projects_with_proposals AS (
    SELECT DISTINCT project_id
    FROM proposals
)
SELECT pp.project_id,
       pp.title,
       cat.name AS category,
       pp.budget,
       pp.created_at
FROM period_projects pp
JOIN categories cat ON cat.category_id = pp.category_id
LEFT JOIN projects_with_proposals pwp ON pwp.project_id = pp.project_id
WHERE pwp.project_id IS NULL
ORDER BY pp.created_at;
