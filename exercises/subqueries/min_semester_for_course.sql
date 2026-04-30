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
    SELECT c.course_id, c.name, 1 AS min_year
    FROM course c
    WHERE c.course_id NOT IN (SELECT cp.course_id FROM course_prerequisite cp)

    UNION ALL

    SELECT c.course_id, c.name, cl.min_year + 1
    FROM course c
    JOIN course_prerequisite cp ON c.course_id = cp.course_id
    JOIN course_levels cl ON cp.prerequisite_course_id = cl.course_id
)
SELECT cl.course_id as course_id, cl.name as name, MAX(cl.min_year) AS min_year
FROM course_levels cl
WHERE EXISTS (SELECT 1 FROM enrolment e WHERE e.course_id = cl.course_id)
GROUP BY course_id, name
ORDER BY min_year, name