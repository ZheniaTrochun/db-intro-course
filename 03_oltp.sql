-- =====================================================
-- Завдання 2. OLTP запити
-- =====================================================

-- ---------- INSERT ----------

-- 1. Новий проєкт від клієнта (категорія вибирається за назвою)
INSERT INTO projects (client_id, category_id, title, description, budget, deadline)
VALUES (
    3,
    (SELECT category_id FROM categories WHERE name = 'Design'),
    'Дизайн мобільного застосунку',
    'Макети 15 екранів у Figma',
    1800.00,
    CURRENT_DATE + 45
);

-- 2. Нова пропозиція фрілансера на проєкт
INSERT INTO proposals (project_id, freelancer_id, price, cover_letter)
VALUES (9, 1, 1900.00, 'Маю досвід міграції з MySQL на PostgreSQL');

-- ---------- UPDATE ----------

-- 1. Прийняти пропозицію і перевести відповідний проєкт у статус "в роботі"
UPDATE proposals
SET status = 'accepted'
WHERE proposal_id = 7;

UPDATE projects
SET status = 'in_progress'
WHERE project_id = (SELECT project_id FROM proposals WHERE proposal_id = 7);

-- 2. Підвищити погодинну ставку фрілансера на 10%
UPDATE freelancers
SET hourly_rate = ROUND(hourly_rate * 1.10, 2)
WHERE freelancer_id = 2;

-- ---------- DELETE ----------

-- 1. Видалити відхилені пропозиції старші за 90 днів
DELETE FROM proposals
WHERE status = 'rejected'
  AND submitted_at < CURRENT_DATE - 90;

-- 2. Видалити відкриті проєкти без жодної пропозиції, створені понад 50 днів тому
DELETE FROM projects
WHERE status = 'open'
  AND created_at < CURRENT_DATE - 50
  AND NOT EXISTS (
      SELECT 1 FROM proposals pr WHERE pr.project_id = projects.project_id
  );

-- ---------- SELECT ----------

-- 1. Усі відкриті проєкти в конкретній категорії
SELECT p.project_id,
       p.title,
       p.budget,
       p.deadline,
       c.company_name
FROM projects p
JOIN categories cat ON cat.category_id = p.category_id
JOIN clients c      ON c.client_id = p.client_id
WHERE p.status = 'open'
  AND cat.name = 'Web Development'
ORDER BY p.deadline;

-- 2. Усі виконані проєкти заданого фрілансера (freelancer_id = 2)
SELECT p.project_id,
       p.title,
       pr.price,
       ct.start_date,
       ct.end_date,
       ct.rating
FROM contracts ct
JOIN proposals pr ON pr.proposal_id = ct.proposal_id
JOIN projects p   ON p.project_id = pr.project_id
WHERE pr.freelancer_id = 2
  AND p.status = 'completed'
ORDER BY ct.end_date DESC;
