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
WITH student_rank AS (
    SELECT e.course_id,
           e.student_id,
           pe.first_name || ' ' || pe.last_name AS student_full_name,
           e.grade,
           ROW_NUMBER() OVER (PARTITION BY e.course_id ORDER BY e.grade DESC, pe.first_name || ' ' || pe.last_name ASC) as rank
    FROM enrolment e
    JOIN student s USING(student_id)
    JOIN person pe USING(person_id)
    WHERE e.grade IS NOT NULL
)
SELECT c.name AS course_name,
       sr.student_id,
       sr.student_full_name,
       sr.grade,
       sr.rank
FROM student_rank sr
JOIN course c USING(course_id)
WHERE sr.rank <= 5
ORDER BY course_name, sr.rank ASC, student_full_name;
