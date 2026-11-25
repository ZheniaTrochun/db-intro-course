-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (course_name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_levels AS (
SELECT
c.course_id,
c.course_name,
1 AS min_year
FROM course c
WHERE NOT EXISTS (
SELECT 1
FROM course_prerequisite cp
WHERE cp.course_id = c.course_id
)

UNION ALL

SELECT
c.course_id,
c.course_name,
cl.min_year + 1 AS min_year
FROM course_prerequisite cp
JOIN course_levels cl ON cp.prerequisite_course_id = cl.course_id
JOIN course c ON cp.course_id = c.course_id
)
SELECT
course_id,
course_name,
MAX(min_year) AS min_year
FROM course_levels
GROUP BY course_id, course_name
ORDER BY min_year ASC, course_name ASC;