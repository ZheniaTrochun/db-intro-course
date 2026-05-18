-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
with recursive course_depth as ( select
    c.course_id,
    c.name,
    1 as min_year
  from course c
  where not exists (select 1
    from course_prerequisite cp
    where cp.course_id = c.course_id)
  union all
  select c.course_id,
    c.name,
    cd.min_year + 1
  from course c
  join course_prerequisite cp on cp.course_id = c.course_id
  join course_depth cd on cd.course_id = cp.prerequisite_course_id)
select course_id,
  name,
  max(min_year) as min_year
from course_depth
group by course_id,
  name
order by min_year,
  name;
