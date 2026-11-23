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
        s.student_id AS student_id,
        COUNT(DISTINCT e.course_id) AS course_number
    FROM student AS s
    LEFT JOIN enrolment AS e
        ON e.student_id = s.student_id
    GROUP BY s.student_id
),
avg_courses AS (
    SELECT AVG(course_number) AS avg_number
    FROM student_courses
)
SELECT
    sc.student_id AS student_id,
    p.first_name || ' ' || p.last_name AS full_name,
    sc.course_number AS course_number,
    ROUND(ac.avg_number, 2) AS avg_number
FROM student_courses AS sc
CROSS JOIN avg_courses AS ac
JOIN student AS s
    ON s.student_id = sc.student_id
JOIN person AS p
    ON p.person_id = s.person_id
WHERE sc.course_number > ac.avg_number
ORDER BY
    sc.course_number DESC,
    full_name ASC,
    sc.student_id ASC;
