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
ct.professor_role AS role
FROM course c
JOIN course_teacher ct ON ct.course_id = c.course_id
JOIN professor pr ON pr.professor_id = ct.professor_id
JOIN person p ON p.person_id = pr.person_id
WHERE c.status = 'активний'
ORDER BY c.name, ct.professor_role;
