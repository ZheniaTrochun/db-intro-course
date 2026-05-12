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
start_year AS student_year,
COUNT(DISTINCT course_id) AS number_of_courses,
COUNT(1) AS number_of_enrolments,
SUM(CASE WHEN grade IS NOT NULL THEN 1 ELSE 0 END) AS number_of_students_with_grade
FROM enrolment
GROUP BY 1
ORDER BY 1;