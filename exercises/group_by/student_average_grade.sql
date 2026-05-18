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

WITH StudentGrades AS (

    SELECT
        s.student_id,
        CONCAT(p.first_name, ' ', p.last_name) AS full_name,
        sg.name AS group_name,
        s.group_id,
        e.grade
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    LEFT JOIN student_group sg ON s.group_id = sg.group_id
    LEFT JOIN enrolment e ON s.student_id = e.student_id
)
SELECT DISTINCT
    student_id,
    full_name,
    ROUND(AVG(grade) OVER (PARTITION BY student_id), 2) AS avg_student_grade,
    group_name,
    ROUND(AVG(grade) OVER (PARTITION BY group_id), 2) AS avg_group_grade
FROM StudentGrades
ORDER BY
    group_name,
    full_name;
