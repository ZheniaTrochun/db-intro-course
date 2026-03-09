-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
SELECT
s.id AS student_id,
s.first_name || ' ' || s.last_name AS full_name,
ROUND(
CAST(COUNT(CASE WHEN e.grade >= 60 THEN 1 END) AS FLOAT) * 100 / COUNT(e.course_id),2) AS success_rate
FROM students s
JOIN enrolments e
    ON s.id = e.student_id
GROUP BY s.id, full_name
ORDER BY success_rate DESC, full_name ASC;