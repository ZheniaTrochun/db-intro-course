-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:

-- IO-45 Bondarchuk Mykhailo
-- Топ-100 викладачів з найбільшою кількістю кредитів

WITH TeacherCredits AS (

    SELECT
        p.first_name || ' ' || p.last_name AS full_name,
        SUM(c.credits) AS total_credits
    FROM professor prof
    JOIN person p ON prof.person_id = p.person_id
    JOIN course_teacher ct ON prof.professor_id = ct.professor_id
    JOIN course c ON ct.course_id = c.course_id
    GROUP BY prof.professor_id, p.first_name, p.last_name
),
AverageCalculation AS (

    SELECT AVG(total_credits) AS global_avg FROM TeacherCredits
)
SELECT
    full_name,
    CAST(total_credits AS BIGINT) AS total_credits,

    ROUND((SELECT global_avg FROM AverageCalculation)::numeric, 2)::numeric(38,2) AS avg_total_credits
FROM TeacherCredits
ORDER BY
    total_credits DESC,
    full_name ASC
LIMIT 100;