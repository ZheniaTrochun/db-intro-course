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
    ROUND(COALESCE(AVG(e.grade), 0), 2) AS avg_grade
FROM student_group sg
INNER JOIN student_group_assignment sga USING (group_id)
INNER JOIN student s USING (student_id)
LEFT JOIN enrolment e USING (student_id)
GROUP BY sg.start_year
ORDER BY sg.start_year;
