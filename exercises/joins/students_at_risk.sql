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
SELECT pe_s.first_name || ' ' || pe_s.last_name AS student_name,
	   sg.name AS group_name,
	   c.name AS course_name,
	   e.grade,
	   pe_pr.first_name || ' ' || pe_pr.last_name AS lecturer_name
FROM student s LEFT JOIN enrolment e USING(student_id)
LEFT JOIN person pe_s USING(person_id)
LEFT JOIN student_group sg USING(group_id)
LEFT JOIN course c USING(course_id)
LEFT JOIN course_teacher ct USING(course_id)
LEFT JOIN professor pr USING(professor_id)
LEFT JOIN person pe_pr ON pr.person_id = pe_pr.person_id
WHERE e.grade < 60 AND e.grade IS NOT NULL AND ct.professor_role = 'лектор'
ORDER BY e.grade, sg.name, student_name, course_name