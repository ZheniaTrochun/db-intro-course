-- Завдання:
--      Знайти студентів, чий середній бал перевищує середній бал їхньої групи
--      Використати два CTE: один для середнього балу студента, інший для середнього балу групи
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - назва групи (group_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - середній бал групи (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента

-- Рішення:
WITH avg_st_grade AS ( 
SELECT s.student_id as student_id, 
	CONCAT(p.first_name, ' ', p.last_name) AS full_name,
	AVG(e.grade) as avg_s_grade
FROM student s
	inner join person p USING(person_id)
	inner join enrolment e USING(student_id)
GROUP BY s.student_id, p.first_name, p.last_name),
avg_gr_grade AS ( 
SELECT sg.name as group_name, 
	AVG(e.grade) as avg_g_grade
FROM student_group sg
	inner join student s USING(group_id)
	inner join enrolment e ON s.student_id=e.student_id
GROUP BY sg.name)
SELECT asg.student_id, 
	asg.full_name, 
	agg.group_name,
	ROUND(asg.avg_s_grade, 2) AS avg_student_grade,
	ROUND(agg.avg_g_grade, 2) AS avg_group_grade
FROM student s
	inner join avg_st_grade asg USING (student_id)
	inner join student_group sg USING (group_id)
	inner join avg_gr_grade agg ON sg.name = agg.group_name
WHERE asg.avg_s_grade > agg.avg_g_grade
ORDER BY agg.group_name ASC, asg.avg_s_grade DESC, agg.avg_g_grade ASC
