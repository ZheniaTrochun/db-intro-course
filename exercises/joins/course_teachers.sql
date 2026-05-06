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
SELECT c.name AS course_name,
	   pe.first_name || ' ' || pe.last_name AS teacher_name,
	   ct.professor_role AS role
FROM course c
LEFT JOIN course_teacher ct USING(course_id)
LEFT JOIN professor pr USING(professor_id)
LEFT JOIN person pe USING(person_id)
WHERE c.status = 'активний'
ORDER BY c.name, role