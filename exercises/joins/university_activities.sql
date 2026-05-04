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
WITH CourseParticipants AS (
    SELECT s.person_id, e.course_id, 'запис на курс' AS activity_type
    FROM enrolment e
    JOIN student s ON e.student_id = s.student_id

    UNION ALL

    SELECT pr.person_id, ct.course_id, 'викладання курсу' AS activity_type
    FROM course_teacher ct
    JOIN professor pr ON ct.professor_id = pr.professor_id
)

SELECT 
    p.first_name || ' ' || p.last_name AS full_name,
    c.name AS course_name,
    cp.activity_type
FROM CourseParticipants cp
JOIN person p ON cp.person_id = p.person_id
JOIN course c ON cp.course_id = c.course_id
WHERE c.status = 'активний'
ORDER BY course_name, activity_type, full_name;