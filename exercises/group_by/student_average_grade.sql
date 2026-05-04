-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента

-- Рішення:
with student_avg_data as (
    select
        s.student_id,
        p.first_name || ' ' || p.last_name as full_name,
        s.group_id,
        sg.name as group_name,
        avg(e.grade) as student_raw_avg
    from student s
    join person p on s.person_id = p.person_id
    join student_group sg on s.group_id = sg.group_id
    left join enrolment e on s.student_id = e.student_id
    group by s.student_id, p.first_name, p.last_name, s.group_id, sg.name
)
select
    student_id,
    full_name,
    round(student_raw_avg, 2) as avg_student_grade,
    group_name,
    round(avg(student_raw_avg) over (partition by group_id), 2) as avg_group_grade
from student_avg_data
order by group_name, full_name, student_id;