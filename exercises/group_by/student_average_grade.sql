-- Завдання:
--      Для кожного студента знайти його середній бал у порівнянні з середнім балом по групі
--      Очікувані колонки результату:
--          - ідентифікатор студента (student_id)
--          - повне ім'я студента (full_name)
--          - середній бал студента (avg_student_grade) - округлити результат до 2 знаків після коми
--          - назва групи (group_name)
--          - середній бал по групі (avg_group_grade) - округлити результат до 2 знаків після коми
--      Результат відсортувати за:
--          - за назвою групи, потім за іменем студента, потім за ідентифікатором студента

-- Рішення:
WITH student_avg AS (
    SELECT 
          sga.student_id,
          sga.group_id,
          AVG(e.grade) AS avg_student_grade
    FROM enrolment e
    INNER JOIN student_group_assignment sga USING (student_id)
    WHERE e.grade IS NOT NULL
    GROUP BY sga.student_id, sga.group_id
),
group_avg AS (
    SELECT
          group_id,
          AVG(avg_student_grade) AS avg_g
    FROM student_avg
    GROUP BY group_id
)
SELECT 
      s.student_id,
      p.first_name || ' ' || p.last_name AS full_name,
      ROUND(AVG(e.grade), 2)::float AS avg_student_grade,
      sg.group_name,
      ROUND(COALESCE(ga.avg_g, 0), 2)::float AS avg_group_grade
FROM student s
INNER JOIN person p USING (person_id)
INNER JOIN student_group_assignment sga USING (student_id)
INNER JOIN student_group sg USING (group_id)
LEFT JOIN enrolment e USING (student_id)
LEFT JOIN group_avg ga USING (group_id)
GROUP BY s.student_id, full_name, sg.group_name, ga.avg_g
ORDER BY group_name, full_name, student_id;