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
SELECT concat(pst.first_name,' ', pst.last_name) AS student_name,
       sg.group_name,
	   c.course_name,
	   e.grade,
	   concat(ppr.first_name,' ', ppr.last_name) AS lecturer_name
FROM enrolment e 
INNER JOIN student st ON st.student_id = e.student_id
INNER JOIN course c ON c.course_id = e.course_id
INNER JOIN student_group_assignment sga ON sga.student_id = st.student_id
INNER JOIN student_group sg ON sg.group_id = sga.group_id
INNER JOIN course_teacher ct ON ct.course_id = c.course_id
INNER JOIN professor pr ON pr.professor_id = ct.professor_id
INNER JOIN person pst ON st.person_id = pst.person_id
INNER JOIN person ppr ON pr.person_id = ppr.person_id
WHERE professor_role= 'lecturer'
      AND grade < 60
	  AND grade IS NOT NULL
ORDER BY grade, group_name, student_name, course_name