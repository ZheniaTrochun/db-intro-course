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
    SELECT pr.professor_id,
           p.first_name || ' ' || p.last_name as full_name,
           SUM(c.credits) as total_credits
    FROM professor as pr
    JOIN person p ON pr.person_id = p.person_id
    JOIN course_teacher ct ON pr.professor_id = ct.professor_id
    JOIN course c ON ct.course_id = c.course_id
    GROUP BY pr.professor_id, full_name
)
SELECT full_name, total_credits,
       ROUND(AVG(total_credits) OVER(), 2) as avg_total_credits
 FROM teacher_credits
ORDER BY total_credits DESC, full_name
LIMIT 100;