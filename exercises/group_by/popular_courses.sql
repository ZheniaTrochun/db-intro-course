-- Завдання:
--      Знайти курси, на які записано більше ніж 100 студентів
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - кількість студентів (student_count)
--          - середній бал (avg_grade) - середній бал серед студентів, які вже отримали оцінку - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю студентів (спадання), потім за назвою курсу

-- Рішення:
SELECT c.name AS course_name, COUNT(student_id) AS student_count, ROUND(AVG(grade), 2) AS avg_grade
FROM enrolment e
LEFT JOIN course c ON c.course_id = e.course_id
GROUP BY c.name
HAVING COUNT(student_id) > 100
ORDER BY student_count DESC, course_name