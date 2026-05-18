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
WITH StudentStats AS (
    SELECT 
        s.student_id, 
        s.group_id,
        p.first_name || ' ' || p.last_name AS full_name,
        AVG(e.grade) AS student_avg
    FROM student s
    JOIN person p USING (person_id)
    JOIN enrolment e USING (student_id)
    GROUP BY 1, 2, 3
)
SELECT 
    st.student_id, 
    st.full_name,
    ROUND(st.student_avg, 2) AS avg_student_grade, 
    sg.name AS group_name,
    ROUND(AVG(st.student_avg) OVER (PARTITION BY st.group_id), 2) AS avg_group_grade
FROM StudentStats st
JOIN student_group sg USING (group_id)
ORDER BY 4 ASC, 2 ASC;