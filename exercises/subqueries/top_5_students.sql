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

SELECT c.name AS course_name, top_students.student_id, top_students.student_full_name, top_students.grade, top_students.rank
FROM course c
CROSS JOIN LATERAL (
SELECT e.student_id, p.first_name || ' ' || p.last_name AS student_full_name, e.grade,
ROW_NUMBER() OVER (ORDER BY e.grade DESC NULLS LAST, p.first_name || ' ' || p.last_name ASC, e.student_id ASC) AS rank
FROM enrolment e
JOIN student s ON e.student_id = s.student_id
JOIN person p ON s.person_id = p.person_id
WHERE e.course_id = c.course_id
ORDER BY e.grade DESC NULLS LAST, student_full_name ASC, e.student_id ASC
LIMIT 5
) top_students
ORDER BY course_name ASC, top_students.rank ASC, top_students.student_full_name ASC, top_students.student_id ASC;