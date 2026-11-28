-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (course_name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:

WITH RECURSIVE course_dependencies AS (
  SELECT 
  	c.course_id, 
	1 AS level
  FROM course c
  LEFT JOIN course_prerequisite cp ON cp.course_id = c.course_id
  WHERE cp.course_id IS NULL

  UNION ALL

  SELECT 
  	cp.course_id, 
	cd.level + 1 as level
  FROM course_dependencies cd
  INNER JOIN course_prerequisite cp ON cd.course_id = cp.prerequisite_course_id

)
SELECT
	c.course_id,
	c.course_name, 
	MAX(cd.level) AS min_year
FROM course_dependencies cd
INNER JOIN course c ON c.course_id = cd.course_id
GROUP BY c.course_id, c.course_name
ORDER BY min_year, c.course_name;