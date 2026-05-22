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
    s.course                                    AS student_year,
    COUNT(DISTINCT e.course_id)                 AS number_of_courses,
    COUNT(*)                                    AS number_of_enrolments,
    COUNT(*) FILTER (WHERE e.grade IS NOT NULL) AS number_of_students_with_grade
FROM enrolment e
JOIN student s ON s.student_id = e.student_id
GROUP BY s.course
ORDER BY s.course;