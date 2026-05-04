-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
with professor_sum as (
    select 
        p.first_name || ' ' || p.last_name as full_name,
        sum(c.credits) as total_credits
    from professor pro
    inner join person p on p.person_id = pro.person_id
    inner join course_teacher ct on ct.professor_id = pro.professor_id
    inner join course c on c.course_id = ct.course_id
    group by pro.professor_id, p.first_name, p.last_name
)
select 
    full_name,
    total_credits,
    round(avg(total_credits) over(), 2) as avg_total_credits
from professor_sum
order by total_credits desc, full_name
limit 100;