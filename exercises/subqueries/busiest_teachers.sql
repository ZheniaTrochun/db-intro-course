-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
WITH total_credits AS (
    SELECT pe.first_name || ' ' || pe.last_name AS full_name,
           SUM(c.credits) AS total_credits
    FROM professor pr JOIN person pe USING(person_id)
    JOIN (
        SELECT DISTINCT professor_id, course_id 
        FROM course_teacher
    ) ct ON pr.professor_id = ct.professor_id
    JOIN course c USING(course_id)
    GROUP BY pr.professor_id, full_name
),
ranked_professors AS (
    SELECT tc.full_name, tc.total_credits,
           ROW_NUMBER() OVER (ORDER BY tc.total_credits DESC, tc.full_name ASC) AS rank
    FROM total_credits tc
)
SELECT 
    rp.full_name,
    rp.total_credits,
    (SELECT ROUND(AVG(total_credits), 2) FROM total_credits) AS avg_total_credits
FROM ranked_professors rp
WHERE rank <= 100
ORDER BY rp.total_credits DESC, rp.full_name;