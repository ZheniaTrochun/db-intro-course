-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
SELECT 
    e.start_year AS student_year,
    ROUND(AVG(e.grade)::numeric, 2) AS avg_year_grade
FROM student s
JOIN enrolment e 
    ON e.student_id = s.student_id
WHERE e.grade IS NOT NULL
GROUP BY e.start_year
ORDER BY e.start_year ASC;