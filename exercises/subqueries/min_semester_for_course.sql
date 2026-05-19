-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_year AS (
SELECT c.course_id, c.name, 1 AS min_year
FROM course c
WHERE NOT EXISTS (SELECT 1 FROM course_prerequisite cp WHERE cp.course_id = c.course_id)
UNION ALL
SELECT c.course_id, c.name, cy.min_year + 1
FROM course c
JOIN course_prerequisite cp ON cp.course_id = c.course_id
JOIN course_year cy ON cy.course_id = cp.prerequisite_course_id
)
SELECT course_id, name, MAX(min_year) AS min_year
FROM course_year
GROUP BY course_id, name
ORDER BY MAX(min_year) ASC, name;
