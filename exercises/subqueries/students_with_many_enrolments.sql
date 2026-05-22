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
WITH student_counts AS (
    SELECT
        student_id,
        COUNT(*) AS course_number
    FROM enrolment
    GROUP BY student_id
),
global_avg AS (
    SELECT ROUND(AVG(course_number), 2) AS avg_number
    FROM student_counts
)
SELECT
    s.student_id,
    per.first_name || ' ' || per.last_name AS full_name,
    sc.course_number,
    ga.avg_number
FROM student_counts sc
CROSS JOIN global_avg ga
JOIN student s  ON s.student_id = sc.student_id
JOIN person per ON per.person_id = s.person_id
WHERE sc.course_number > ga.avg_number
ORDER BY sc.course_number DESC, full_name, s.student_id;
