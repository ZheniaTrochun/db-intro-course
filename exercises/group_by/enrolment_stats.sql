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

ІО-41 Кореняко Антон

select start_year as student_year, count(distinct course_id) as number_of_courses,
count(*) as number_of_enrolments, count(grade) as number_of_students_with_grade

from enrolment
group by start_year
order by start_year

