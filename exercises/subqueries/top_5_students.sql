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

SELECT course_name, student_name, grade
FROM (
SELECT c.name AS course_name, p.first_name || ' ' || p.last_name AS student_name, e.grade,
DENSE_RANK() OVER(PARTITION BY c.course_id ORDER BY e.grade DESC) as rank
FROM enrolment e
JOIN course c ON e.course_id = c.course_id
JOIN student s ON e.student_id = s.student_id
JOIN person p ON s.person_id = p.person_id
WHERE e.grade IS NOT NULL
) ranked_students
WHERE rank <= 5
ORDER BY course_name, rank;