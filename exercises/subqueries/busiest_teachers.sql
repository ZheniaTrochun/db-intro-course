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
        t.first_name || ' ' || t.last_name AS full_name,
        SUM(c.credits) AS total_credits
    FROM teachers t
    JOIN courses c
        ON t.id = c.teacher_id
    GROUP BY t.id, full_name
)
SELECT
    full_name,
    total_credits,
    ROUND(AVG(total_credits) OVER(), 2) AS avg_total_credits
FROM teacher_credits
ORDER BY
    total_credits DESC,
    full_name ASC
LIMIT 100;