-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
SELECT 
    EXTRACT(YEAR FROM s.start_date) AS student_year,
    ROUND(AVG(e.grade), 2) AS avg_year_grade
FROM student s
JOIN enrolment e ON s.student_id = e.student_id
GROUP BY EXTRACT(YEAR FROM s.start_date)
ORDER BY student_year ASC;
