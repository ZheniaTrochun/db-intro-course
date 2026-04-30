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
    sp.first_name || ' ' || sp.last_name AS full_name,
    c.name AS course_name,
    'запис на курс' AS activity_type
FROM enrolment e
JOIN student s 
    ON s.student_id = e.student_id
JOIN person sp 
    ON sp.person_id = s.person_id
JOIN course c 
    ON c.course_id = e.course_id
WHERE 
    c.status = 'активний'

UNION ALL

SELECT 
    pp.first_name || ' ' || pp.last_name AS full_name,
    c.name AS course_name,
    'викладання курсу' AS activity_type
FROM course_teacher ct
JOIN professor p 
    ON p.professor_id = ct.professor_id
JOIN person pp 
    ON pp.person_id = p.person_id
JOIN course c 
    ON c.course_id = ct.course_id
WHERE 
    c.status = 'активний'

ORDER BY 
    course_name ASC,
    activity_type ASC,
    full_name ASC;