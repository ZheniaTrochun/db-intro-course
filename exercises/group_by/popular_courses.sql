-- Завдання:
--      Знайти курси, на які записано більше ніж 100 студентів
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - кількість студентів (student_count)
--          - середній бал (avg_grade) - середній бал серед студентів, які вже отримали оцінку - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю студентів (спадання), потім за назвою курсу

-- Рішення:
SELECT
    c.name AS course_name,
    COUNT(e.student_id) AS student_count,
    ROUND(AVG(e.grade), 2) AS avg_grade
FROM courses c
JOIN enrollments e
    ON c.id = e.course_id
GROUP BY c.id, c.name
HAVING COUNT(e.student_id) > 100
ORDER BY student_count DESC, course_name ASC;