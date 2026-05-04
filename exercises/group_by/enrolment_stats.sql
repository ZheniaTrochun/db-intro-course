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
WITH yearly_data AS (
    SELECT
        start_year,
        course_id,
        student_id,
        grade
    FROM enrolment
)
SELECT 
    start_year AS student_year,
    COUNT(DISTINCT course_id) AS number_of_courses,
    COUNT(student_id) AS number_of_enrolments,
    COUNT(grade) AS number_of_students_with_grade
FROM yearly_data
GROUP BY start_year
ORDER BY student_year ASC;
