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
with course_count_of_student as ( select
    student_id, 
    count(course_id) as course_number
  from enrolment e
  group by e.student_id
),
global_avg_course_count as (select 
    avg(course_number) as avg_number
  from course_count_of_student
)
select 
  ccof.student_id as student_id, 
  p.first_name || ' ' || p.last_name as full_name,
  ccof.course_number as course_number, 
  round(gacc.avg_number, 2)::float as avg_number
from course_count_of_student ccof
  cross join global_avg_course_count gacc
  join student s on ccof.student_id = s.student_id
  join person p on s.person_id = p.person_id
where ccof.course_number > gacc.avg_number
order by ccof.course_number desc, 
  p.first_name || ' ' || p.last_name asc, 
  ccof.student_id asc;
