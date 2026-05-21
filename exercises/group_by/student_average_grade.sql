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
WITH student_avg AS (
    SELECT 
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        s.group_id,
        sg.name AS group_name,
        AVG(e.grade) AS avg_student_grade
    FROM enrolment e
    JOIN student s USING(student_id)
    JOIN person p USING(person_id)
    JOIN student_group sg ON s.group_id = sg.group_id
    GROUP BY 
        s.student_id, 
        p.first_name, 
        p.last_name, 
        s.group_id, 
        sg.name
)
SELECT 
    student_id,
    full_name,
    ROUND(avg_student_grade, 2) AS avg_student_grade,
    group_name,
    ROUND(AVG(avg_student_grade) OVER (PARTITION BY group_id), 2) AS avg_group_grade
FROM student_avg
ORDER BY 
    group_name,
    full_name,
    student_id;