-- Завдання:
--      Порахувати успішність студентів залежно від року вступу їхньої групи
--      Очікувані колонки результату:
--          - рік вступу групи (start_year) - student_group.start_year
--          - середній бал студентів груп цього року вступу (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком вступу групи (зростання)

-- Рішення:
SELECT EXTRACT(YEAR FROM CURRENT_DATE)::int - student_group.start_year + 1 AS student_year, ROUND(AVG(enrolment.grade), 2) AS avg_year_grade
FROM enrolment
INNER JOIN student_group_assignment USING (student_id)
INNER JOIN student_group USING (group_id)
GROUP BY student_year
ORDER BY student_year;
