-- Завдання:
--      Знайти групи, в яких середній бал студентів вищий за 75
--      Очікувані колонки результату:
--          - назва групи (group_name)
--          - кількість студентів у групі (student_count)
--          - середній бал групи (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - середнім балом (спадання), потім за назвою групи

-- Рішення:
SELECT
    sg.name AS group_name,
    COUNT(DISTINCT s.student_id) AS student_count,
    ROUND(AVG(enr.grade), 2) AS avg_grade
FROM student_group sg
INNER JOIN student s ON sg.group_id = s.group_id
INNER JOIN enrolment enr ON s.student_id = enr.student_id
WHERE enr.grade IS NOT NULL
GROUP BY sg.group_id, sg.name
HAVING AVG(enr.grade) > 75
ORDER BY avg_grade DESC, group_name;
