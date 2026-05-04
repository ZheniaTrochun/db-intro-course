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
SELECT ps.first_name || ' ' || ps.last_name as student_name,
	   sg.name as group_name,
	   c.name as course_name,
	   e.grade as grade, 
	   pp.first_name || ' ' || pp.last_name as lecturer_name
FROM student s
	left join person ps using(person_id)
	left join student_group sg using(group_id)
	left join enrolment e using(student_id)
	left join course c ON e.course_id=c.course_id
	left join course_teacher ct ON c.course_id=ct.course_id
	left join professor p ON ct.professor_id=p.professor_id
	left join person pp ON p.person_id=pp.person_id
WHERE e.grade < 60 AND e.grade IS NOT NULL AND ct.professor_role = 'лектор'
ORDER BY grade ASC, group_name, student_name, course_name;
