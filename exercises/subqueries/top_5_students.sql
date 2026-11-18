-- Завдання:
--      Знайти топ-5 студентів у кожному курсі за отриманими балами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (student_full_name)
--          - бал (grade)
--          - ранг (rank) - за балом, іменем студента та ідентифікатором студента
--      Результат відсортувати за:
--          - назвою курсу, потім за рангом (зростання), потім за іменем студента, потім за ідентифікатором студента

-- Рішення:

with avg_student_grades as (
     select 
           c.course_name,
           s.student_id,
           p.first_name || ' ' || p.last_name as student_full_name,
           round(coalesce(avg(e.grade), 0), 2)::double precision as grade
     from student s
     inner join enrolment e using(student_id)
     inner join course c using(course_id)
     inner join person p using(person_id)
     where e.grade is not null
     group by s.student_id, c.course_id, c.course_name, student_full_name
),
ranked_students as (
     select 
           course_name,
           student_id,
           student_full_name,
           grade,
           rank() over (
               partition by course_name 
               order by grade desc, student_full_name asc, student_id asc
           ) as rank
     from avg_student_grades
)

select *
from ranked_students
where rank <= 5
order by course_name asc, rank asc, student_full_name asc, student_id asc;