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
-- SELECT *
-- FROM course c
-- LEFT JOIN enrolment e ON e.course_id = c.course_id
-- LEFT JOIN course_teacher ct ON ct.course_id = c.course_id
-- 
-- LEFT JOIN profesor prof ON prof.professor_id = ct.professor_id
-- LEFT JOIN student s ON s.student_id = e.studednt_id
-- LEFT JOIN person prsnprof ON prsnprof.person_id = prof.person_id
-- LEFT JOIN person prsns ON prsns.person_id = s.person_id
-- 
-- WHERE c.course_status = 'active'
-- ORDER BY




SELECT prsn.first_name || ' ' || prsn.last_name AS full_name, c.course_name AS course_name, 'запис на курс' AS activity_type
FROM course c
JOIN enrolment e ON e.course_id = c.course_id
JOIN student s ON s.student_id = e.student_id
JOIN person prsn ON prsn.person_id = s.person_id
WHERE c.course_status = 'active'

UNION ALL

SELECT prsn.first_name || ' ' || prsn.last_name AS full_name, c.course_name AS course_name, 'викладання курсу' AS activity_type
FROM course c
JOIN course_teacher ct ON ct.course_id = c.course_id
JOIN professor prof ON prof.professor_id = ct.professor_id
JOIN person prsn ON prsn.person_id = prof.person_id
WHERE c.course_status = 'active'

ORDER BY course_name, activity_type, full_name