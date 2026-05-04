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
        pr.person_id,
        SUM(c.credits) AS total_credits
    FROM professor pr
    JOIN course_teacher ct ON pr.professor_id = ct.professor_id
    JOIN course c ON ct.course_id = c.course_id
    GROUP BY pr.person_id
)
SELECT 
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    tc.total_credits,
    ROUND(AVG(tc.total_credits) OVER(), 2) AS avg_total_credits
FROM teacher_credits tc
JOIN person p ON tc.person_id = p.person_id
ORDER BY tc.total_credits DESC, full_name ASC
LIMIT 100;