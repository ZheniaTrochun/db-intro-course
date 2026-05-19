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
    crs.name AS course_name,
    COUNT(enr.student_id) AS student_count,
    ROUND(AVG(enr.grade), 2) AS avg_grade
FROM course crs
INNER JOIN enrolment enr ON crs.course_id = enr.course_id
GROUP BY crs.course_id, crs.name
HAVING COUNT(enr.student_id) > 100
ORDER BY student_count DESC, course_name;
