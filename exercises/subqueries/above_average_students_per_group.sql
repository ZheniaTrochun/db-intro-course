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
    s.group_id,
    p.first_name || ' ' || p.last_name as full_name,
    avg(e.grade) as avg_student_grade
  from student s
  join person p on s.person_id = p.person_id
  join enrolment e on s.student_id = e.student_id
  group by s.student_id, s.group_id, p.first_name, p.last_name
),

group_avg as (
  select 
    s.group_id,
    g.name as group_name,
    avg(e.grade) as avg_group_grade
  from student s
  join student_group g on s.group_id = g.group_id
  join enrolment e on s.student_id = e.student_id
  group by s.group_id, g.name
)

select 
  sa.student_id,
  sa.full_name,
  ga.group_name,
  round(sa.avg_student_grade::numeric, 2)::float as avg_student_grade,
  round(ga.avg_group_grade::numeric, 2)::float as avg_group_grade
from student_avg sa
join group_avg ga on sa.group_id = ga.group_id
where sa.avg_student_grade > ga.avg_group_grade
order by 
  ga.group_name asc, 
  sa.avg_student_grade desc, 
  sa.full_name asc
