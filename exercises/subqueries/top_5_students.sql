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

SELECT course_name, student_id, student_full_name, grade, rank
FROM (
    SELECT c.name AS course_name, s.student_id, 
    per.first_name || ' ' || per.last_name AS student_full_name,
    e.grade, 
    ROW_NUMBER() OVER (
            PARTITION BY c.course_id 
            ORDER BY e.grade DESC, per.first_name || ' ' || per.last_name ASC
        ) AS rank
    FROM course c 
    INNER JOIN enrolment e USING(course_id)
    INNER JOIN student s USING(student_id)
    INNER JOIN person per USING(person_id)
    WHERE e.grade IS NOT NULL
) AS sub
WHERE rank <= 5
ORDER BY course_name, rank ASC, student_full_name;