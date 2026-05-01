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
SELECT p.first_name || ' ' || p.last_name AS full_name, c.name AS course_name, 'запис на курс' AS activity_type
FROM student s
LEFT JOIN person p ON s.person_id = p. person_id
LEFT JOIN enrolment e ON e.student_id = s.student_id
LEFT JOIN course c ON c.course_id = e.course_id
WHERE c.status = 'активний'
UNION ALL
SELECT p.first_name || ' ' || p.last_name AS full_name, c.name AS course_name, 'викладання курсу' AS activity_type
FROM course_teacher ct
JOIN professor pf using(professor_id)
JOIN person p using(person_id)
JOIN course c ON ct.course_id = c.course_id
WHERE c.status = 'активний'
ORDER BY course_name, activity_type, full_name;