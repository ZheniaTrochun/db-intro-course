-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента

-- Рішення:
SELECT 
    s.id AS student_id,
    p.first_name || ' ' || p.last_name AS full_name,
    ROUND(AVG(e.grade), 2) AS avg_student_grade,
    sg.name AS group_name,
    ga.avg_group_grade
FROM student s
JOIN person p ON s.person_id = p.id
JOIN student_group sg ON s.group_id = sg.id
JOIN enrolment e ON s.id = e.student_id
JOIN (
    
    SELECT 
        s2.group_id, 
        ROUND(AVG(e2.grade), 2) AS avg_group_grade
    FROM student s2
    JOIN enrolment e2 ON s2.id = e2.student_id
    GROUP BY s2.group_id
) ga ON sg.id = ga.group_id
GROUP BY 
    s.id, 
    p.first_name, 
    p.last_name, 
    sg.name, 
    ga.avg_group_grade
ORDER BY 
    group_name ASC, 
    full_name ASC;
