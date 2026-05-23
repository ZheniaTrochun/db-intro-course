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
        s.student_id,
        pers.first_name || ' ' || pers.last_name AS full_name,
        COUNT(enr.course_id) AS course_number
    FROM student s
    INNER JOIN person pers ON s.person_id = pers.person_id
    INNER JOIN enrolment enr ON s.student_id = enr.student_id
    GROUP BY s.student_id, pers.first_name, pers.last_name
),
overall_avg AS (
    SELECT AVG(course_number) AS avg_number
    FROM student_courses
)
SELECT
    sc.student_id,
    sc.full_name,
    sc.course_number,
    ROUND((SELECT avg_number FROM overall_avg), 2) AS avg_number
FROM student_courses sc
WHERE sc.course_number > (SELECT avg_number FROM overall_avg)
ORDER BY sc.course_number DESC, sc.full_name, sc.student_id;
