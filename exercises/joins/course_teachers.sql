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
    p.first_name || ' ' || p.last_name AS teacher_name,
    pc.role
FROM courses c
JOIN professor_course pc ON c.id = pc.course_id
JOIN professors p ON pc.professor_id = p.id
ORDER BY course_name, teacher_name;