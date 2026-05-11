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
SELECT c.name as course_name, dnp.first_name || ' ' || dnp.last_name as teacher_name, ct.professor_role as role --teacher_name - бо інакше тест не працює
FROM course c
LEFT JOIN course_teacher ct on c.course_id = ct.course_id
LEFT JOIN professor p on ct.professor_id = p.professor_id
LEFT JOIN person dnp on p.person_id = dnp.person_id
WHERE c.status = 'активний'
ORDER BY course_name, role;