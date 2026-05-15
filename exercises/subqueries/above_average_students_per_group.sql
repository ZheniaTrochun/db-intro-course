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
SELECT p.first_name || ' ' || p.last_name AS student_name, gr.name AS group_name, ROUND(avg_s.personal_avg, 2) AS average_grade
FROM student st
JOIN person p USING(person_id)
JOIN student_group gr USING(group_id)
JOIN (SELECT student_id, AVG(grade) as personal_avg FROM enrolment GROUP BY student_id) avg_s USING(student_id)
WHERE avg_s.personal_avg > (
    SELECT AVG(e2.grade) FROM student st2
    JOIN enrolment e2 USING(student_id)
    WHERE st2.group_id = st.group_id
)
ORDER BY group_name, average_grade DESC, student_name;