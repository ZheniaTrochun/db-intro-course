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
select s.student_id, p.first_name || ' ' || p.last_name as full_name, sg.name as group_name, round(avg(e.grade), 2) as avg_student_grade, (
select round(avg(e2.grade), 2)
from student s2
join enrolment e2 on s2.student_id = e2.student_id
where s2.group_id = s.group_id
and e2.grade is not null
) as avg_group_grade
from student s
join person p on s.person_id = p.person_id
join student_group sg on s.group_id = sg.group_id
join enrolment e on s.student_id = e.student_id
where e.grade is not null
group by s.student_id, p.first_name, p.last_name, sg.name, s.group_id
having avg(e.grade) > (
select avg(e2.grade)
from student s2
join enrolment e2 on s2.student_id = e2.student_id
where s2.group_id = s.group_id
and e2.grade is not null
)
order by sg.name, avg_student_grade desc
