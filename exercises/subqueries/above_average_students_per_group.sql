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

WITH StudentGrades AS (
SELECT s.student_id, s.person_id, s.group_id,
AVG(e.grade) AS avg_grade
FROM student s
JOIN enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.person_id, s.group_id),
GroupAverages AS (
SELECT group_id,
AVG(grade) AS group_avg
FROM enrolment e
JOIN student s ON e.student_id = s.student_id
GROUP BY group_id)
SELECT p.first_name || ' ' || p.last_name AS student_name,
ROUND(sg.avg_grade, 2) AS student_avg,
ROUND(ga.group_avg, 2) AS group_avg
FROM StudentGrades sg
JOIN GroupAverages ga ON sg.group_id = ga.group_id
JOIN person p ON sg.person_id = p.person_id
WHERE sg.avg_grade > ga.group_avg
ORDER BY student_avg DESC;