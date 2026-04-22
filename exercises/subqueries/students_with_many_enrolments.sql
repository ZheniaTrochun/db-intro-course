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

WITH StudWithManyEnr AS(
    SELECT s.student_id, per.first_name || ' ' || per.last_name AS full_name,
           COUNT(e.course_id) AS course_number
    FROM student s
    INNER JOIN person per USING(person_id)
    INNER JOIN enrolment e USING(student_id)
    GROUP BY s.student_id, full_name
)
SELECT student_id, full_name, course_number,
    ROUND((SELECT AVG(course_number) FROM StudWithManyEnr), 2) AS avg_number
FROM StudWithManyEnr
WHERE course_number > (SELECT AVG(course_number) FROM StudWithManyEnr)
ORDER BY course_number DESC, full_name;