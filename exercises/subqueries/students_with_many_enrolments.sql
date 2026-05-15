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
SELECT 
    first_name || ' ' || last_name AS student_name,
    (SELECT COUNT(*) FROM campus.enrolments e WHERE e.student_id = s.id) AS enrolment_count
FROM campus.students s
WHERE (SELECT COUNT(*) FROM campus.enrolments e WHERE e.student_id = s.id) > (
    SELECT AVG(counts.cnt) FROM (
        SELECT COUNT(*) as cnt FROM campus.enrolments GROUP BY student_id
    ) counts
)
ORDER BY enrolment_count DESC;