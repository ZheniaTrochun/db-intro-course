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
WITH prepared_data AS (
    SELECT 
        c.name AS course_name,
        s.student_id,
        per.first_name || ' ' || per.last_name AS student_full_name,
        e.grade,
        c.course_id
    FROM course c
    JOIN enrolment e ON c.course_id = e.course_id
    JOIN student s ON e.student_id = s.student_id
    JOIN person per ON s.person_id = per.person_id
    WHERE e.grade IS NOT NULL
),
ranked_data AS (
    SELECT 
        course_name,
        student_id,
        student_full_name,
        grade,
        ROW_NUMBER() OVER (
            PARTITION BY course_id
            ORDER BY 
                grade DESC,
                student_full_name ASC,
                student_id ASC
        )::int AS rank
    FROM prepared_data
)
SELECT 
    course_name,
    student_id,
    student_full_name,
    grade,
    rank
FROM ranked_data
WHERE rank <= 5
ORDER BY 
    course_name ASC,
    rank ASC,
    student_full_name ASC,
    student_id ASC