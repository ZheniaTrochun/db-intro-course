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
    ROUND (AVG (e.grade), 2) AS avg_grade
FROM student_group sg
    JOIN student_group_assignment sga ON sga.group_id = sg.group_id
    JOIN student s ON s.student_id = sga.student_id
    JOIN enrolment e ON e.student_id = s.student_id
GROUP BY sg.start_year
ORDER BY start_year ASC