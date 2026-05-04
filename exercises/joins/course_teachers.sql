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
 c.name as course_name,
 p.first_name || ' ' || p.last_name as teacher_name,
 ct.professor_role as role
FROM course c
JOIN course_teacher ct on c.course_id = ct.course_id
JOIN professor prof on ct.professor_id = prof.professor_id
JOIN person p on prof.person_id = p.person_id
WHERE c.status::text = 'активний'
ORDER by course_name ASC, role ASC;