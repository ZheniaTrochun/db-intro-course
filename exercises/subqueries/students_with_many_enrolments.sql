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

--ІО-41 Кореняко Антон

SELECT
    s.student_id,
    p.first_name  ' '
 p.last_name AS full_name,
    COUNT(e.course_id) AS course_number,
    CAST((SELECT ROUND(AVG(counts.cnt)::numeric, 2)
          FROM (SELECT COUNT(course_id) AS cnt FROM enrolment GROUP BY student_id) AS counts
         ) AS DOUBLE PRECISION) AS avg_number
FROM student s
JOIN person p ON s.person_id = p.person_id
JOIN enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, p.first_name, p.last_name
HAVING COUNT(e.course_id) > (
    SELECT AVG(counts.cnt)
    FROM (SELECT COUNT(course_id) AS cnt FROM enrolment GROUP BY student_id) AS counts
)
ORDER BY
    course_number DESC,
    full_name ASC,
    s.student_id ASC;
