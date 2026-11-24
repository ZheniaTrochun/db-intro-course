-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (course_name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_years AS (
    SELECT
        c.course_id AS course_id,
        1 AS min_year
    FROM course AS c
    UNION ALL
    SELECT
        cp.course_id,
        cy.min_year + 1
    FROM course_years AS cy
    JOIN course_prerequisite AS cp
        ON cp.prerequisite_course_id = cy.course_id
),
max_years AS (
    SELECT
        course_id,
        MAX(min_year) AS min_year
    FROM course_years
    GROUP BY course_id
)
SELECT
    c.course_id AS course_id,
    c.course_name AS course_name,
    my.min_year AS min_year
FROM course AS c
JOIN max_years AS my
    ON my.course_id = c.course_id
ORDER BY
    my.min_year ASC,
    c.course_name ASC;
