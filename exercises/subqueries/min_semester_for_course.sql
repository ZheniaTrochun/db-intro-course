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
    c.course_id AS course_id,
    c.name,
    (
        SELECT MIN(e.semester) 
        FROM enrolment e 
        WHERE e.course_id = c.course_id
    ) AS min_year
FROM course c
ORDER BY 
    min_year ASC, 
    c.name ASC;
