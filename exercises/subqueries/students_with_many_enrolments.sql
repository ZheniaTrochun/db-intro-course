-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента

-- Рішення:
WITH student_courses AS (
    SELECT 
        s.student_id,
        p.first_name || ' ' || p.last_name AS full_name,
        COUNT(e.course_id) AS course_number
    FROM student s
    JOIN person p 
        ON p.person_id = s.person_id
    JOIN enrolment e 
        ON e.student_id = s.student_id
    GROUP BY s.student_id, p.first_name, p.last_name
),
avg_courses AS (
    SELECT 
        ROUND(AVG(course_number)::numeric, 2) AS avg_number
    FROM student_courses
)
SELECT 
    sc.student_id,
    sc.full_name,
    sc.course_number,
    ac.avg_number
FROM student_courses sc
CROSS JOIN avg_courses ac
WHERE sc.course_number > ac.avg_number
ORDER BY 
    sc.course_number DESC,
    sc.full_name ASC;