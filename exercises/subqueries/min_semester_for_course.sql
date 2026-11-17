-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (course_name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:

WITH RECURSIVE prerequisites_count AS (
	SELECT 
		c.course_id,
		c.course_name,
		1 AS min_year
	FROM course c
	LEFT JOIN course_prerequisite pr USING(course_id)
	WHERE prerequisite_course_id IS NULL

	UNION ALL

	SELECT 
		c.course_id,
		c.course_name,
		min_year + 1 AS min_year
	FROM course c
	INNER JOIN course_prerequisite pr USING(course_id)
	INNER JOIN prerequisites_count pc ON pr.prerequisite_course_id = pc.course_id
)

SELECT 
    course_id, 
    course_name, 
    MAX(min_year) AS min_year
FROM prerequisites_count
GROUP BY course_id, course_name
ORDER BY min_year ASC, course_name ASC;