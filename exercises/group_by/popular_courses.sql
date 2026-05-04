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
 c.name as course_name,
 COUNT(e.student_id) as student_count,
 ROUND(AVG(e.grade), 2) as avg_grade
FROM course c
JOIN enrolment e on c.course_id = e.course_id
GROUP by c.course_id, c.name
HAVING COUNT(e.student_id) > 100
ORDER by student_count DESC, course_name ASC;