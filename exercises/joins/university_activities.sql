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
SELECT
 p.first_name || ' ' || p.last_name as full_name,
 c.name as course_name,
 'запис на курс' as activity_type
FROM enrolment e
JOIN student s on e.student_id = s.student_id
JOIN person p on s.person_id = p.person_id
JOIN course c on e.course_id = c.course_id
WHERE c.status::text = 'активний'
UNION ALL
SELECT
 p.first_name || ' ' || p.last_name as full_name,
 c.name as course_name,
 'викладання курсу' as activity_type
FROM course_teacher ct
JOIN professor prof on ct.professor_id = prof.professor_id
JOIN person p on prof.person_id = p.person_id
JOIN course c on ct.course_id = c.course_id
WHERE c.status::text = 'активний'
ORDER by course_name ASC, activity_type ASC, full_name ASC;