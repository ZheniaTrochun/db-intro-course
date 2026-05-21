-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE CourseDepth AS (
    SELECT 
        c.course_id, 
        c.name, 
        1 AS min_year
    FROM course c
    LEFT JOIN course_prerequisite cp ON c.course_id = cp.course_id
    WHERE cp.prerequisite_course_id IS NULL

    UNION ALL

    SELECT 
        c.course_id, 
        c.name, 
        cd.min_year + 1
    FROM course c
    JOIN course_prerequisite cp ON c.course_id = cp.course_id
    JOIN CourseDepth cd ON cp.prerequisite_course_id = cd.course_id
)
SELECT 
    course_id, 
    name, 
    MAX(min_year)::int AS min_year
FROM CourseDepth
GROUP BY course_id, name
ORDER BY 
    min_year ASC, 
    name ASC, 
    course_id ASC