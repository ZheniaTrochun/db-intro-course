-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
WITH teacher_credits AS (
SELECT pr.professor_id, SUM(c.credits) AS total_credits
FROM professor pr
JOIN course_teacher ct ON ct.professor_id = pr.professor_id
JOIN course c ON c.course_id = ct.course_id
GROUP BY pr.professor_id
),
avg_credits AS (
SELECT AVG(total_credits) AS avg_total_credits FROM teacher_credits
)
SELECT
p.first_name || ' ' || p.last_name AS full_name,
tc.total_credits,
ROUND((SELECT avg_total_credits FROM avg_credits), 2) AS avg_total_credits
FROM teacher_credits tc
JOIN professor pr ON pr.professor_id = tc.professor_id
JOIN person p ON p.person_id = pr.person_id
ORDER BY tc.total_credits DESC, full_name
LIMIT 100;
