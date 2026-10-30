-- Завдання:
--      Порахувати успішність студентів залежно від року вступу їхньої групи
--      Очікувані колонки результату:
--          - рік вступу групи (start_year) - student_group.start_year
--          - середній бал студентів груп цього року вступу (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком вступу групи (зростання)

-- Рішення:
SELECT student.student_year, ROUND(AVG(enrolment.grade), 2) AS avg_year_grade
FROM student
INNER JOIN enrolment USING (student_id)
GROUP BY student.student_year
ORDER BY student.student_year;
