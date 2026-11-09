-- Завдання:
--      Вивести список усіх активних курсів разом з іменами їхніх викладачів та їхніми ролями
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - повне ім'я викладача (professor_name)
--          - роль викладача на курсі (role)
--      Включити тільки курси зі статусом 'active'
--      Результат відсортувати за:
--          - назвою курсу, потім за роллю викладача

-- Рішення: 
SELECT
    course.course_name,
    person.first_name || ' ' || person.last_name AS professor_name,
    course_teacher.professor_role AS role
FROM course
JOIN course_teacher ON course_teacher.course_id = course.course_id
JOIN professor ON professor.professor_id = course_teacher.professor_id
JOIN person ON person.person_id = professor.person_id
WHERE course.course_status = 'active'
ORDER BY course.course_name, course_teacher.professor_role;
