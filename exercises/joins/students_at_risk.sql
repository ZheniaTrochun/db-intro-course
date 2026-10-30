-- Завдання:
--      Вивести список студентів, які мають низькі оцінки (менше 60) разом з інформацією про курс та викладача
--      Очікувані колонки результату:
--          - повне ім'я студента (student_name)
--          - назва групи (group_name)
--          - назва курсу (course_name)
--          - оцінка (grade)
--          - повне ім'я лектора курсу (lecturer_name)
--      Включити тільки записи, де оцінка вже виставлена
--      Включити тільки лекторів (роль 'lecturer' або 'full_ownership')
--      Результат відсортувати за:
--          - оцінкою (зростання), потім за назвою групи, потім за іменем студента, потім за назвою курсу

-- Рішення:
SELECT student_person.first_name || ' ' || student_person.last_name AS student_name, student_group.group_name, course.course_name, enrolment.grade, 
lecturer_person.first_name || ' ' || lecturer_person.last_name AS lecturer_name
FROM enrolment
JOIN student ON student.student_id = enrolment.student_id
JOIN person student_person ON student_person.person_id = student.person_id
JOIN student_group_assignment ON student_group_assignment.student_id = student.student_id
AND student_group_assignment.assignment_status = 'active'
JOIN student_group ON student_group.group_id = student_group_assignment.group_id
JOIN course ON course.course_id = enrolment.course_id
JOIN course_teacher ON course_teacher.course_id = course.course_id
JOIN professor ON professor.professor_id = course_teacher.professor_id
JOIN person lecturer_person ON lecturer_person.person_id = professor.person_id
WHERE enrolment.grade < 60
AND course_teacher.professor_role IN ('lecturer', 'full_ownership')
ORDER BY enrolment.grade, student_group.group_name, student_name, course.course_name;
