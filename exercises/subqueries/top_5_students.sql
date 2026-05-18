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
with ranked as (select
    c.name as course_name,
    s.student_id,
    p.first_name || ' ' || p.last_name as student_full_name,
    e.grade,
    rank() over (
      partition by c.course_id
      order by e.grade desc,
      p.first_name || ' ' || p.last_name,
      s.student_id
    ) as rank
  from enrolment e
  join student s on s.student_id = e.student_id
  join person p on p.person_id  = s.person_id
  join course c on c.course_id  = e.course_id
  where e.grade is not null)
select course_name,
  student_id,
  student_full_name,
  grade,
  rank
from ranked
where rank <= 5
order by course_name,
  rank,
  student_full_name,
  student_id;

