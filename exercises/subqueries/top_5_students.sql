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
        s.student_id,
        p.first_name || ' ' || p.last_name AS student_full_name,
        e.grade,
        ROW_NUMBER() OVER (
            PARTITION BY c.course_id
            ORDER BY
                e.grade DESC,
                (p.first_name || ' ' || p.last_name) ASC
        ) AS rank
    FROM enrolment e
    JOIN student s 
        ON s.student_id = e.student_id
    JOIN person p 
        ON p.person_id = s.person_id
    JOIN course c 
        ON c.course_id = e.course_id
    WHERE e.grade IS NOT NULL
)
SELECT 
    course_name,
    student_id,
    student_full_name,
    grade,
    rank
FROM ranked_students
WHERE rank <= 5
ORDER BY 
    course_name ASC,
    rank ASC,
    student_full_name ASC;