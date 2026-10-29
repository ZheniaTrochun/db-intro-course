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

select 
	st_per.first_name || ' ' || st_per.last_name as student_name,
	sg.group_name,
	c.course_name,
	e.grade,
	pr_per.first_name || ' ' || pr_per.last_name as lecturer_name
from student s
inner join person st_per using (person_id)
inner join student_group_assignment sga using (student_id)
inner join student_group sg using (group_id)
inner join enrolment e using (student_id)
inner join course c using (course_id)
inner join course_teacher ct using (course_id)
inner join professor pr using (professor_id)
inner join person pr_per on pr.person_id = pr_per.person_id 
where e.grade is not null
	and e.grade < 60
	and ct.professor_role = 'lecturer'
order by e.grade asc, sg.group_name, student_name, c.course_name;
