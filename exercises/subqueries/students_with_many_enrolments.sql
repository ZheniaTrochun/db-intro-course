-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента

-- Рішення:
with student_counts as (
    select 
        s.student_id,
        p.first_name || ' ' || p.last_name as full_name,
        count(e.course_id) as course_number
    from student s
    join person p on p.person_id = s.person_id
    join enrolment e on e.student_id = s.student_id
    group by s.student_id, p.first_name, p.last_name
),
global_average as (
    select avg(course_number * 1.0) as avg_val from student_counts
)
select 
    sc.student_id,
    sc.full_name,
    sc.course_number,
    round((select avg_val from global_average), 2) as avg_number
from student_counts sc
where sc.course_number > (select avg_val from global_average)
order by sc.course_number desc, sc.full_name;