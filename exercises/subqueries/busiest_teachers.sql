-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
with teacher_credits as (
select 
  p.first_name || ' ' || p.last_name as full_name,
  sum(c.credits) as total_credits
  from professor prof
  join person p on prof.person_id = p.person_id
  join course_teacher ct on prof.professor_id = ct.professor_id
  join course c on ct.course_id = c.course_id
  group by prof.professor_id, p.first_name, p.last_name
)

select 
  full_name,
  total_credits,
  round(avg(total_credits) over ()::numeric, 2)::float as avg_total_credits
from teacher_credits
order by 
  total_credits desc, 
  full_name asc
limit 100
