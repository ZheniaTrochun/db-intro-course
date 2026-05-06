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
SELECT s.student_id,
	   p.first_name || ' ' || p.last_name AS full_name,
	   ROUND(AVG(e.grade), 2) AS avg_student_grade,
	   sg.name AS group_name,
	   ROUND((AVG(AVG(e.grade)) OVER (PARTITION BY s.group_id)), 2) AS avg_group_grade
FROM student s 
JOIN student_group sg USING(group_id)
JOIN person p USING(person_id)
JOIN enrolment e USING(student_id)
GROUP BY s.student_id, p.first_name, p.last_name, sg.name
ORDER BY sg.name, full_name;