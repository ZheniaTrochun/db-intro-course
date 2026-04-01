-- Завдання:
--      Для кожного курсу знайти мінімальний семестр, в якому він може читатись
--      Очікувані колонки результату:
--          - ідентифікатор курсу (course_id)
--          - назва курсу (name)
--          - мінімальний рік (min_year)
--      Результат відсортувати за:
--          - мінімальним роком (зростання), потім за назвою курсу

-- Рішення:
WITH RECURSIVE course_semester AS (
    -- Базовий випадок: курси без пре-реквізитів — читаються з 1-го семестру
    SELECT c.course_id, c.name, 1 AS min_year
    FROM course c
    WHERE NOT EXISTS (
        SELECT 1 FROM course_prerequisite cp WHERE cp.course_id = c.course_id
    )

    UNION ALL

    -- Рекурсивний крок: семестр курсу = семестр пре-реквізиту + 1
    SELECT cp.course_id, c.name, cs.min_year + 1
    FROM course_prerequisite cp
    JOIN course c          ON cp.course_id            = c.course_id
    JOIN course_semester cs ON cp.prerequisite_course_id = cs.course_id
)
SELECT course_id, name, MAX(min_year) AS min_year
FROM course_semester
GROUP BY course_id, name
ORDER BY min_year, name;
