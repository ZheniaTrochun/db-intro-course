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
WITH student_grades AS (
SELECT
s.id AS student_id,
s.first_name || ' ' || s.last_name AS full_name,
s.group_id,
g.name AS group_name,
ROUND(AVG(e.grade), 2) AS avg_student_grade
FROM students s
JOIN groups g ON s.group_id = g.id
JOIN enrolments e ON s.id = e.student_id
WHERE e.grade IS NOT NULL
GROUP BY s.id, full_name, s.group_id, group_name
)

SELECT
student_id,
full_name,
avg_student_grade,
group_name,
ROUND(AVG(avg_student_grade) OVER (PARTITION BY group_id), 2) AS avg_group_grade
FROM student_grades
ORDER BY
group_name ASC,
full_name ASC;