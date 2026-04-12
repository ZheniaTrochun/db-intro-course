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
    COUNT(DISTINCT s.id) AS student_count,
    ROUND(AVG(e.grade), 2) AS avg_grade
FROM student_group sg
JOIN student s ON sg.id = s.group_id
JOIN enrolment e ON s.id = e.student_id
GROUP BY sg.id, sg.name
HAVING AVG(e.grade) > 75
ORDER BY 
    avg_grade DESC, 
    group_name ASC;
