-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
SELECT first_name || ' ' || last_name AS full_name, SUM (co.credits) AS total_credits, 
	(
     SELECT ROUND(AVG(total_credits), 2) as avg_total_credits
     FROM (
	 SELECT professor_id, SUM (co.credits) AS total_credits
	 FROM course co
		join course_teacher c using(course_id) 
		join professor pr using(professor_id)
	 GROUP BY professor_id
 	 ) AS avg_total_credits
	) 
FROM course co
	join course_teacher c using(course_id) 
	join professor pr using(professor_id)
	join person p using(person_id)
GROUP BY full_name
ORDER BY total_credits DESC, full_name
LIMIT 100;