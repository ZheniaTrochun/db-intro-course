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

SELECT 
    p.first_name || ' ' || p.last_name AS full_name,
    c.course_name,
	'запис на курс' AS activity_type
FROM person p
INNER JOIN student s ON p.person_id = s.person_id
INNER JOIN enrolment e ON s.student_id = e.student_id
INNER JOIN course c ON e.course_id = c.course_id
WHERE c.course_status = 'active'

UNION ALL

SELECT
    p.first_name || ' ' || p.last_name AS full_name,
    c.course_name,
    'викладання курсу' AS activity_type
FROM person p
INNER JOIN professor pr ON p.person_id = pr.person_id
INNER JOIN course_teacher ct ON ct.professor_id = pr.professor_id
INNER JOIN course c ON ct.course_id = c.course_id
WHERE c.course_status = 'active'
ORDER BY course_name, activity_type, full_name;