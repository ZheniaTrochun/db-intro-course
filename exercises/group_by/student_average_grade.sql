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
    c.name AS course_name,
    COUNT(e.student_id) AS student_count,
    ROUND(AVG(e.grade), 2) AS avg_grade
FROM 
    course c
JOIN 
    enrolment e ON c.course_id = e.course_id
GROUP BY 
    c.name
HAVING 
    COUNT(e.student_id) > 100
ORDER BY 
    student_count DESC, 
    course_name ASC;