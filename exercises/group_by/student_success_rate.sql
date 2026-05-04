-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
SELECT
 e.start_year as student_year,
 ROUND(AVG(e.grade), 2) as avg_year_grade
FROM enrolment e
GROUP by e.start_year
ORDER by student_year ASC;