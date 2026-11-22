-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (course_name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_year AS (
    SELECT
        c.course_id,
        1 AS year
    FROM course c
    WHERE NOT EXISTS (
        SELECT 1
        FROM course_prerequisite cp
        WHERE cp.course_id = c.course_id
    )

    UNION ALL

    SELECT
        cp.course_id,
        cy.year + 1
    FROM course_prerequisite cp
    JOIN course_year cy ON cy.course_id = cp.prerequisite_course_id
)
SELECT
    c.course_id,
    c.course_name,
    MAX(cy.year) AS min_year
FROM course c
JOIN course_year cy ON cy.course_id = c.course_id
GROUP BY c.course_id, c.course_name
ORDER BY min_year ASC, c.course_name ASC;