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
SELECT DISTINCT
    s.id AS student_id,
    s.first_name || ' ' || s.last_name AS full_name,
    ROUND(AVG(e.grade) OVER (PARTITION BY s.id), 2) AS avg_student_grade,
    g.name AS group_name,
    ROUND(AVG(e.grade) OVER (PARTITION BY g.id), 2) AS avg_group_grade
FROM students s
JOIN groups g ON s.group_id = g.id
JOIN enrollments e ON s.id = e.student_id
ORDER BY group_name ASC, full_name ASC;
