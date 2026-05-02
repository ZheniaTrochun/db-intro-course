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
        p.professor_id,
        per.first_name || ' ' || per.last_name AS full_name,
        SUM(c.credits) AS total_credits
    FROM professor p
    JOIN person per 
        ON per.person_id = p.person_id
    JOIN course_teacher ct 
        ON ct.professor_id = p.professor_id
    JOIN course c 
        ON c.course_id = ct.course_id
    GROUP BY p.professor_id, per.first_name, per.last_name
),
avg_credits AS (
    SELECT 
        ROUND(AVG(total_credits)::numeric, 2) AS avg_total_credits
    FROM teacher_credits
)
SELECT 
    tc.full_name,
    tc.total_credits,
    ac.avg_total_credits
FROM teacher_credits tc
CROSS JOIN avg_credits ac
ORDER BY 
    tc.total_credits DESC,
    tc.full_name ASC
LIMIT 100;