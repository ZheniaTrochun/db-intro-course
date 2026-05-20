-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента, потім за ідентифікатор студента

-- Рішення:
select s.student_id, p.first_name || ' ' || p.last_name as full_name, count(e.course_id) as course_number
from student s
join person p on s.person_id = p.person_id
join enrolment e on s.student_id = e.student_id
group by s.student_id, p.first_name, p.last_name
having count(e.course_id) > (
select avg(cnt) from (
select count(course_id) as cnt
from enrolment
group by student_id
) sub
)
order by course_number desc
