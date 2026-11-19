-- Знайти всі курси, які не мають пререквізитів
-- Варіант 1: NOT EXISTS
select *
from course c
where not exists (
    select 1 from course_prerequisite cp where cp.course_id = c.course_id
);

-- Варіант 2: LEFT JOIN + IS NULL (результат той самий, 5 курсів)
select *
from course c
         left join course_prerequisite cp on cp.course_id = c.course_id
where cp.prerequisite_course_id is null;


-- Знайти активні курси, на які записані студенти набору 2023 року, та кількість таких студентів

with active_courses as (
    select *
    from course
    where course_status = 'active'
),
     students_2023 as (
         select *
         from student s
                  inner join student_group_assignment sga using (student_id)
                  inner join student_group sg using (group_id)
         where sg.start_year = 2023
     )
select
    ac.course_name,
    count(*) as num_of_students
from active_courses ac
         inner join enrolment e using (course_id)
         inner join students_2023 using (student_id)
group by ac.course_name;

-- Для кожного викладача знайти кількість курсів, які він викладає,
-- та середній бал студентів, які відвідували ці курси

with courses_stats as (
    select professor_id, COUNT(*) as number_of_courses
    from course_teacher
    group by professor_id
),
     grades_stats as (
         select ct.professor_id, AVG(e.grade) as avg_student_grade
         from course_teacher ct
                  inner join enrolment e using (course_id)
         group by ct.professor_id
     )
select prof.professor_id,
       p.first_name || ' ' || p.last_name as full_name,
       COALESCE(cs.number_of_courses, 0) as number_of_courses,
       ROUND(gs.avg_student_grade, 2) as avg_student_grade
from professor prof
         inner join person p using (person_id)
         left join courses_stats cs using (professor_id)
         left join grades_stats gs using (professor_id)
order by prof.professor_id;


-- Для кожного курсу знайти, в якому мінімальному семестрі він може читатись

with recursive course_dependencies as (

    select course_id, 1 as level
    from course c
    where not exists (
        select 1 from course_prerequisite cp where cp.course_id = c.course_id
    )

    union all

    select cp.course_id, cd.level + 1 as level
    from course_dependencies cd
             inner join course_prerequisite cp on cd.course_id = cp.prerequisite_course_id

)
select c.course_name, max(cd.level) as min_semester
from course_dependencies cd
         inner join course c using (course_id)
group by c.course_id;
