-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента, потім за ідентифікатором студента

-- Рішення:
with student_stats as (
    select 
        s.student_id,
        p.first_name || ' ' || p.last_name as full_name,
        sga.group_id,
        sg.group_name,
        avg(e.grade) as avg_student_grade
    from student s
    join person p on s.person_id = p.person_id
    join student_group_assignment sga on s.student_id = sga.student_id
    join student_group sg on sga.group_id = sg.group_id
    left join enrolment e on s.student_id = e.student_id
    group by s.student_id, p.first_name, p.last_name, sga.group_id, sg.group_name
),
group_stats as (
    select 
        sga.group_id,
        avg(e.grade) as avg_group_grade
    from student_group_assignment sga
    join enrolment e on sga.student_id = e.student_id
    group by sga.group_id
)
select 
    ss.student_id,
    ss.full_name,
    round(ss.avg_student_grade, 2) as avg_student_grade,
    ss.group_name,
    round(gs.avg_group_grade, 2) as avg_group_grade
from student_stats ss
left join group_stats gs on ss.group_id = gs.group_id
order by ss.group_name asc, ss.full_name asc, ss.student_id asc;
