-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
select 
c.course_id,
c.name,
min(e.start_year) as min_year
from course c
join enrolment e on c.course_id = e.course_id
group by c.course_id, c.name
order by min_year asc, c.name asc
