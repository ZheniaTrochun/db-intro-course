-- Завдання:
--      Знайти групи, в яких середній бал студентів вищий за 75
--      Очікувані колонки результату:
--          - назва групи (group_name)
--          - кількість студентів у групі (student_count)
--          - середній бал групи (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - середнім балом (спадання), потім за назвою групи

-- Рішення:
WITH group_metrics AS (
    -- Збираємо статистику тільки по тих записах, де вже виставлено оцінку
    SELECT 
        s.group_id,
        COUNT(DISTINCT s.student_id) AS student_count,
        AVG(e.grade) AS raw_avg_grade
    FROM student s
    JOIN enrolment e ON s.student_id = e.student_id
    WHERE e.grade IS NOT NULL -- Враховуємо тільки студентів з оцінками
    GROUP BY s.group_id
    HAVING AVG(e.grade) > 75
)
SELECT 
    sg.name AS group_name,
    gm.student_count,
    ROUND(gm.raw_avg_grade, 2)::float AS avg_grade
FROM group_metrics gm
JOIN student_group sg ON gm.group_id = sg.group_id
ORDER BY avg_grade DESC, group_name ASC