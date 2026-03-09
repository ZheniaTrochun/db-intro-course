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
ROUND(AVG(e.grade), 2) AS avg_grade
FROM groups g
JOIN students s
    ON g.id = s.group_id
JOIN enrolments e
    ON s.id = e.student_id
WHERE e.grade IS NOT NULL
GROUP BY g.id, g.name
HAVING avg_grade > 75
ORDER BY avg_grade DESC, group_name ASC;