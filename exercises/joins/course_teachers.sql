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
SELECT
    c.course_name,
    p.first_name || ' ' || p.last_name AS professor_name,
    ct.professor_role AS role
FROM course c
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN professor prof ON ct.professor_id = prof.professor_id
JOIN person p ON prof.person_id = p.person_id
WHERE c.course_status = 'active'
ORDER BY
    c.course_name ASC,
    ct.professor_role ASC;