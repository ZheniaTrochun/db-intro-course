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
    (SELECT SUM(c.credits) 
     FROM courses c 
     JOIN professor_course pc ON c.id = pc.course_id 
     WHERE pc.professor_id = p.id) AS total_credits
FROM professors p
WHERE p.id IN (SELECT professor_id FROM professor_course)
ORDER BY total_credits DESC
LIMIT 100;