-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
WITH total_professor_credits as (
    SELECT pr.person_id, sum(c.credits) as total_credits
    from professor pr
    	join course_teacher ct on pr.professor_id = ct.professor_id
    	join course c on ct.course_id = c.course_id
	GROUP BY pr.person_id
)
SELECT p.first_name || ' ' || p.last_name as "full_name", tpc.total_credits as "total_credits", 
	   ROUND(avg(tpc.total_credits) over(), 2) as "avg_total_credits"
from total_professor_credits tpc
	join person p on tpc.person_id = p.person_id
ORDER BY tpc.total_credits desc, p.first_name || ' ' || p.last_name
LIMIT 100;