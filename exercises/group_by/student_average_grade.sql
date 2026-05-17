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


--ІО-41 Кореняко Антон

SELECT
    s.student_id,
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    CAST(ROUND(AVG(e.grade)::numeric, 2) AS DOUBLE PRECISION) AS avg_student_grade,
    sg.name AS group_name,
    CAST(ROUND(AVG(AVG(e.grade)) OVER (PARTITION BY s.group_id)::numeric, 2) AS DOUBLE PRECISION) AS avg_group_grade
FROM student s
JOIN person p ON s.person_id = p.person_id
JOIN student_group sg ON s.group_id = sg.group_id
LEFT JOIN enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, p.first_name, p.last_name, sg.name, s.group_id
ORDER BY
    group_name ASC,
    full_name ASC,
    avg_student_grade ASC,
    s.student_id ASC;
