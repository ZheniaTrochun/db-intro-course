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
SELECT e.start_year as student_year, COUNT(DISTINCT e.course_id) as number_of_courses,
       COUNT(*) as number_of_enrolments, COUNT(e.grade) as number_of_students_with_grade
  FROM enrolment e
 GROUP BY e.start_year
ORDER BY student_year;
