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
-- Medgitova Sevil ІО-46

WITH student_avg AS (
    SELECT
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        s.group_id,
        ROUND(AVG(e.grade)::numeric, 2)::double precision AS avg_student_grade,
        AVG(e.grade) AS raw_student_avg
    FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id
),
group_avg AS (
    SELECT
        group_id,
        ROUND(AVG(raw_student_avg)::numeric, 2)::double precision AS avg_group_grade
    FROM student_avg
    GROUP BY group_id
)
SELECT
    sa.student_id,
    sa.full_name,
    sa.avg_student_grade,
    sg.name AS group_name,
    ga.avg_group_grade
FROM student_avg sa
JOIN student_group sg ON sa.group_id = sg.group_id
JOIN group_avg ga ON sa.group_id = ga.group_id
ORDER BY
    sg.name,
    sa.full_name,
    sa.student_id;