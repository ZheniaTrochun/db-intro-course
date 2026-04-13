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
    s.first_name || ' ' || s.last_name AS full_name,
    c.name AS course_name,
    'запис на курс' AS activity_type
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
WHERE c.status = 'активний'

UNION ALL

SELECT 
    t.first_name || ' ' || t.last_name AS full_name,
    c.name AS course_name,
    'викладання курсу' AS activity_type
FROM courses c
JOIN teachers t ON c.teacher_id = t.id
WHERE c.status = 'активний'

ORDER BY course_name ASC, activity_type ASC, full_name ASC;
