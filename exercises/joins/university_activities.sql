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
SELECT p.first_name || ' ' || p.last_name as full_name, c.name as course_name, 
'запис на курс' as activity_type
FROM person p
JOIN student s on p.person_id = s.person_id
JOIN enrolment e on s.student_id = e.student_id
JOIN course c on e.course_id = c.course_id
WHERE c.status = 'активний'

UNION ALL

SELECT p.first_name || ' ' || p.last_name as full_name, c.name as course_name, 
'викладання курсу' as activity_type
FROM person p
JOIN professor s on p.person_id = s.person_id
JOIN course_teacher e on s.professor_id = e.professor_id
JOIN course c on e.course_id = c.course_id
WHERE c.status = 'активний'

ORDER BY course_name, activity_type, full_name;