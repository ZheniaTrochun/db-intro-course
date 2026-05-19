-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_depth AS (
    SELECT 
        crs.course_id, 
        crs.name, 
        1 AS min_year
    FROM course crs
    WHERE NOT EXISTS (
        SELECT 1 
        FROM course_prerequisite cp 
        WHERE cp.course_id = crs.course_id
    )
    UNION ALL
    SELECT 
        crs.course_id, 
        crs.name, 
        cd.min_year + 1
    FROM course crs
    INNER JOIN course_prerequisite cp ON crs.course_id = cp.course_id
    INNER JOIN course_depth cd ON cp.prerequisite_course_id = cd.course_id
)
SELECT 
    course_id, 
    name, 
    MAX(min_year) AS min_year
FROM course_depth
GROUP BY course_id, name
ORDER BY min_year ASC, name;
