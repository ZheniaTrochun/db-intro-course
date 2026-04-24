-- Завдання:
--      Знайти топ-5 студентів у кожному курсі за отриманими балами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (student_full_name)
--          - бал (grade)
--          - ранг (rank)
--      Результат відсортувати за:
--          - назвою курсу, потім за рангом (зростання), потім за іменем студента

-- Рішення:
with ranked_students as (
    select
        c.name as course_name,
        s.student_id,
        p.first_name || ' ' || p.last_name as student_full_name,
        e.grade,
        row_number() over (
            partition by c.course_id 
            order by e.grade desc nulls last, p.first_name || ' ' || p.last_name asc, s.student_id asc
        ) as rank
    from student s
    inner join person p on p.person_id = s.person_id
    inner join enrolment e on e.student_id = s.student_id
    inner join course c on c.course_id = e.course_id
)
select 
    course_name,
    student_id,
    student_full_name,
    grade,
    rank
from ranked_students
where rank <= 5
order by course_name, rank asc, student_full_name;