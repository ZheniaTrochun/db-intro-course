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
WITH group_avg AS (
    SELECT 
          sga.group_id,
          AVG(e.grade) AS avg_g
    FROM enrolment e
    INNER JOIN student_group_assignment sga USING (student_id)
    WHERE e.grade IS NOT NULL
    GROUP BY sga.group_id
)
SELECT 
      s.student_id,
      p.first_name || ' ' || p.last_name AS full_name,
      ROUND(COALESCE(AVG(e.grade), 0), 2) AS avg_student_grade,
      sg.group_name,
      ROUND(COALESCE(ga.avg_g, 0), 2) AS avg_group_grade
FROM student s
INNER JOIN person p USING (person_id)
INNER JOIN student_group_assignment sga USING (student_id)
INNER JOIN student_group sg USING (group_id)
LEFT JOIN enrolment e USING (student_id)
LEFT JOIN group_avg ga USING (group_id)
GROUP BY s.student_id, full_name, sg.group_name, ga.avg_g
ORDER BY group_name, full_name, student_id;