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
INNER JOIN course_teacher ct USING (course_id)
INNER JOIN professor pr USING (professor_id)
INNER JOIN person p USING (person_id)
WHERE c.course_status = 'active'
ORDER BY c.course_name, ct.professor_role