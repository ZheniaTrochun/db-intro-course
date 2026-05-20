-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента, потім за ідентифікатор студента

-- Рішення:
with student_courses as (
  select 
  s.student_id,
  p.first_name || ' ' || p.last_name as full_name,
  count(e.course_id) as course_number
  from student s
  join person p on s.person_id = p.person_id
  join enrolment e on s.student_id = e.student_id
  group by s.student_id, p.first_name, p.last_name
)

select 
  student_id,
  full_name,
  course_number,
  round(avg(course_number) over ()::numeric, 2)::float as avg_number
from student_courses
where course_number > (select avg(course_number) from student_courses)
order by course_number desc, full_name asc, student_id asc
