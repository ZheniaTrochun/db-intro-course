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
WITH ranked_students AS (
    SELECT
        crs.name AS course_name,
        s.student_id,
        pers.first_name || ' ' || pers.last_name AS student_full_name,
        enr.grade,
        RANK() OVER (
            PARTITION BY crs.course_id
            ORDER BY enr.grade DESC, pers.first_name || ' ' || pers.last_name, s.student_id
        ) AS rank
    FROM enrolment enr
    INNER JOIN student s ON enr.student_id = s.student_id
    INNER JOIN person pers ON s.person_id = pers.person_id
    INNER JOIN course crs ON enr.course_id = crs.course_id
    WHERE enr.grade IS NOT NULL
)
SELECT
    course_name,
    student_id,
    student_full_name,
    grade,
    rank
FROM ranked_students
WHERE rank <= 5
ORDER BY course_name, rank ASC, student_full_name, student_id;
