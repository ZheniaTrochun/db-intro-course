-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
WITH prof_credits AS (
    SELECT 
        ct.professor_id,
        SUM(c.credits) AS total_credits
    FROM course_teacher ct
    JOIN course c ON ct.course_id = c.course_id
    GROUP BY ct.professor_id
),
global_avg AS (
    SELECT 
        ROUND(AVG(total_credits)::numeric, 2) AS avg_total_credits
    FROM prof_credits
)
SELECT 
    pe.first_name || ' ' || pe.last_name AS full_name,
    pc.total_credits,
    ga.avg_total_credits
FROM prof_credits pc
JOIN professor p ON pc.professor_id = p.professor_id
JOIN person pe ON p.person_id = pe.person_id
CROSS JOIN global_avg ga
ORDER BY 
    pc.total_credits DESC, 
    full_name
LIMIT 100;