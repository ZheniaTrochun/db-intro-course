-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_dependencies AS (
    -- Початковий крок: курси без пререквізитів (1 семестр)
    SELECT c.course_id, 1 AS level
    FROM course c
    WHERE NOT EXISTS (
        SELECT 1 FROM course_prerequisite pr WHERE pr.course_id = c.course_id
    )
    
    UNION ALL
    
    -- Рекурсивний крок: курси, які залежать від попередніх
    SELECT pr.course_id, cd.level + 1 AS level
    FROM course_dependencies cd
    JOIN course_prerequisite pr ON cd.course_id = pr.prerequisite_course_id
)
SELECT 
    c.course_id,
    c.name,
    MAX(cd.level) AS min_year
FROM course_dependencies cd
JOIN course c ON cd.course_id = c.course_id
GROUP BY 
    c.course_id, 
    c.name
ORDER BY 
    min_year ASC, 
    c.name ASC;