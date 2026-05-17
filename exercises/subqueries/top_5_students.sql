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

--ІО-41 Кореняко Антон

  with ranklist as (
    select c.name as course_name, e.student_id, p.first_name || ' ' || p.last_name as full_name,
    e.grade, row_number() over (partition by c.course_id
    order by e.grade desc nulls last, (p.first_name || ' ' || p.last_name)) as student_rank
    from enrolment e
    join course c on e.course_id = c.course_id
    join student s on e.student_id = s.student_id
    join person p on s.person_id = p.person_id)

select rl.course_name, rl.student_id, rl.full_name as student_full_name, rl.grade as grade,
rl.student_rank as rank

from ranklist rl

where rl.student_rank < 6

order by course_name, student_rank, student_full_name