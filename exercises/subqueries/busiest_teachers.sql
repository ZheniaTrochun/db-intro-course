-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:
with teacher_credits as (select pr.professor_id,
    p.first_name || ' ' || p.last_name as "full_name",
    sum(c.credits) as "total_credits"
  from professor pr
  join person p on p.person_id = pr.person_id
  join course_teacher ct on ct.professor_id = pr.professor_id
  join course c on c.course_id = ct.course_id
  group by pr.professor_id,
    full_name),
avg_credits as (select avg(total_credits) as avg_total_credits from teacher_credits)
select tc.full_name,
  tc.total_credits,
  round(a.avg_total_credits, 2) as "avg_total_credits"
from teacher_credits tc
cross join avg_credits a
order by tc.total_credits desc,
  tc.full_name
limit 100;
 

