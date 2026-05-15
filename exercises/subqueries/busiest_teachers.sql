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
SELECT CONCAT(p.first_name, ' ', p.last_name) AS full_name, SUM(c.credits) AS total_credits
FROM person p
JOIN professor prof ON p.person_id = prof.person_id
JOIN course_teacher ct ON prof.professor_id = ct.professor_id
JOIN course c ON ct.course_id = c.course_id
GROUP BY p.person_id, p.first_name, p.last_name
)
SELECT full_name, total_credits,
ROUND(AVG(total_credits) OVER (), 2) AS avg_total_credits
FROM professor_credits
ORDER BY total_credits DESC, full_name ASC
LIMIT 100;
