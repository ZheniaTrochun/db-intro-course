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
COUNT(*) AS student_count,
ROUND(AVG(e.grade), 2) AS avg_grade
FROM course c
INNER JOIN enrolment e USING (course_id)
GROUP BY c.name
HAVING
COUNT(*) > 100
ORDER BY 2 DESC, 1 ASC;