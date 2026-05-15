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
    s.first_name || ' ' || s.last_name AS person_name,
    c.name AS course_name,
    'student' AS role
FROM students s
JOIN enrolments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id
UNION ALL
SELECT 
    p.first_name || ' ' || p.last_name AS person_name,
    c.name AS course_name,
    'professor' AS role
FROM professors p
JOIN professor_course pc ON p.id = pc.professor_id
JOIN courses c ON pc.course_id = c.id
ORDER BY person_name, course_name;
