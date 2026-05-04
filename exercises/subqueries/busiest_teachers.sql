-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
WITH sum_teach_credits as(
	SELECT  p.person_id,
	CONCAT(p.first_name, ' ', p.last_name) AS full_name,
	SUM (c.credits) as total_credits
FROM person p
	inner join professor pr USING(person_id)
	inner join course_teacher ct ON pr.professor_id = ct.professor_id
	inner join course c ON ct.course_id = c.course_id
GROUP BY p.person_id, p.first_name, p.last_name),
avg_teach_credits AS (
    SELECT AVG(total_credits) AS avg_total_credits
    FROM sum_teach_credits)
SELECT  
    tc.full_name,
    ROUND(tc.total_credits, 2) as total_credits,
    ROUND(atc.avg_total_credits, 2) as avg_total_credits
FROM sum_teach_credits tc
    CROSS JOIN avg_teach_credits atc
ORDER BY 
    tc.total_credits DESC, 
    tc.full_name ASC
LIMIT 100;
