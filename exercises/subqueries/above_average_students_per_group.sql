-- Завдання:
--      Знайти студентів, чий середній бал перевищує середній бал їхньої групи
--      Використати два CTE: один для середнього балу студента, інший для середнього балу групи
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - назва групи (group_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - середній бал групи (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента

-- Рішення:
SELECT 
    s.first_name || ' ' || s.last_name AS student_name,
    g.name AS group_name,
    ROUND(avg_s.personal_avg, 2) AS average_grade
FROM students s
JOIN groups g ON s.group_id = g.id
JOIN (
    SELECT student_id, AVG(grade) as personal_avg 
    FROM enrolments GROUP BY student_id
) avg_s ON s.id = avg_s.student_id
WHERE avg_s.personal_avg > (
    SELECT AVG(e2.grade)
    FROM students s2
    JOIN enrolments e2 ON s2.id = e2.student_id
    WHERE s2.group_id = s.group_id
)
ORDER BY group_name, average_grade DESC;