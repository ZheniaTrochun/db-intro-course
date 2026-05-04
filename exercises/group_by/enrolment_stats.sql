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
SELECT start_year as student_year, 
     COUNT (DISTINCT (course_id)) as number_of_courses, 
     COUNT(*) as number_of_enrolments,
     count(*) FILTER (WHERE grade is not null) as number_of_students_with_grade
FROM enrolment
GROUP BY start_year
ORDER BY student_year ASC;