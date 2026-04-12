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
    c.course_name, 
    p.professor_name, 
    ct.role
FROM courses c
JOIN course_teachers ct ON c.id = ct.course_id
JOIN professors p ON ct.professor_id = p.id
WHERE c.status = 'активний'
ORDER BY c.course_name ASC, ct.role ASC;
