-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
SELECT
    c.id AS course_id,
    c.name,
    MIN(co.year) AS min_year
FROM courses c
JOIN course_offerings co
    ON c.id = co.course_id
GROUP BY c.id, c.name
ORDER BY
    min_year ASC,
    c.name ASC;