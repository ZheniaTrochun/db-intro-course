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
      pr.first_name || ' ' || pr.last_name AS professor_name,
        ct.professor_role AS role
FROM course c
INNER JOIN course_teacher ct ON c.course_id = ct.course_id
INNER JOIN professor p ON ct.professor_id = p.professor_id
INNER JOIN person pr ON p.person_id = pr.person_id
WHERE c.course_status = 'active'
ORDER BY c.course_name,
         ct.professor_role;