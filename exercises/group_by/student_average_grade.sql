-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента

-- Рішення:
SELECT
 s.student_id as student_id,
 p.first_name || ' ' || p.last_name as full_name,
 ROUND(avg_grades.s_avg, 2) as avg_student_grade,
 sg.name as group_name,
 ROUND(AVG(avg_grades.s_avg) OVER (PARTITION by s.group_id), 2) as avg_group_grade
FROM student s
JOIN person p on s.person_id = p.person_id
JOIN student_group sg on s.group_id = sg.group_id
JOIN (
 SELECT student_id, AVG(grade) as s_avg
 FROM enrolment
 GROUP by student_id
) avg_grades on s.student_id = avg_grades.student_id
ORDER by group_name ASC, full_name ASC;