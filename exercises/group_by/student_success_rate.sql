-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:

-- IO-45 Bondarchuk Mykhailo
-- Success rate by year of study

SELECT
    start_year::int AS student_year,
    ROUND(AVG(grade)::numeric, 2)::numeric(38,2) AS avg_year_grade
FROM
    enrolment
GROUP BY
    start_year
ORDER BY
    student_year ASC;