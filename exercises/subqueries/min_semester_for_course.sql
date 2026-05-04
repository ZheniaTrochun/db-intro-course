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
    MIN(e.start_year - s.student_year + 1) AS min_year
FROM course c
JOIN enrolment e ON c.course_id = e.course_id
JOIN student s ON e.student_id = s.student_id
GROUP BY c.course_id, c.name
ORDER BY min_year ASC, c.name ASC;
