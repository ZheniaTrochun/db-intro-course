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
    g.name AS group_name,
    ROUND(AVG(e.grade), 2) AS average_grade
FROM groups g
JOIN students s ON g.id = s.group_id
JOIN enrolments e ON s.id = e.student_id
GROUP BY g.id, g.name
HAVING AVG(e.grade) > 75
ORDER BY average_grade DESC;