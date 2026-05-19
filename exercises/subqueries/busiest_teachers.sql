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
        prof.professor_id, 
        SUM(crs.credits) AS total_credits
    FROM professor prof
    INNER JOIN course_teacher ct ON prof.professor_id = ct.professor_id
    INNER JOIN course crs ON ct.course_id = crs.course_id
    GROUP BY prof.professor_id
),
overall_avg AS (
    SELECT AVG(total_credits) AS avg_total_credits 
    FROM prof_credits
)
SELECT
    pers.first_name || ' ' || pers.last_name AS full_name,
    pc.total_credits,
    ROUND((SELECT avg_total_credits FROM overall_avg), 2) AS avg_total_credits
FROM prof_credits pc
INNER JOIN professor prof ON pc.professor_id = prof.professor_id
INNER JOIN person pers ON prof.person_id = pers.person_id
ORDER BY pc.total_credits DESC, full_name
LIMIT 100;
