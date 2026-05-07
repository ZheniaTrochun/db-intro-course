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
SELECT c.name AS course_name, pe.first_name || ' ' || pe.last_name AS teacher_name, 
	t.professor_role AS role
FROM course c
	left join course_teacher t USING(course_id)
	left join professor pr USING(professor_id)
	left join person pe USING(person_id)
WHERE c.status = 'активний'
ORDER BY course_name, role;