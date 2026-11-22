-- Завдання:
--      Знайти групи, в яких середній бал студентів вищий за 75
--      Очікувані колонки результату:
--          - назва групи (group_name)
--          - кількість студентів у групі (student_count)
--          - середній бал групи (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - середнім балом (спадання), потім за назвою групи

-- Рішення:
WITH group_stats AS (
    SELECT
        sg.group_id,
        sg.group_name,
        COUNT(DISTINCT s.student_id) AS student_count,
        AVG(e.grade) AS avg_grade
    FROM student_group AS sg
    JOIN student_group_assignment AS sga
        ON sga.group_id = sg.group_id
    JOIN student AS s
        ON s.student_id = sga.student_id
    JOIN enrolment AS e
        ON e.student_id = s.student_id
    WHERE e.grade IS NOT NULL
    GROUP BY
        sg.group_id,
        sg.group_name
    HAVING AVG(e.grade) > 75
)
SELECT
    group_name,
    student_count,
    ROUND(avg_grade, 2) AS avg_grade
FROM group_stats
ORDER BY
    ROUND(avg_grade, 2) DESC,
    group_name ASC;
