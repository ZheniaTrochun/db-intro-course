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

SELECT 
CONCAT(p.first_name, ' ', p.last_name) AS full_name, c.name AS course_name, 'запис на курс' AS activity_type
FROM enrolment e
INNER JOIN student s USING (student_id)
INNER JOIN person p USING (person_id)
INNER JOIN course c USING (course_id)
WHERE c.status = 'активний'
UNION ALL

SELECT 
CONCAT(p.first_name, ' ', p.last_name) AS full_name, c.name AS course_name, 'викладання курсу' AS activity_type
FROM course_teacher ct
INNER JOIN professor prof USING (professor_id)
INNER JOIN person p USING (person_id)
INNER JOIN course c USING (course_id)
WHERE c.status = 'активний'
ORDER BY  2 ASC,  3 ASC,  1 ASC;