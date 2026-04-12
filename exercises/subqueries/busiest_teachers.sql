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
        p.first_name || ' ' || p.last_name AS full_name,
        SUM(c.credits) AS total_credits
    FROM professor pr
    JOIN person p ON pr.person_id = p.id
    JOIN course_teacher ct ON pr.id = ct.professor_id
    JOIN course c ON ct.course_id = c.id
    GROUP BY pr.id, p.first_name, p.last_name
)

SELECT 
    full_name,
    total_credits,
    (SELECT ROUND(AVG(total_credits), 2) FROM teacher_credits) AS avg_total_credits
FROM teacher_credits
ORDER BY 
    total_credits DESC, 
    full_name ASC
LIMIT 100;
