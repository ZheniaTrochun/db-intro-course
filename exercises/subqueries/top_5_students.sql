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
SELECT 
    course_name,
    student_id,
    student_full_name,
    grade,
    rank
FROM (
    SELECT 
        c.name AS course_name,
        s.student_id,
        p.first_name || ' ' || p.last_name AS student_full_name,
        e.grade,
        RANK() OVER (PARTITION BY c.course_id ORDER BY e.grade DESC) as rank
    FROM course c
    JOIN enrolment e ON c.course_id = e.course_id
    JOIN student s ON e.student_id = s.student_id
    JOIN person p ON s.person_id = p.person_id
    WHERE e.grade IS NOT NULL
) AS ranked_data
WHERE rank <= 5
ORDER BY 
    course_name ASC,
    rank ASC,
    student_full_name ASC;