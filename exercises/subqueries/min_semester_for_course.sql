-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_hierarchy AS (
    SELECT course_id, 1 AS min_year
    FROM course
    WHERE course_id NOT IN (SELECT course_id FROM course_prerequisite)
    UNION ALL
    SELECT cp.course_id, ch.min_year + 1
    FROM course_prerequisite cp
    JOIN course_hierarchy ch ON cp.prerequisite_course_id = ch.course_id
)
SELECT 
    c.course_id,
    c.name,
    MAX(ch.min_year) AS min_year
FROM course c
JOIN course_hierarchy ch ON c.course_id = ch.course_id
GROUP BY c.course_id, c.name
ORDER BY min_year, c.name;