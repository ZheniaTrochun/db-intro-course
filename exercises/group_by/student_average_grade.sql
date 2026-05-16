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
WITH student_personal_stats AS (
    SELECT 
        s.student_id,
        s.person_id,
        s.group_id,
        AVG(e.grade) AS raw_student_grade
    FROM student s
    LEFT JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, s.person_id, s.group_id
)
SELECT 
    sps.student_id,
    pe.first_name || ' ' || pe.last_name AS full_name,
    ROUND(sps.raw_student_grade::numeric, 2) AS avg_student_grade,
    sg.name AS group_name,
    ROUND(AVG(sps.raw_student_grade) OVER(PARTITION BY sps.group_id)::numeric, 2) AS avg_group_grade
FROM student_personal_stats sps
JOIN person pe ON sps.person_id = pe.person_id
JOIN student_group sg ON sps.group_id = sg.group_id
ORDER BY 
    group_name ASC, 
    full_name ASC;