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
SELECT c.name AS "course_name", pers.first_name || ' ' || pers.last_name AS "teacher_name",
ct.professor_role AS "role"
FROM course c
LEFT JOIN course_teacher ct ON ct.course_id = c.course_id
LEFT JOIN professor prof ON ct.professor_id = prof.professor_id
LEFT JOIN person pers ON prof.person_id = pers.person_id
WHERE c.status = 'активний'
ORDER BY c.name, ct.professor_role