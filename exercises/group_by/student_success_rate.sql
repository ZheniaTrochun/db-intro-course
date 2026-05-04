-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
WITH stats_source AS (
    SELECT 
        start_year,
        grade
    FROM enrolment
    WHERE grade IS NOT NULL
)
SELECT 
    start_year AS student_year,
    ROUND(AVG(grade), 2) AS avg_year_grade
FROM stats_source
GROUP BY start_year
ORDER BY student_year ASC;
