-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_levels AS (
    SELECT 
        c.course_id, 
        1 AS current_level
    FROM course c
    WHERE NOT EXISTS (
        SELECT 1 
        FROM course_prerequisite cp 
        WHERE cp.course_id = c.course_id
    )
    
    UNION ALL
    SELECT 
        cp.course_id, 
        cl.current_level + 1
    FROM course_prerequisite cp
    INNER JOIN course_levels cl ON cl.course_id = cp.prerequisite_course_id
),
max_depth_per_course AS (
    SELECT 
        course_id, 
        MAX(current_level) AS min_year
    FROM course_levels
    GROUP BY course_id
)
SELECT 
    c.course_id,
    c.name,
    md.min_year
FROM course c
INNER JOIN max_depth_per_course md ON c.course_id = md.course_id
ORDER BY 
    md.min_year ASC, 
    c.name ASC;
