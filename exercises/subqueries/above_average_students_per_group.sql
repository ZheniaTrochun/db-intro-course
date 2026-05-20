-- Завдання:
--      Знайти студентів, чий середній бал перевищує середній бал їхньої групи
--      Використати два CTE: один для середнього балу студента, інший для середнього балу групи
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - назва групи (group_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - середній бал групи (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента

-- Рішення:
with student_avg as (
  select 
    s.student_id,
    p.first_name || ' ' || p.last_name as full_name,
    g.name as group_name,
    avg(e.grade) as avg_student_grade,
    avg(avg(e.grade)) over (partition by s.group_id) as avg_group_grade
  from student s
  join person p on s.person_id = p.person_id
  join student_group g on s.group_id = g.group_id
  join enrolment e on s.student_id = e.student_id
  group by s.student_id, s.group_id, p.first_name, p.last_name, g.name
)
select 
  student_id,
  full_name,
  group_name,
  round(avg_student_grade::numeric, 2) as avg_student_grade,
  round(avg_group_grade::numeric, 2) as avg_group_grade
from student_avg
where avg_student_grade > avg_group_grade
order by group_name asc, avg_student_grade desc, full_name asc
