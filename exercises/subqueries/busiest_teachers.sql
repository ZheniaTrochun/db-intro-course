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
        p.first_name || ' ' || p.last_name AS full_name,
        SUM(c.credits) AS total_credits
    FROM professor pr
    INNER JOIN person p ON p.person_id = pr.person_id
    INNER JOIN course_teacher ct ON ct.professor_id = pr.professor_id
	INNER JOIN course c ON ct.course_id = c.course_id
    GROUP BY pr.professor_id, p.first_name, p.last_name
)

SELECT
    tc.full_name,
    tc.total_credits,
    ROUND((SELECT AVG(total_credits) FROM teacher_credits), 2) AS avg_total_credits
FROM teacher_credits tc
ORDER BY tc.total_credits DESC, tc.full_name
LIMIT 100;