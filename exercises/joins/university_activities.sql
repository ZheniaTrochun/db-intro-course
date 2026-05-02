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
    'student' AS activity_type
FROM student s
JOIN person p ON s.person_id = p.person_id
UNION
SELECT 
    p.first_name || ' ' || p.last_name AS full_name,
    'professor' AS activity_type
FROM professor prof
JOIN person p ON prof.person_id = p.person_id
ORDER BY full_name ASC, activity_type ASC;