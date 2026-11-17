-- Завдання:
--      Знайти курси, на які записано більше ніж 100 студентів
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - кількість студентів (student_count)
--          - середній бал (avg_grade) - середній бал серед студентів, які вже отримали оцінку - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю студентів (спадання), потім за назвою курсу

-- Рішення:

SELECT 
	c.course_name,
	COUNT(DISTINCT e.student_id) AS student_count,
	ROUND(AVG(e.grade), 2) AS avg_grade
FROM course c
INNER JOIN enrolment e USING(course_id)
GROUP BY c.course_id, c.course_name
HAVING COUNT(e.grade) > 0
	AND COUNT(DISTINCT e.student_id) > 100
ORDER BY student_count DESC, c.course_name;