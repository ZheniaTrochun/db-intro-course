-- Знайти всі курси, які не мають пререквізитів

select *
from course c
where not exists (
    select 1 from course_prerequisite p where c.course_id = p.course_id
);

select c.*
from course c
         left join course_prerequisite p using (course_id)
where p.course_id is null;

-- СТЕ
-- Знайти всі активні предмети для 2 курсу та кількість записаних студентів

with active_courses as (
    select * from course c
    where status = 'активний'
),
     second_year_students as (
         select student_id, course_id
         from enrolment e where start_year = 2024
     )
select ac.name, count(distinct sys.student_id) as student_count
from active_courses ac left join second_year_students sys using (course_id)
group by ac.name
having count(distinct sys.student_id) > 0;

-- Для кожного викладача знайти кількість курсів, які він викладає та середній бал студентів, які відвідували курси
with courses_stats as (
    select professor_id, count(distinct course_id) as number_of_courses
    from course_teacher ct
    group by professor_id
),
grades_stats as (
    select professor_id, avg(grade) as avg_student_grade
    from enrolment e
    inner join course_teacher ct USING (course_id)
    group by professor_id
)
select p.*, cs.number_of_courses, gs.avg_student_grade
from professor prof
         inner join courses_stats cs using (professor_id)
         inner join grades_stats gs using (professor_id)
         inner join person p using (person_id);

-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись

with recursive course_dependencies as (
    -- initial CASE
    select course_id, 1 as level
    from course c
    where not exists (
        select 1 from course_prerequisite pr where pr.course_id = c.course_id
    )
    UNION ALL
    -- recursive step
    select pr.course_id, cd.level + 1 as level
    from course_dependencies cd
             inner join course_prerequisite pr on cd.course_id = pr.prerequisite_course_id
)
select c.name, max(cd.level) as min_semester
from course_dependencies cd
         inner join course c using (course_id)
group by c.name;
