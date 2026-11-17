-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента, потім за ідентифікатором студента

-- Рішення:

SELECT 
	s.student_id, 
	concat_ws(' ', p.first_name, p.last_name) AS full_name,
	ROUND(AVG(e.grade), 2)::float8 AS avg_student_grade,
	g.group_name, 
	COALESCE(ROUND(AVG(AVG(e.grade)) OVER (PARTITION BY g.group_id), 2), 0)::float8 AS avg_group_grade
FROM student s
INNER JOIN person p USING(person_id)
LEFT JOIN enrolment e USING(student_id)
INNER JOIN student_group_assignment sga USING(student_id)
INNER JOIN student_group g USING(group_id)
GROUP BY s.student_id, full_name, g.group_name, g.group_id
ORDER BY g.group_name, full_name, s.student_id;