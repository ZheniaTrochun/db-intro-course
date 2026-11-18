-- Завдання:
--      Порахувати статистику записів на курси для кожного року запису на курс
--      Очікувані колонки результату:
--          - рік запису на курс (enrolment_year) - рік з enrolment.created_at
--          - кількість курсів (number_of_courses)
--          - кількість записів (number_of_enrolments)
--          - кількість записів з виставленою оцінкою (number_of_graded_enrolments)
--      Результат відсортувати за:
--          - роком запису на курс (зростання)

-- Рішення:
SELECT 
    EXTRACT(YEAR FROM e.created_at) AS enrolment_year,
    COUNT(DISTINCT e.course_id) AS number_of_courses,
    COUNT(e.student_id) AS number_of_enrolments,
    COUNT(e.grade) AS number_of_graded_enrolments
FROM enrolment e
GROUP BY enrolment_year
ORDER BY enrolment_year;