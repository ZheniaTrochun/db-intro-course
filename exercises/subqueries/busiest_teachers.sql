-- Завдання:
--      Знайти топ-100 викладачів, що мають найбільшу кількість кредитів
--      Очікувані колонки результату:
--          - повне ім'я викладача (full_name)
--          - загальна кількість кредитів (total_credits)
--          - середня кількість кредитів серед усіх викладачів (avg_total_credits) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю кредитів (спадання), потім за ім'ям

-- Рішення:


--ІО-41 Кореняко Антон

  with teacher_credits as (
    select p.person_id as person_id, sum(c.credits) as total_credits
    from course c
    join course_teacher ct on c.course_id = ct.course_id
    join professor pr on ct.professor_id = pr.professor_id
    join person p on pr.person_id = p.person_id
    group by p.person_id)

select p.first_name || ' ' || p.last_name as full_name, tc.total_credits as total_credits,
(select round(avg(total_credits), 2) from teacher_credits) as avg_total_credits

from teacher_credits tc
join person p on tc.person_id = p.person_id

order by total_credits desc, full_name limit 100