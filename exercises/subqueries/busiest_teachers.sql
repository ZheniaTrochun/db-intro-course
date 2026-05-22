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
        ct.professor_id,
        SUM(c.credits) AS total_credits
    FROM course_teacher ct
    JOIN course c ON c.course_id = ct.course_id
    GROUP BY ct.professor_id
)
SELECT
    per.first_name || ' ' || per.last_name AS full_name,
    tc.total_credits,
    ROUND(AVG(tc.total_credits) OVER (), 2) AS avg_total_credits
FROM teacher_credits tc
JOIN professor p ON p.professor_id = tc.professor_id
JOIN person per  ON per.person_id = p.person_id
ORDER BY tc.total_credits DESC, full_name
LIMIT 100;