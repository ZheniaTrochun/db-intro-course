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
    SELECT course_id, 1 as level
    FROM course c
    WHERE NOT EXISTS (
        SELECT 1 
        FROM course_prerequisite p 
        WHERE p.course_id = c.course_id)
    UNION ALL
    SELECT p.course_id as course_id, 
    cd.level + 1 as level
    FROM course_prerequisite p
             INNER JOIN course_dependencies cd ON p.prerequisite_course_id = cd.course_id)
SELECT  c.course_id, c.name, MAX(cd.level) as min_year
FROM course c 
INNER JOIN course_dependencies cd USING (course_id)
GROUP BY c.course_id, c.name
ORDER BY min_year ASC, c.name ASC;