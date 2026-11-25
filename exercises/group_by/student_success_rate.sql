-- Завдання:
--      Порахувати успішність студентів залежно від року вступу їхньої групи
--      Очікувані колонки результату:
--          - рік вступу групи (start_year) - student_group.start_year
--          - середній бал студентів груп цього року вступу (avg_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - роком вступу групи (зростання)

-- Рішення:
SELECT
sg.start_year,
ROUND(AVG(e.grade), 2) AS avg_grade
FROM student_group sg
JOIN student_group_assignment sga ON sg.group_id = sga.group_id
JOIN enrolment e ON sga.student_id = e.student_id
GROUP BY sg.start_year
ORDER BY sg.start_year ASC;