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
SELECT c.name as course_name, ppr.first_name || ' ' || ppr.last_name as teacher_name,
ct.professor_role as role
FROM course c
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN professor pr ON ct.professor_id = pr.professor_id
JOIN person ppr ON pr.person_id = ppr.person_id
WHERE c.status = 'активний'
ORDER BY course_name, role