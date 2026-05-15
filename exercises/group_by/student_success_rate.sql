-- Завдання:
--      Порахувати успішність студентів залежно від року навчання
--      Очікувані колонки результату:
--          - рік навчання студентів (student_year)
--          - середній бал за рік (avg_year_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
SELECT 
    study_year,
    ROUND(AVG(grade), 2) AS success_rate
FROM campus.students s
JOIN campus.enrolments e ON s.id = e.student_id
GROUP BY study_year
ORDER BY success_rate DESC;