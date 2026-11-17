-- Завдання:
--      Вивести список студентів, які мають низькі оцінки (менше 60) разом з інформацією про курс та викладача
--      Очікувані колонки результату:
--          - повне ім'я студента (student_name)
--          - назва групи (group_name)
--          - назва курсу (course_name)
--          - оцінка (grade)
--          - повне ім'я лектора курсу (lecturer_name)
--      Включити тільки записи, де оцінка вже виставлена
--      Включити тільки лекторів (роль 'lecturer' або 'full_ownership')
--      Результат відсортувати за:
--          - оцінкою (зростання), потім за назвою групи, потім за іменем студента, потім за назвою курсу

-- Рішення:

SELECT 
	concat_ws(' ', p.first_name, p.last_name) AS student_name,
	g.group_name,
	c.course_name,
	e.grade,
	concat_ws(' ', p_prof.first_name, p_prof.last_name) AS lecturer_name
FROM student s
INNER JOIN enrolment e
	ON s.student_id = e.student_id
INNER JOIN course c USING(course_id)
INNER JOIN course_teacher teacher USING(course_id)
INNER JOIN professor prof USING(professor_id)
INNER JOIN person p_prof 
	ON p_prof.person_id = prof.person_id
INNER JOIN person p 
	ON p.person_id = s.person_id
INNER JOIN student_group_assignment assign 
	ON assign.student_id = s.student_id
INNER JOIN student_group g USING(group_id)
WHERE e.grade IS NOT NULL 
	AND e.grade < 60
	AND teacher.professor_role IN ('lecturer', 'full_ownership')
ORDER BY e.grade ASC,
	g.group_name,
	student_name,
	c.course_name;