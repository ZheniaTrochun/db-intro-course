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
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента, потім за ідентифікатором студента

-- Рішення:
SELECT
    s.student_id,
    p.first_name || ' ' || p.Last_name AS full_name,
    avg_sg.group_name,
    avg_s.avg_student_grade,
    avg_sg.avg_group_grade
FROM student s
    JOIN ( --Avg student
        SELECT
            s.student_id,
            ROUND (AVG (e.grade), 2) AS avg_student_grade
        FROM student s
            JOIN enrolment e USING (student_id)
        WHERE e.grade IS NOT NULL
        GROUP BY s.student_id
    ) avg_s USING (student_id)
    JOIN student_group_assignment sga USING (student_id)
    JOIN ( --Avg group
        SELECT
            sg.group_id,
            sg.group_name,
            ROUND (AVG (e.grade), 2) AS avg_group_grade
        FROM student_group sg
            JOIN student_group_assignment sga USING (group_id)
            JOIN student s USING (student_id)
            JOIN enrolment e USING (student_id)
        WHERE e.grade IS NOT NULL
        GROUP BY sg.group_id, sg.group_name
    ) avg_sg USING (group_id)
    JOIN person p USING (person_id)
WHERE avg_s.avg_student_grade > avg_sg.avg_group_grade
ORDER BY group_name, avg_student_grade DESC, full_name, student_id