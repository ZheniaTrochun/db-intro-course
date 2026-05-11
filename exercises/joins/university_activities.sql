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
SELECT p.first_name || ' ' || p.last_name AS full_name, c.name AS course_name, U&'\0437\0430\043F\0438\0441 \043D\0430 \043A\0443\0440\0441' AS activity_type
FROM student s
	LEFT JOIN person p ON p.person_id = s.person_id
	LEFT JOIN enrolment e ON e.student_id = s.student_id
	LEFT JOIN course c ON c.course_id = e.course_id
WHERE c.status = U&'\0430\043A\0442\0438\0432\043D\0438\0439'
UNION ALL
SELECT p.first_name || ' ' || p.last_name AS full_name, c.name AS course_name, U&'\0432\0438\043A\043B\0430\0434\0430\043D\043D\044F \043A\0443\0440\0441\0443' AS activity_type
FROM course_teacher ct
	JOIN professor prof using(professor_id)
	JOIN person p using(person_id)
	JOIN course c ON ct.course_id = c.course_id
WHERE c.status = U&'\0430\043A\0442\0438\0432\043D\0438\0439'
ORDER BY course_name, activity_type, full_name;