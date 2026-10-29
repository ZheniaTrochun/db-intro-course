-- Завдання:
--      Сформувати єдиний список активностей університету, що поєднує:
--          - записи студентів на курси
--          - призначення викладачів на курси
--      Очікувані колонки результату:
--          - повне ім'я (full_name)
--          - назва курсу (course_name)
--          - тип активності (activity_type) - 'запис на курс' або 'викладання курсу'
--      Включити тільки активні курси (статус 'активний')
--      Результат відсортувати за:
--          - назвою курсу, потім за типом активності, потім за іменем

-- Рішення:

select
	p.first_name || ' ' || p.last_name as full_name,
	c.course_name,
	'запис на курс' as activity_type
from enrolment e
inner join student s using (student_id)
inner join person p using (person_id)
inner join course c using (course_id)
where c.course_status = 'active'

union

select
	per.first_name || ' ' || per.last_name as full_name,
	c.course_name,
	'викладання курсу' as activity_type
from course_teacher ct
inner join professor pr using (professor_id)
inner join person per using (person_id)
inner join course c using (course_id)
where c.course_status = 'active'

order by course_name, activity_type, full_name;
