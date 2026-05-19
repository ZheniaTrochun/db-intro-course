-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
SELECT
    enrol.start_year AS student_year,
    ROUND(AVG(enrol.grade), 2) AS avg_year_grade
FROM enrolment enrol
GROUP BY enrol.start_year
ORDER BY student_year;
