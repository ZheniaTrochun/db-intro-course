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
    SELECT course_id, 1 as lvl
    FROM course
    WHERE course_id NOT IN (SELECT course_id FROM course_prerequisite)

UNION ALL

    SELECT cp.course_id, cl.lvl + 1
      FROM course_prerequisite as cp
      JOIN course_levels cl ON cp.prerequisite_course_id = cl.course_id
)

SELECT c.course_id, c.name, MAX(cl.lvl) as min_year
  FROM course as c
  JOIN course_levels cl ON c.course_id = cl.course_id
 GROUP BY c.course_id, c.name
 ORDER BY min_year, c.name;