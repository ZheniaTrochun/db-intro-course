-- Завдання:
--      Знайти групи, в яких середній бал студентів вищий за 75
--      Очікувані колонки результату:
--          - назва групи (group_name)
--          - кількість студентів у групі (student_count)
--          - середній бал групи (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - середнім балом (спадання), потім за назвою групи

-- Рішення:
SELECT sg.name as group_name, COUNT(DISTINCT s.student_id) as student_count,
ROUND(AVG(e.grade), 2) as avg_grade
FROM enrolment e
LEFT JOIN student s on e.student_id = s.student_id
LEFT JOIN student_group sg on s.group_id = sg.group_id
WHERE e.grade is NOT NULL
GROUP BY sg.name, sg.group_id
HAVING ROUND(AVG(e.grade), 2) > 75
ORDER BY avg_grade DESC, group_name;