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
    sg.start_year AS student_year,
    COUNT(DISTINCT e.course_id) AS number_of_courses,
    COUNT(e.course_id) AS number_of_enrolments,
    COUNT(e.grade) AS number_of_students_with_grade
FROM enrolment e
JOIN student_group_assignment sga ON e.student_id = sga.student_id
JOIN student_group sg ON sga.group_id = sg.group_id
GROUP BY sg.start_year
ORDER BY student_year ASC;