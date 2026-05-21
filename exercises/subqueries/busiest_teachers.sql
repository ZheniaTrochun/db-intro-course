-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
WITH total_professor_credits AS (
    SELECT pr.person_id, sum(c.credits) AS total_credits
    FROM professor pr
    	JOIN course_teacher ct ON pr.professor_id = ct.professor_id
    	JOIN course c ON ct.course_id = c.course_id
	GROUP BY pr.person_id
)
SELECT p.first_name || ' ' || p.last_name AS "full_name", tpc.total_credits AS "total_credits", 
	   ROUND(avg(tpc.total_credits) OVER(), 2) AS "avg_total_credits"
FROM total_professor_credits tpc
	JOIN person p ON tpc.person_id = p.person_id
ORDER BY tpc.total_credits DESC, p.first_name || ' ' || p.last_name
LIMIT 100;
