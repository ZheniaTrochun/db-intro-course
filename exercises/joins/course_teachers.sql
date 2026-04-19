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

SELECT c.name AS course_name, per.first_name || ' ' || per.last_name as teacher_name, ct.professor_role as role
FROM course c
INNER JOIN course_teacher ct
    ON c.course_id = ct.course_id
INNER JOIN professor pr
    ON ct.professor_id = pr.professor_id
INNER JOIN person per
    ON pr.person_id = per.person_id

WHERE c.status = 'активний'
ORDER BY c.name ASC , ct.professor_role ASC;