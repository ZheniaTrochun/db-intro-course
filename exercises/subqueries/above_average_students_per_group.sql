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
WITH students_avg_score AS (
    SELECT student_id, avg(grade) AS raw_avg
    FROM enrolment e
    GROUP BY e.student_id
),
groups_avg_score AS (
    SELECT s.group_id, avg(e.grade) AS raw_group_avg
    FROM student s
        JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.group_id
)
SELECT s.student_id AS "student_id", p.first_name || ' ' || p.last_name AS "full_name", sg.name AS "group_name",
    ROUND(sa.raw_avg, 2) AS "avg_student_grade", ROUND(ga.raw_group_avg, 2) AS "avg_group_grade"
FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN student_group sg ON s.group_id = sg.group_id
    JOIN students_avg_score sa ON s.student_id = sa.student_id
    JOIN groups_avg_score ga ON s.group_id = ga.group_id
WHERE ROUND(sa.raw_avg, 2) > ROUND(ga.raw_group_avg, 2)
ORDER BY sg.name, sa.raw_avg DESC, p.first_name || ' ' || p.last_name;
