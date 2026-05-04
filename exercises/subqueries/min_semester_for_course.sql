-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE prerequisite_tree AS (
    SELECT 
        c.course_id, 
        1 AS min_year
    FROM course c
    WHERE c.course_id NOT IN (SELECT course_id FROM course_prerequisite)

    UNION ALL

    SELECT 
        cp.course_id, 
        pt.min_year + 1
    FROM course_prerequisite cp
    JOIN prerequisite_tree pt ON cp.prerequisite_course_id = pt.course_id
),
course_min_semester AS (
    SELECT 
        course_id, 
        MAX(min_year) AS min_year
    FROM prerequisite_tree
    GROUP BY course_id
)
SELECT 
    c.course_id,
    c.name,
    cms.min_year
FROM course c
JOIN course_min_semester cms ON c.course_id = cms.course_id
ORDER BY 
    cms.min_year ASC, 
    c.name ASC;