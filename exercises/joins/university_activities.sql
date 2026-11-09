-- Завдання:
--      Сформувати єдиний список активностей університету, що поєднує:
--          - записи студентів на курси
--          - призначення викладачів на курси
--      Очікувані колонки результату:
--          - повне ім'я (full_name)
--          - назва курсу (course_name)
--          - тип активності (activity_type) - 'запис на курс' або 'викладання курсу'
--      Включити тільки активні курси (статус 'active')
--      Результат відсортувати за:
--          - назвою курсу, потім за типом активності, потім за іменем

-- Рішення:
select p.first_name || ' ' || p.last_name as full_name,
       c.course_name,
       'запис на курс' AS activity_type
from student s
join person p on s.person_id = p.person_id
join enrolment e on s.student_id = e.student_id
join course c on e.course_id = c.course_id
where c.course_status = 'active'

union all

select pl.first_name || ' ' || pl.last_name as full_name,
       c.course_name,
       'викладання курсу' AS activity_type
from professor pr
join person pl on pr.person_id = pl.person_id
join course_teacher cl on pr.professor_id = cl.professor_id
join course c on cl.course_id = c.course_id
where c.course_status = 'active'

order by course_name, activity_type, full_name