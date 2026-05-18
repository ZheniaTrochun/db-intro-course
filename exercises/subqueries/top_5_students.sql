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
WITH ranked AS (
    SELECT
        c.name AS course_name,
        s.student_id,
        CONCAT(p.first_name, ' ', p.last_name) AS student_full_name,
        e.grade,
        RANK() OVER (
            PARTITION BY c.course_id
            ORDER BY e.grade DESC,
                     CONCAT(p.first_name, ' ', p.last_name),
                     s.student_id
        ) AS rank
    FROM enrolment e
    JOIN student s ON s.student_id = e.student_id
    JOIN person p ON p.person_id  = s.person_id
    JOIN course c ON c.course_id  = e.course_id
    WHERE e.grade IS NOT NULL
)
SELECT
    course_name,
    student_id,
    student_full_name,
    grade,
    rank
FROM ranked
WHERE rank <= 5
ORDER BY course_name, rank, student_full_name, student_id;

