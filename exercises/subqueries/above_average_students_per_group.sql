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

--ІО-41 Кореняко Антон

  with student_grades as (
    select s.student_id, s.group_id, avg(e.grade) as avg_student_grade
    from student s
    join enrolment e on s.student_id = e.student_id
    group by s.student_id, s.group_id),

group_grades as (
    select s.group_id, avg(e.grade) as avg_group_grade
    from student s
    join enrolment e on s.student_id = e.student_id
    group by s.group_id)

select sg.student_id, p.first_name || ' ' || p.last_name as full_name, g.name as group_name,
round(sg.avg_student_grade::numeric, 2) as avg_student_grade, round(gg.avg_group_grade::numeric, 2) as avg_group_grade

from student_grades sg
join group_grades gg on sg.group_id = gg.group_id
join student_group g on sg.group_id = g.group_id
join student s on sg.student_id = s.student_id
join person p on s.person_id = p.person_id

where sg.avg_student_grade > gg.avg_group_grade

order by group_name asc, avg_student_grade desc, full_name, sg.student_id