-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:

WITH RECURSIVE PrereqTree AS (
SELECT course_id, name, 1 AS min_year
FROM course
WHERE course_id NOT IN (

SELECT course_id 
FROM course_prerequisite 
WHERE course_id IS NOT NULL
)

UNION ALL
SELECT cp.course_id, c.name, pt.min_year + 1
FROM course_prerequisite cp
JOIN PrereqTree pt ON cp.prerequisite_course_id = pt.course_id
JOIN course c ON cp.course_id = c.course_id
)
SELECT course_id,  name, 
MAX(min_year) AS min_year
FROM PrereqTree
GROUP BY 1, 2
ORDER BY 3 ASC, 2 ASC;