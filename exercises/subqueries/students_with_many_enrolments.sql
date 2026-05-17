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
SELECT p.first_name || ' ' || p.last_name AS student_name,
       (SELECT COUNT(*) FROM enrolment e WHERE e.student_id = s.student_id) AS enrolment_count
FROM student s
JOIN person p USING(person_id)
WHERE (SELECT COUNT(*) FROM enrolment e WHERE e.student_id = s.student_id) > (
    SELECT AVG(cnt) FROM (SELECT COUNT(*) as cnt FROM enrolment GROUP BY student_id) sub
)
ORDER BY enrolment_count DESC, student_name;