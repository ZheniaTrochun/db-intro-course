-- Завдання:
--      Знайти топ-5 студентів у кожному курсі за отриманими балами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (student_full_name)
--          - бал (grade)
--          - ранг (rank) - за балом, іменем студента та ідентифікатором студента
--      Результат відсортувати за:
--          - назвою курсу, потім за рангом (зростання), потім за іменем студента, потім за ідентифікатором студента

-- Рішення:
SELECT course_name, student_id, student_full_name, grade, rank
FROM (
    SELECT 
        c.name AS course_name,
        s.student_id,
        p.first_name || ' ' || p.last_name AS student_full_name,
        e.grade,
        DENSE_RANK() OVER (PARTITION BY c.course_id ORDER BY e.grade DESC, p.last_name, s.student_id) AS rank
    FROM enrolment e
    JOIN student s USING(student_id)
    JOIN person p USING(person_id)
    JOIN course c USING(course_id)
    WHERE e.grade IS NOT NULL
) ranked
WHERE rank <= 5
ORDER BY course_name, rank, student_full_name;і