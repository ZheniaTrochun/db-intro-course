-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:

WITH RECURSIVE course_levels AS (
SELECT course_id, name, 1 AS semester
FROM course
WHERE course_id NOT IN (SELECT course_id FROM course_prerequisite)
UNION ALL
SELECT c.course_id, c.name, cl.semester + 1
FROM course c
JOIN course_prerequisite cp ON c.course_id = cp.course_id
JOIN course_levels cl ON cp.prerequisite_course_id = cl.course_id)
SELECT name, MAX(semester) AS min_semester
FROM course_levels
GROUP BY name
ORDER BY min_semester ASC, name ASC;