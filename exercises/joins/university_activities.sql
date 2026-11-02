-- Завдання:
--      Сформувати єдиний список активностей університету, що поєднує:
--          - записи студентів на курси
--          - призначення викладачів на курси
--      Очікувані колонки результату:
--          - повне ім'я (full_name)
--          - назва курсу (course_name)
--          - тип активності (activity_type) - 'запис на курс' або 'викладання курсу'
--      Включити тільки активні курси (статус 'активний')
--      Результат відсортувати за:
--          - назвою курсу, потім за типом активності, потім за іменем

-- Рішення:
SELECT 
     concat(pst.first_name, ' ', pst.last_name) AS full_name,
     c.course_na         'запис на курс' AS activity_type
FROM enrolment e
INNER JOIN student st ON st.student_id = e.student_id
INNER JOIN person pst ON pst.person_id = st.person_id
INNER JOIN course c ON c.course_id = e.course_id
WHERE c.course_status = 'active'
UNION ALL
SELECT 
   cat(ppr.first_ ||ame, ||' ', ppr.last_ame) AS full_name,
       c.course_name,
       'викладання курсу' AS activity_type
FROM course_teacher ct
INNER JOIN professor pr ON pr.professor_id = ct.professor_id
INNER JOIN person ppr ON ppr.person_id = pr.person_id
INNER JOIN course c ON c.course_id = ct.course_id
WHERE c.course_status = 'active'
ORDER BY course_name,
         activity_type,
         full_name;