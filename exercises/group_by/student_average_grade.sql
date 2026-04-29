-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента

-- Рішення:
SELECT s.student_id as student_id, p.first_name || ' ' || p.last_name as full_name, round(AVG(e.grade), 2) as avg_student_grade, 
	sg.name as group_name, round((AVG(AVG(e.grade)) over (PARTITION BY s.group_id)), 2) as avg_group_grade
FROM enrolment e
	JOIN student s USING (student_id)
	JOIN person p USING (person_id)
	JOIN student_group sg USING (group_id)
	GROUP BY s.student_id, p.first_name, p.last_name, sg.name, sg.group_id
ORDER BY group_name, full_name;