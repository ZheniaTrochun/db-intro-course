-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
SELECT start_year as student_year, 
     ROUND(AVG(grade), 2) as avg_year_grade
FROM enrolment
GROUP BY start_year
ORDER BY student_year ASC;
