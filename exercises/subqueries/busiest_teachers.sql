-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:

WITH professor_credits AS (
    SELECT 
        p.first_name || ' ' || p.last_name AS full_name,
        SUM(c.credits) AS total_credits
    FROM professor pr
    JOIN person p ON pr.person_id = p.person_id
    JOIN course_teacher ct ON pr.professor_id = ct.professor_id
    JOIN course c ON ct.course_id = c.course_id
    GROUP BY p.first_name, p.last_name
)
SELECT 
    full_name,
    total_credits,
    (SELECT ROUND(AVG(total_credits)::numeric, 2) FROM professor_credits) AS avg_total_credits
FROM professor_credits
ORDER BY total_credits DESC, full_name ASC
LIMIT 100;