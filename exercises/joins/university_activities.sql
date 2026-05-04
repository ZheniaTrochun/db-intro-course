-- Завдання:
--      Сформувати єдиний список активностей університету, що поєднує:
--          - записи студентів на курси
--          - призначення викладачів на курси
--      Очікувані колонки результату:
--          - повне ім'я (full_name)
--          - назва курсу (course_name)
--          - тип активності (activity_type) - 'запис на курс' або 'викладання курсу'
--      Включити тільки активні курси (статус 'активний')
--      Результат відсортувати за:
--          - назвою курсу, потім за типом активності, потім за іменем

-- Рішення:
SELECT ps.first_name || ' ' || ps.last_name as "full_name",
	   c.name as course_name,
	   'запис на курс' as activity_type
FROM enrolment e
JOIN course c USING(course_id)
JOIN student s USING(student_id)
JOIN person ps ON s.person_id=ps.person_id
WHERE c.status ='активний'

UNION ALL

SELECT pp.first_name || ' ' || pp.last_name as "full_name",
	   c.name as course_name,
	   'викладання курсу' as activity_type
FROM course_teacher ct
JOIN course c USING(course_id)
JOIN professor p USING(professor_id)
JOIN person pp ON p.person_id=pp.person_id
WHERE c.status ='активний'
ORDER BY  course_name, activity_type, full_name;
