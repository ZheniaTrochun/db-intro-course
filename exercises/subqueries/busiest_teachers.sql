-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
SELECT
    prsn.first_name || ' ' || prsn.last_name AS full_name,
    SUM (c.credits) AS total_credits,
    ROUND (sub.total_credits_sub, 2) AS avg_total_credits
FROM professor p
    JOIN course_teacher ct USING (professor_id)
    JOIN course c USING (course_id)
    JOIN (
        SELECT 
            p.professor_id,
            AVG(SUM (c.credits)) OVER () AS total_credits_sub
        FROM professor p
            JOIN course_teacher ct USING (professor_id)
            JOIN course c USING (course_id)
        GROUP BY p.professor_id
    ) sub USING (professor_id)
    JOIN person prsn USING (person_id)
GROUP BY p.professor_id, prsn.first_name, prsn.Last_name, sub.total_credits_sub
ORDER BY total_credits DESC, full_name
LIMIT 100