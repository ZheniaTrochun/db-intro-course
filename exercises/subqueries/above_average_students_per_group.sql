-- Завдання:
--      Знайти студентів, чий середній бал перевищує середній бал їхньої групи
--      Використати два CTE: один для середнього балу студента, інший для середнього балу групи
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - назва групи (group_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - середній бал групи (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - назвою групи, потім за середнім балом студента (спадання), потім за іменем студента

-- Рішення:
WITH group_averages AS (
    SELECT st.group_id, AVG(e.grade) AS group_avg
    FROM student st
    JOIN enrolment e USING(student_id)
    GROUP BY st.group_id
),
student_averages AS (
    SELECT st.student_id, st.group_id, p.first_name || ' ' || p.last_name AS student_name, AVG(e.grade) AS personal_avg
    FROM student st
    JOIN person p USING(person_id)
    JOIN enrolment e USING(student_id)
    GROUP BY st.student_id, st.group_id, p.first_name, p.last_name
)
SELECT sa.student_name, gr.name AS group_name, ROUND(sa.personal_avg, 2) AS average_grade
FROM student_averages sa
JOIN student_group gr USING(group_id)
JOIN group_averages ga USING(group_id)
WHERE sa.personal_avg > ga.group_avg
ORDER BY group_name, average_grade DESC, student_name;