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
WITH course_count_of_student AS (
    SELECT
        student_id, 
        COUNT(course_id) AS course_number
    FROM enrolment e
    GROUP BY e.student_id
),
global_avg_course_count AS (
    SELECT 
      AVG(course_number) AS avg_number
    FROM course_count_of_student
)
SELECT 
    ccof.student_id AS student_id, 
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    ccof.course_number AS course_number, 
    ROUND(gacc.avg_number, 2)::float AS avg_number
FROM course_count_of_student ccof
    CROSS JOIN global_avg_course_count gacc
    JOIN student s ON ccof.student_id = s.student_id
    JOIN person p ON s.person_id = p.person_id
WHERE ccof.course_number > gacc.avg_number
ORDER BY 
    ccof.course_number DESC, 
    CONCAT(p.first_name, ' ', p.last_name) ASC, 
    ccof.student_id ASC;
