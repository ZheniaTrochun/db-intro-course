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
SELECT p.first_name || ' ' || p.last_name AS full_name, c.name AS course_name, 'викладання курсу' as activity_type
FROM course_teacher t
    inner join course c USING (course_id)
    inner join professor pr USING (professor_id)
    inner join person p USING (person_id)
WHERE c.status = 'активний'

UNION ALL

SELECT p.first_name || ' ' || p.last_name AS full_name, c.name as course_name, 'запис на курс' as activity_type
FROM enrolment e
    inner join course c using (course_id)
	inner join student s using (student_id)
	inner join person p using (person_id)
WHERE c.status = 'активний'
ORDER BY course_name, activity_type, full_name;