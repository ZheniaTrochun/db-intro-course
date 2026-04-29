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
SELECT c.name as course_name, 
       p.first_name || ' ' || p.last_name as teacher_name,
       ct.professor_role as role 
    FROM course as c
 JOIN course_teacher ct ON ct.course_id = c.course_id
 JOIN professor pr ON ct.professor_id = pr.professor_id 
 JOIN person p ON  pr.person_id = p.person_id 
WHERE c.status = 'активний'
ORDER BY course_name, role;

