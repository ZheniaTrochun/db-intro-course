-- Завдання:
--      Порахувати статистику записів на курси для кожного року навчання
--      Очікувані колонки результату:
--          - рік навчання (student_year)
--          - кількість курсів (number_of_courses)
--          - кількість записів (number_of_enrolments)
--          - кількість студентів, що вже отримали бали (number_of_students_with_grade)
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
SELECT 
    study_year,
    COUNT(*) AS total_enrolments,
    ROUND(AVG(grade), 2) AS average_grade
FROM campus.students s
JOIN campus.enrolments e ON s.id = e.student_id
GROUP BY study_year
ORDER BY study_year;