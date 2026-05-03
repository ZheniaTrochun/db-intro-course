-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE prereq_chain AS (
    -- База: курси без пре-реквізитів → рік 1
    SELECT course_id, 1 AS min_year
    FROM course
    WHERE course_id NOT IN (SELECT course_id FROM course_prerequisite)
    
    UNION ALL
    
    -- Рекурсія: курс з пре-реквізитом → рік пре-реквізиту + 1
    SELECT cp.course_id, pc.min_year + 1
    FROM course_prerequisite cp
    JOIN prereq_chain pc ON pc.course_id = cp.prerequisite_course_id
)
SELECT 
    c.course_id,
    c.name,
    MAX(min_year) AS min_year
FROM prereq_chain rc
JOIN course c ON c.course_id = rc.course_id
GROUP BY c.course_id, c.name
ORDER BY min_year ASC, c.name ASC;