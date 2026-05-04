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
SELECT enrolment.start_year as student_year, 
        COUNT(DISTINCT enrolment.course_id) as number_of_courses, 
        COUNT(*) as number_of_enrolments, 
        COUNT(enrolment.grade) as number_of_students_with_grade 
    FROM enrolment 
GROUP BY enrolment.start_year ORDER BY enrolment.start_year;