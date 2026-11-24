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
    SELECT
        ct.professor_id AS professor_id,
        SUM(c.credits) AS total_credits
    FROM course_teacher AS ct
    JOIN course AS c
        ON c.course_id = ct.course_id
    GROUP BY ct.professor_id
),
avg_credits AS (
    SELECT AVG(tc.total_credits) AS avg_total_credits
    FROM teacher_credits AS tc
)
SELECT
    p.first_name || ' ' || p.last_name AS full_name,
    tc.total_credits AS total_credits,
    ROUND(ac.avg_total_credits, 2) AS avg_total_credits
FROM teacher_credits AS tc
CROSS JOIN avg_credits AS ac
JOIN professor AS pr
    ON pr.professor_id = tc.professor_id
JOIN person AS p
    ON p.person_id = pr.person_id
ORDER BY
    tc.total_credits DESC,
    full_name ASC
LIMIT 100;
