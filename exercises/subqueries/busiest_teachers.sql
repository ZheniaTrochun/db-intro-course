-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
SELECT p.first_name || ' ' || p.last_name AS professor_name, 
       (SELECT SUM(c.credits) FROM course c JOIN course_teacher ct USING(course_id) WHERE ct.professor_id = pr.professor_id) AS total_credits
FROM professor pr
JOIN person p ON pr.person_id = p.person_id
WHERE pr.professor_id IN (SELECT professor_id FROM course_teacher)
ORDER BY total_credits DESC, professor_name
LIMIT 100;