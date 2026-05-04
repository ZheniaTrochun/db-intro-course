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
    COALESCE(
        (SELECT MAX(p.year) + 1 
         FROM course_prerequisites cp
         JOIN courses p ON cp.prerequisite_id = p.id
         WHERE cp.course_id = c.id), 
    1) AS min_year
FROM courses c
ORDER BY min_year ASC, c.name ASC;
