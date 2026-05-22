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
    s.student_id                                        AS student_id,
    per.first_name || ' ' || per.last_name              AS full_name,
    ROUND(AVG(e.grade), 2)                              AS avg_student_grade,
    sg.name                                             AS group_name,
    ROUND(AVG(AVG(e.grade)) OVER (PARTITION BY s.group_id), 2) AS avg_group_grade
FROM enrolment e
JOIN student s       ON s.student_id = e.student_id
JOIN person per      ON per.person_id = s.person_id
JOIN student_group sg ON sg.group_id = s.group_id
WHERE e.grade IS NOT NULL
GROUP BY s.student_id, per.first_name, per.last_name, sg.name, s.group_id
ORDER BY sg.name, full_name;