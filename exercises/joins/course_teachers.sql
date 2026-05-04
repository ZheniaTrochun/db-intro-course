-- Завдання:
--      Вивести список усіх активних курсів разом з іменами їхніх викладачів та їхніми ролями
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - повне ім'я викладача (professor_name)
--          - роль викладача на курсі (role)
--      Включити тільки курси зі статусом 'активний'
--      Результат відсортувати за:
--          - назвою курсу, потім за роллю викладача

-- Коментар студента:
-- В умові вказано, що повне ім'я викладача має бути в колонці professor_name, 
-- проте під час тестування, скрипт Python очікує колонку з назвою teacher_name.

-- Рішення:
SELECT
    c.name as course_name,
    CONCAT(pr.first_name, ' ', pr.last_name) as teacher_name,
    ct.professor_role as role
FROM course c
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN professor p ON ct.professor_id = p.professor_id
JOIN person pr ON p.person_id = pr.person_id
WHERE c.status = 'активний'
ORDER BY course_name, role;