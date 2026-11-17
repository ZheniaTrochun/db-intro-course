-- Завдання:
--      Порахувати успішність студентів залежно від року вступу їхньої групи
--      Очікувані колонки результату:
--          - рік вступу групи (start_year) - student_group.start_year
--          - середній бал студентів груп цього року вступу (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком вступу групи (зростання)

-- Рішення:

SELECT 
	g.start_year,
	ROUND(AVG(e.grade), 2) AS avg_grade
FROM student_group g
INNER JOIN student_group_assignment assign USING(group_id)
INNER JOIN student s USING(student_id)
INNER JOIN enrolment e USING(student_id)
GROUP BY g.start_year
ORDER BY g.start_year ASC;