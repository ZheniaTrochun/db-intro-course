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

-- IO-45 Bondarchuk Mykhailo
-- Єдиний список активностей університету

SELECT
    p.first_name || ' ' || p.last_name AS full_name,
    c.name AS course_name,
    'запис на курс' AS activity_type
FROM
    student s
JOIN
    person p ON s.person_id = p.person_id
JOIN
    enrolment e ON s.student_id = e.student_id
JOIN
    course c ON e.course_id = c.course_id
WHERE
    c.status = 'активний'

UNION ALL

SELECT
    p.first_name || ' ' || p.last_name AS full_name,
    c.name AS course_name,
    'викладання курсу' AS activity_type
FROM
    professor prof
JOIN
    person p ON prof.person_id = p.person_id
JOIN
    course_teacher ct ON prof.professor_id = ct.professor_id
JOIN
    course c ON ct.course_id = c.course_id
WHERE
    c.status = 'активний'

ORDER BY
    course_name ASC,
    activity_type ASC,
    full_name ASC;