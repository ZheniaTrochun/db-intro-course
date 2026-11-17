-- Завдання:
--      Сформувати єдиний список активностей університету, що поєднує:
--          - записи студентів на курси
--          - призначення викладачів на курси
--      Очікувані колонки результату:
--          - повне ім'я (full_name)
--          - назва курсу (course_name)
--          - тип активності (activity_type) - 'запис на курс' або 'викладання курсу'
--      Включити тільки активні курси (статус 'active')
--      Результат відсортувати за:
--          - назвою курсу, потім за типом активності, потім за іменем

-- Рішення:

SELECT 
	concat_ws(' ', p.first_name, p.last_name) AS full_name,
	c.course_name,
	'викладання курсу' AS activity_type 
FROM course c
INNER JOIN course_teacher t USING(course_id)
INNER JOIN professor prof USING(professor_id)
INNER JOIN person p USING(person_id)	
WHERE c.course_status = 'active'

UNION ALL

SELECT 
	concat_ws(' ', p.first_name, p.last_name) AS full_name,
	c.course_name,
	'запис на курс' AS activity_type 
FROM course c
INNER JOIN enrolment e USING(course_id) 
INNER JOIN student s USING(student_id)
INNER JOIN person p USING(person_id)	
WHERE c.course_status = 'active'

ORDER BY course_name, activity_type, full_name;