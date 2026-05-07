-- Завдання:
--      Вивести список студентів, які мають низькі оцінки (менше 60) разом з інформацією про курс та викладача
--      Очікувані колонки результату:
--          - повне ім'я студента (student_name)
--          - назва групи (group_name)
--          - назва курсу (course_name)
--          - оцінка (grade)
--          - повне ім'я лектора курсу (lecturer_name)
--      Включити тільки записи, де оцінка вже виставлена
--      Включити тільки лекторів
--      Результат відсортувати за:
--          - оцінкою (зростання), потім за назвою групи, потім за іменем студента, потім за назвою курсу

-- Рішення:
SELECT pe2.first_name || ' ' || pe2.last_name AS student_name, g.name AS group_name, c.name AS course_name, e.grade, 
	pe.first_name || ' ' || pe.last_name AS lecturer_name
FROM enrolment e
	left join student s ON e.student_id = s.student_id
	left join student_group g ON s.group_id = g.group_id
	left join course c ON e.course_id = c.course_id
	left join course_teacher t ON t.course_id = e.course_id
	left join professor p ON t.professor_id = p.professor_id
	left join person pe ON p.person_id = pe.person_id
	left join person pe2 ON s.person_id = pe2.person_id
WHERE e.grade < 60 AND e.grade IS NOT NULL AND t.professor_role = 'лектор'
ORDER BY grade ASC, group_name, student_name, course_name;