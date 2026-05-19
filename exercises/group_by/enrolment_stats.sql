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
    enr.start_year AS student_year,
    COUNT(DISTINCT enr.course_id) AS number_of_courses,
    COUNT(1) AS number_of_enrolments,
    COUNT(enr.grade) AS number_of_students_with_grade
FROM enrolment enr
GROUP BY enr.start_year
ORDER BY student_year ASC;
