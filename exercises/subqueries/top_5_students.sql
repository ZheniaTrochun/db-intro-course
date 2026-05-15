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
SELECT student_name, study_year, total_points
FROM (
    SELECT 
        s.first_name || ' ' || s.last_name AS student_name,
        s.study_year,
        SUM(e.grade) AS total_points,
        ROW_NUMBER() OVER (PARTITION BY s.study_year ORDER BY SUM(e.grade) DESC) as rank
    FROM campus.students s
    JOIN campus.enrolments e ON s.id = e.student_id
    GROUP BY s.id, s.study_year, s.first_name, s.last_name
) AS ranked_students
WHERE rank <= 5
ORDER BY study_year ASC, total_points DESC;