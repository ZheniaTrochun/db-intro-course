-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:

--ІО-41 Кореняко Антон

with recursive course_levels as (
    select c.course_id, c.name, 1 as min_year
    from course c
    where c.course_id not in (select cp.course_id from course_prerequisite cp)

    union all

    select c.course_id, c.name, cl.min_year + 1
    from course c
    join course_prerequisite cp on c.course_id = cp.course_id
    join course_levels cl on cp.prerequisite_course_id = cl.course_id
)
select cl.course_id as course_id, cl.name as name, max(cl.min_year) as min_year
from course_levels cl

where exists (select 1 from enrolment e where e.course_id = cl.course_id)

group by course_id, name

order by min_year, name