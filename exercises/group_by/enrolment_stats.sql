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
    FLOOR(DATE_PART('year', created_at)) AS enrolment_year,
    COUNT (DISTINCT course_id) AS number_of_courses,
    COUNT (*) AS number_of_enrolments,
    COUNT (grade) AS number_of_graded_enrolments
FROM enrolment
GROUP BY DATE_PART('year', created_at)
ORDER BY enrolment_year ASC