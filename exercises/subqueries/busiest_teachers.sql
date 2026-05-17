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
    p.first_name || ' ' || p.last_name AS professor_name, 
    SUM(c.credits) AS total_credits
FROM professor pr
JOIN person p ON pr.person_id = p.person_id
JOIN course_teacher ct ON pr.professor_id = ct.professor_id
JOIN course c ON ct.course_id = c.course_id
GROUP BY pr.professor_id, p.first_name, p.last_name
ORDER BY total_credits DESC, professor_name
LIMIT 100;