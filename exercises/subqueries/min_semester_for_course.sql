-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_depth AS (
    SELECT
        course_id,
        1 AS min_year
    FROM course
    WHERE course_id NOT IN (SELECT course_id FROM course_prerequisite)

    UNION ALL

    SELECT
        cp.course_id,
        cd.min_year + 1
    FROM course_prerequisite cp
    JOIN course_depth cd ON cd.course_id = cp.prerequisite_course_id
)
SELECT
    c.course_id,
    c.name,
    MAX(cd.min_year) AS min_year
FROM course_depth cd
JOIN course c ON c.course_id = cd.course_id
GROUP BY c.course_id, c.name
ORDER BY min_year, c.name;