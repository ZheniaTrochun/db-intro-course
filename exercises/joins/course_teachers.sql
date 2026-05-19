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
    crs.name AS course_name,
    pers.first_name || ' ' || pers.last_name AS teacher_name,
    c_t.professor_role AS role
FROM course crs
INNER JOIN course_teacher c_t ON crs.course_id = c_t.course_id
INNER JOIN professor prof ON c_t.professor_id = prof.professor_id
INNER JOIN person pers ON prof.person_id = pers.person_id
WHERE crs.status = 'активний'
ORDER BY crs.name, c_t.professor_role;
