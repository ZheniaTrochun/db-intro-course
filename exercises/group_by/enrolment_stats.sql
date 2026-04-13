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
    s.year AS student_year, 
    COUNT(DISTINCT e.course_id) AS number_of_courses,
    COUNT(e.id) AS number_of_enrolments, 
    COUNT(DISTINCT CASE WHEN e.grade IS NOT NULL THEN e.student_id END) AS number_of_students_with_grade
FROM students s
JOIN enrollments e ON s.id = e.student_id
GROUP BY s.year
ORDER BY student_year ASC;
