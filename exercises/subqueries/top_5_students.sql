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
SELECT 
    course_name,
    student_id,
    student_full_name,
    grade,
    rank
FROM (
    SELECT
        c.course_name,
        s.student_id,
        p.first_name || ' ' || p.last_name AS student_full_name,
        e.grade,
        RANK () OVER (PARTITION BY c.course_id ORDER BY e.grade DESC, p.first_name || ' ' || p.last_name, s.student_id)  AS rank
    FROM course c
        JOIN enrolment e USING (course_id)
        JOIN student s USING (student_id)
        JOIN person p USINg (person_id)
    WHERE e.grade IS NOT NULL
    
)
WHERE rank <= 5
ORDER BY course_name, rank ASC, student_full_name, student_id