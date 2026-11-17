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
		concat_ws(' ', p.first_name, p.last_name) AS full_name,
		SUM(c.credits) AS total_credits 
	FROM professor prof
	INNER JOIN person p USING(person_id)
	INNER JOIN course_teacher ct USING(professor_id)
	INNER JOIN course c USING(course_id)
	GROUP BY prof.professor_id, p.first_name, p.last_name
),
teacher_avg AS (
	SELECT 
		full_name,
		total_credits,
		ROUND(AVG(total_credits) OVER (), 2) AS avg_total_credits
	FROM teacher_credits 
) 

SELECT *
FROM teacher_avg
ORDER BY total_credits DESC, full_name
LIMIT 100;

