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
    sg.start_year                 AS student_year,
    COUNT(DISTINCT e.course_id)   AS number_of_courses,
    COUNT(*)                      AS number_of_enrolments,
    COUNT(e.grade)                AS number_of_students_with_grade
FROM enrolment e
JOIN student_group_assignment sga ON sga.student_id = e.student_id
JOIN student_group sg             ON sg.group_id    = sga.group_id
GROUP BY sg.start_year
ORDER BY sg.start_year ASC;