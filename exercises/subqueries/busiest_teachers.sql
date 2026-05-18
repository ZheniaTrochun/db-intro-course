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
        pr.professor_id,
        CONCAT(p.first_name, ' ', p.last_name) AS full_name,
        SUM(c.credits) AS total_credits
    FROM professor pr
    JOIN person p ON p.person_id = pr.person_id
    JOIN course_teacher ct ON ct.professor_id = pr.professor_id
    JOIN course c ON c.course_id = ct.course_id
    GROUP BY
        pr.professor_id,
        full_name
),
avg_credits AS (
    SELECT AVG(total_credits) AS avg_total_credits
    FROM teacher_credits
)
SELECT
    tc.full_name,
    tc.total_credits,
    ROUND(a.avg_total_credits, 2) AS avg_total_credits
FROM teacher_credits tc
CROSS JOIN avg_credits a
ORDER BY 
    tc.total_credits DESC,
    tc.full_name
LIMIT 100;
 

