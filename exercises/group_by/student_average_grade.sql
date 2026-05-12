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

WITH StudentStats AS (
SELECT s.student_id, s.group_id,
CONCAT(p.first_name, ' ', p.last_name) AS full_name,
AVG(e.grade) AS student_avg
FROM student s
JOIN person p ON s.person_id = p.person_id
JOIN enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.group_id, p.first_name, p.last_name
)
SELECT st.student_id, st.full_name,
ROUND(st.student_avg, 2) AS avg_student_grade, sg.name AS group_name,
ROUND(AVG(st.student_avg) OVER (PARTITION BY st.group_id), 2) AS avg_group_grade
FROM StudentStats st
JOIN student_group sg ON st.group_id = sg.group_id
ORDER BY group_name ASC, full_name ASC;