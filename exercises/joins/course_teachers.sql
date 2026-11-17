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
	concat_ws(' ', p.first_name, p.last_name) AS professor_name,
	t.professor_role AS role
FROM course c
INNER JOIN course_teacher t
	ON c.course_id = t.course_id 
	AND c.course_status = 'active'
INNER JOIN professor prof USING(professor_id)
INNER JOIN person p USING(person_id)
ORDER BY course_name, role;