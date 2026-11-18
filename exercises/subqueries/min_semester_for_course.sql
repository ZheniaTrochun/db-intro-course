-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (course_name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:

SELECT 
    c.course_id,
    c.course_name,
    (
        SELECT MIN(sg.start_year)
        FROM enrolment e
        INNER JOIN student_group_assignment sga USING (student_id)
        INNER JOIN student_group sg USING (group_id)
        WHERE e.course_id = c.course_id
    ) AS min_year
FROM course c
ORDER BY min_year ASC, c.course_name ASC;