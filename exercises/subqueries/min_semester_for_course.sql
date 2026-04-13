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
        SELECT MIN(e.start_year - sg.start_year + 1)
        FROM enrolment e
        JOIN student s ON e.student_id = s.student_id
        JOIN student_group sg ON s.group_id = sg.group_id
        WHERE e.course_id = c.course_id AND e.grade IS NOT NULL
    ) AS min_year
FROM course c
ORDER BY 
    min_year ASC, 
    c.name ASC;
