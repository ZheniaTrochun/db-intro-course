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
    c.course_name                      AS course_name,
    'запис на курс'                    AS activity_type
FROM enrolment e
JOIN student s ON s.student_id = e.student_id
JOIN person p  ON p.person_id  = s.person_id
JOIN course c  ON c.course_id  = e.course_id
WHERE c.course_status = 'active'

UNION ALL

SELECT
    p.first_name || ' ' || p.last_name,
    c.course_name,
    'викладання курсу'
FROM course_teacher ct
JOIN professor pr ON pr.professor_id = ct.professor_id
JOIN person p     ON p.person_id     = pr.person_id
JOIN course c     ON c.course_id     = ct.course_id
WHERE c.course_status = 'active'

ORDER BY course_name, activity_type, full_name;