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
SELECT sp.first_name || ' ' || sp.last_name as "student_name", sg.name as "group_name", c.name as "course_name", 
       e.grade as "grade",  lp.first_name || ' ' || lp.last_name as "lecturer_name"
FROM enrolment e
	JOIN student s
		on e.student_id = s.student_id
	JOIN person sp
		on s.person_id = sp.person_id
	JOIN student_group sg 
    		on s.group_id = sg.group_id
	JOIN course c 
    		on e.course_id = c.course_id
	JOIN course_teacher ct 
    		on c.course_id = ct.course_id
	JOIN professor pr 
    		on ct.professor_id = pr.professor_id
	JOIN person lp
    		on pr.person_id = lp.person_id
WHERE e.grade is NOT NULL and e.grade < 60 and ct.professor_role = 'лектор'
ORDER BY e.grade ASC, sg.name ASC, student_name ASC, course_name ASC;