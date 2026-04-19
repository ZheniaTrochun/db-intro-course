-- Завдання:
--      Порахувати статистику записів на курси для кожного року навчання
--      Очікувані колонки результату:
--          - рік навчання (student_year)
--          - кількість курсів (number_of_courses)
--          - кількість записів (number_of_enrollments)
--          - кількість студентів, що вже отримали бали (number_of_students_with_grade)
--      Результат відсортувати за:
--          - роком навчання (зростання)

-- Рішення:
SELECT
    s.year_of_study AS student_year,
    COUNT(DISTINCT e.course_id) AS number_of_courses,
    COUNT(e.student_id) AS number_of_enrollments,
    COUNT(e.grade) AS number_of_students_with_grade
FROM students s
GROUP BY s.year_of_study
ORDER BY student_year ASC;



