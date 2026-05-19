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
    p.first_name || ' ' || p.last_name AS full_name,
    c.name AS course_name,
    'запис на курс' AS activity_type
FROM course c
INNER JOIN enrolment e ON c.course_id = e.course_id
INNER JOIN student s ON e.student_id = s.student_id
INNER JOIN person p ON s.person_id = p.person_id
WHERE c.status = 'активний'

UNION ALL

SELECT
    p.first_name || ' ' || p.last_name AS full_name,
    c.name AS course_name,
    'викладання курсу' AS activity_type
FROM course c
INNER JOIN course_teacher ct ON c.course_id = ct.course_id
INNER JOIN professor pr ON ct.professor_id = pr.professor_id
INNER JOIN person p ON pr.person_id = p.person_id
WHERE c.status = 'активний'

ORDER BY course_name, activity_type, full_name;
