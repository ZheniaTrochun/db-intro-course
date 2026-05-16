-- Завдання:
--      Знайти всіх студентів, які записані на більше курсів ніж в середньому
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - кількість курсів студента (course_number)
--          - середня кількість курсів серед усіх студентів (avg_number) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - кількістю курсів студента (спадання), потім за іменем студента, потім за ідентифікатор студента

-- Рішення:
WITH student_courses AS (
    SELECT 
        student_id, 
        COUNT(course_id) AS course_number
    FROM enrolment
    GROUP BY student_id
),
global_avg AS (
    SELECT 
        ROUND(AVG(course_number)::numeric, 2) AS avg_number
    FROM student_courses
)
SELECT 
    sc.student_id,
    pe.first_name || ' ' || pe.last_name AS full_name,
    sc.course_number,
    ga.avg_number
FROM student_courses sc
JOIN student s ON sc.student_id = s.student_id
JOIN person pe ON s.person_id = pe.person_id
CROSS JOIN global_avg ga
WHERE sc.course_number > ga.avg_number
ORDER BY 
    sc.course_number DESC, 
    full_name ASC, 
    sc.student_id ASC;