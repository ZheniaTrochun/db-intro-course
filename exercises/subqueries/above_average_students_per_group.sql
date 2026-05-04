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
        p.first_name,
        p.last_name,
        p.first_name || ' ' || p.last_name as full_name,
        sg.name as group_name,
        s.group_id,
        avg(e.grade) as s_avg
    from student s
    inner join person p on p.person_id = s.person_id
    inner join student_group sg on s.group_id = sg.group_id
    inner join enrolment e on e.student_id = s.student_id
    group by s.student_id, p.first_name, p.last_name, sg.name, s.group_id
),
group_avg as (
    select
        s.group_id,
        avg(e.grade) as g_avg
    from student s
    inner join enrolment e on e.student_id = s.student_id
    group by s.group_id
)
select
    sa.student_id,
    sa.full_name,
    sa.group_name,
    round(sa.s_avg::numeric, 2) as avg_student_grade,
    round(ga.g_avg::numeric, 2) as avg_group_grade
from student_avg sa
inner join group_avg ga on sa.group_id = ga.group_id
where sa.s_avg > ga.g_avg
order by sa.group_name asc, avg_student_grade desc, sa.last_name asc, sa.first_name asc;