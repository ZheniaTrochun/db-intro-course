-- Завдання:
--      Вивести список усіх активних курсів разом з іменами їхніх викладачів та їхніми ролями
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - повне ім'я викладача (professor_name)
--          - роль викладача на курсі (role)
--      Включити тільки курси зі статусом 'active'
--      Результат відсортувати за:
--          - назвою курсу, потім за роллю викладача

-- Рішення:
SELECT c.course_name AS course_name, prsn.first_name || ' ' || prsn.last_name AS professor_name, ct.professor_role AS role
FROM course c
LEFT JOIN course_teacher ct ON ct.course_id = c.course_id
LEFT JOIN professor prof ON prof.professor_id = ct.professor_id
LEFT JOIN person prsn ON prof.person_id = prsn.person_id
WHERE c.course_status = 'active'
ORDER BY course_name, role