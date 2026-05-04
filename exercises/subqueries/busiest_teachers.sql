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
	SELECT p.person_id as person_id, SUM(c.credits) as total_credits
	FROM course c
	JOIN course_teacher ct ON c.course_id = ct.course_id
	JOIN professor pr ON ct.professor_id = pr.professor_id
	JOIN person p ON pr.person_id = p.person_id
	GROUP BY p.person_id)
	
SELECT p.first_name || ' ' || p.last_name AS full_name, tc.total_credits AS total_credits, 
(SELECT ROUND(AVG(total_credits), 2) FROM teacher_credits) AS avg_total_credits
FROM teacher_credits tc
JOIN person p ON tc.person_id = p.person_id
ORDER BY total_credits DESC, full_name LIMIT 100