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
WITH active_courses AS (
    SELECT course_id, course_name
    FROM course
    WHERE course_status = 'active'
)
SELECT
    p.first_name || ' ' || p.last_name AS full_name,
    ac.course_name AS course_name,
    'запис на курс' AS activity_type
FROM enrolment AS e
JOIN student AS s
    ON s.student_id = e.student_id
JOIN person AS p
    ON p.person_id = s.person_id
JOIN active_courses AS ac
    ON ac.course_id = e.course_id
UNION ALL
SELECT
    p.first_name || ' ' || p.last_name AS full_name,
    ac.course_name AS course_name,
    'викладання курсу' AS activity_type
FROM course_teacher AS ct
JOIN professor AS prof
    ON prof.professor_id = ct.professor_id
JOIN person AS p
    ON p.person_id = prof.person_id
JOIN active_courses AS ac
    ON ac.course_id = ct.course_id
ORDER BY
    course_name ASC,
    activity_type ASC,
    full_name ASC;
