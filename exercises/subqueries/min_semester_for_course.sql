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
    c.course_id,
    c.name,
    e.min_year
FROM course c
JOIN (
    SELECT course_id, MIN(start_year) AS min_year
    FROM enrolment
    GROUP BY course_id
) e ON c.course_id = e.course_id
ORDER BY 
    min_year ASC, 
    name ASC;