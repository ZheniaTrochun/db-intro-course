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
    p_person.first_name || ' ' || p_person.last_name AS teacher_name,
    ct.professor_role AS role
FROM course c
JOIN course_teacher ct ON c.course_id = ct.course_id
JOIN professor p ON ct.professor_id = p.professor_id
JOIN person p_person ON p.person_id = p_person.person_id
WHERE c.status = 'активний'
ORDER BY 
    course_name ASC, 
    role ASC;
