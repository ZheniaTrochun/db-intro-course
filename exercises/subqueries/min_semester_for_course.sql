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
    SELECT c.course_id, 1 AS level
    FROM course c
    WHERE NOT EXISTS (
        SELECT 1
        FROM course_prerequisite cp
        WHERE cp.course_id = c.course_id
    )

    UNION ALL

    SELECT cp.course_id, cd.level + 1 AS level
    FROM course_dependencies cd
    INNER JOIN course_prerequisite cp
        ON cp.prerequisite_course_id = cd.course_id
)
SELECT
    c.course_id,
    c.course_name,
    COALESCE(MAX(cd.level), 1) AS min_year
FROM course c
LEFT JOIN course_dependencies cd USING (course_id)
GROUP BY c.course_id, c.course_name
ORDER BY min_year ASC, c.course_name ASC;