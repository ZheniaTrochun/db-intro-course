-- Завдання:
--      Знайти топ-5 студентів у кожному курсі за отриманими балами
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (student_full_name)
--          - бал (grade)
--          - ранг (rank)
--      Результат відсортувати за:
--          - назвою курсу, потім за рангом (зростання), потім за іменем студента

-- Рішення:
WITH ranked_students AS (
    SELECT
        c.name AS course_name,
        s.id AS student_id,
        s.first_name || ' ' || s.last_name AS student_full_name,
        e.grade,
        DENSE_RANK() OVER (
            PARTITION BY e.course_id
            ORDER BY e.grade DESC
        ) AS rank
    FROM enrollments e
    JOIN students s
        ON e.student_id = s.id
    JOIN courses c
        ON e.course_id = c.id
    WHERE e.grade IS NOT NULL
)
SELECT *
FROM ranked_students
WHERE rank <= 5
ORDER BY
    course_name ASC,
    rank ASC,
    student_full_name ASC;