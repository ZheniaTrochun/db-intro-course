-- Знайти викладачів, які викладають предмети для 2 курсу
select * from teacher
where teacher_id in (
    select teacher_id from course where student_year = 2
);

-- такий самий запит, проте з використанням СТЕ
with second_year_courses as (
    select teacher_id from course where student_year = 2
)
select distinct teacher.teacher_id, teacher.name, teacher.surname
from teacher
         inner join second_year_courses on second_year_courses.teacher_id = teacher.teacher_id;

-- Знайти всі курси, які не мають пререквізитів
select *
from course c
where not exists (
    select 1
    from course_prerequisite p
    where p.course_id = c.course_id
);

-- СТЕ
-- Знайти всі активні предмети для 2 курсу та кількість записаних студентів
with active_second_year_courses as (
    select * from course where student_year = 2 and is_active
)
select course_id, ac.name, count(*) as num_of_students
from enrolment e
         inner join active_second_year_courses ac USING (course_id)
group by course_id, ac.name;

-- Для кожного викладача знайти кількість курсів, які він викладає та середній бал студентів, які відвідували курси
with courses_stats as (
    select teacher_id, count(*) as num_of_courses from course group by teacher_id
),
     grades_stats as (
         select teacher_id, avg(grade) as avg_student_grade
         from enrolment e
                  inner join course c USING (course_id)
         group by teacher_id
     )
select *
from teacher t
         inner join courses_stats using (teacher_id)
         inner join grades_stats using (teacher_id);

-- Для кожного курсу знайти в якому мінімальному семестрі він може читатись
-- Знайти всіх студентів, які записані на більше курсів ніж в середньому студенти
-- Знайти топ-3 студенти у кожному курсі за отриманими балами
