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
WITH student_counts AS (
    SELECT 
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        COUNT(e.course_id) AS course_number
    FROM student s
    JOIN person p ON p.person_id = s.person_id
    LEFT JOIN enrolment e ON e.student_id = s.student_id
    GROUP BY s.student_id, p.first_name, p.last_name
),
counts_with_avg AS (
    SELECT 
        student_id, 
        full_name, 
        course_number,
        ROUND(AVG(course_number) OVER (), 2)::float AS avg_number
    FROM student_counts
)
SELECT 
    student_id, 
    full_name, 
    course_number, 
    avg_number
FROM counts_with_avg
WHERE course_number > avg_number
ORDER BY 
    course_number DESC,
    full_name ASC,
    student_id DESC;