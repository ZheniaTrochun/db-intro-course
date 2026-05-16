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
WITH RankedStudents AS (
    SELECT 
        c.name AS course_name,
        s.student_id,
        pe.first_name || ' ' || pe.last_name AS student_full_name,
        e.grade,
        RANK() OVER (
            PARTITION BY c.course_id 
            ORDER BY e.grade DESC, (pe.first_name || ' ' || pe.last_name) ASC, s.student_id ASC
        ) AS rank
    FROM enrolment e
    JOIN course c ON e.course_id = c.course_id
    JOIN student s ON e.student_id = s.student_id
    JOIN person pe ON s.person_id = pe.person_id
    WHERE e.grade IS NOT NULL
)
SELECT 
    course_name,
    student_id,
    student_full_name,
    grade,
    rank
FROM RankedStudents
WHERE rank <= 5
ORDER BY 
    course_name ASC, 
    rank ASC, 
    student_full_name ASC, 
    student_id ASC;