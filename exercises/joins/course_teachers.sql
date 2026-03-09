-- Завдання:
--      Вивести список усіх активних курсів разом з іменами їхніх викладачів та їхніми ролями
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - повне ім'я викладача (professor_name)
--          - роль викладача на курсі (role)
--      Включити тільки курси зі статусом 'активний'
--      Результат відсортувати за:
--          - назвою курсу, потім за роллю викладача

-- Рішення:
SELECT
    c.name AS course_name,
    t.first_name || ' ' || t.last_name AS professor_name,
    ca.role
FROM courses c
JOIN course_assignments ca
    ON c.id = ca.course_id
JOIN teachers t
    ON ca.teacher_id = t.id
WHERE c.status = 'активний'
ORDER BY
    course_name ASC,
    role ASC;