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
    sp.first_name || ' ' || sp.last_name AS full_name,
    c.course_name,
    'запис на курс' AS activity_type
FROM enrolment e
JOIN student s ON e.student_id = s.student_id
JOIN person sp ON s.person_id = sp.person_id
JOIN course c ON e.course_id = c.course_id
WHERE c.course_status = 'active'

UNION ALL

SELECT
    pp.first_name || ' ' || pp.last_name AS full_name,
    c.course_name,
    'викладання курсу' AS activity_type
FROM course_teacher ct
JOIN professor prof ON ct.professor_id = prof.professor_id
JOIN person pp ON prof.person_id = pp.person_id
JOIN course c ON ct.course_id = c.course_id
WHERE c.course_status = 'active'

ORDER BY
    course_name ASC,
    activity_type ASC,
    full_name ASC;