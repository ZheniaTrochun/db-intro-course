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
SELECT person.first_name || ' ' || person.last_name AS full_name, course.course_name, 'запис на курс' AS activity_type
FROM enrolment
JOIN student ON student.student_id = enrolment.student_id
JOIN person ON person.person_id = student.person_id
JOIN course ON course.course_id = enrolment.course_id
WHERE course.course_status = 'active'
UNION ALL
SELECT person.first_name || ' ' || person.last_name AS full_name, course.course_name, 'викладання курсу' AS activity_type
FROM course_teacher
JOIN professor ON professor.professor_id = course_teacher.professor_id
JOIN person ON person.person_id = professor.person_id
JOIN course ON course.course_id = course_teacher.course_id
WHERE course.course_status = 'active'
ORDER BY course_name, activity_type, full_name;
