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
WITH student_avg AS (
SELECT
s.student_id,
p.first_name || ' ' || p.last_name AS full_name,
AVG(e.grade) AS avg_student_grade
FROM student s
JOIN person p ON s.person_id = p.person_id
JOIN enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, p.first_name, p.last_name
),
group_avg AS (
SELECT
sg.group_id,
sg.group_name,
AVG(e.grade) AS avg_group_grade
FROM student_group sg
JOIN student_group_assignment sga ON sg.group_id = sga.group_id
JOIN enrolment e ON sga.student_id = e.student_id
GROUP BY sg.group_id, sg.group_name
)
SELECT
sa.student_id,
sa.full_name,
ga.group_name,
ROUND(sa.avg_student_grade, 2) AS avg_student_grade,
ROUND(ga.avg_group_grade, 2) AS avg_group_grade
FROM student_avg sa
JOIN student_group_assignment sga ON sa.student_id = sga.student_id
JOIN group_avg ga ON sga.group_id = ga.group_id
WHERE ROUND(sa.avg_student_grade, 2) > ROUND(ga.avg_group_grade, 2)
ORDER BY ga.group_name ASC, avg_student_grade DESC, sa.full_name ASC, sa.student_id ASC;