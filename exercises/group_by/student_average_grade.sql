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
SELECT s.student_id AS student_id,
       per.first_name || ' ' || per.last_name AS full_name,
       ROUND(AVG(e.grade), 2) AS avg_student_grade,
       gr.name AS group_name, ROUND((AVG(AVG(e.grade)) OVER (PARTITION BY s.group_id)), 2) AS avg_group_grade
FROM enrolment e
JOIN student s
    using(student_id)
JOIN person per
    using(person_id)
JOIN student_group gr
    ON s.group_id = gr.group_id
GROUP BY s.student_id, per.first_name, per.last_name, gr.name, s.group_id;
ORDER BY group_name ASC, full_name ASC;