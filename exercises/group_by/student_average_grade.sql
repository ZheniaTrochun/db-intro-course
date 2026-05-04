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
WITH student_avg as (
    SELECT s.student_id,
           p.first_name || ' ' || p.last_name as full_name,
           s.group_id,
           sg.name as group_name,
           AVG(e.grade) as student_raw_avg
        FROM student s
    JOIN person p ON s.person_id = p.person_id
    JOIN student_group sg ON s.group_id = sg.group_id
    LEFT JOIN enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id, p.first_name, p.last_name, s.group_id, sg.name
)
SELECT student_id, full_name, ROUND(student_raw_avg, 2) as avg_student_grade,
       group_name, ROUND(AVG(student_raw_avg) OVER (PARTITION BY group_id), 2) as avg_group_grade
  FROM student_avg
ORDER BY group_name, full_name;