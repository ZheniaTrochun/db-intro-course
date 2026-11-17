-- Завдання:
--      Знайти групи, в яких середній бал студентів вищий за 75
--      Очікувані колонки результату:
--          - назва групи (group_name)
--          - кількість студентів у групі (student_count)
--          - середній бал групи (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - середнім балом (спадання), потім за назвою групи

-- Рішення:

SELECT 
	g.group_name,
	COUNT(DISTINCT sga.student_id) AS student_count,
	ROUND(AVG(e.grade), 2)::float8 AS avg_grade
FROM student_group g
INNER JOIN student_group_assignment sga USING(group_id)
INNER JOIN student s USING(student_id)
INNER JOIN enrolment e USING(student_id)
WHERE e.grade IS NOT NULL
GROUP BY g.group_id
	HAVING AVG(COALESCE(e.grade, 0)) > 75
ORDER BY avg_grade DESC, g.group_name;

