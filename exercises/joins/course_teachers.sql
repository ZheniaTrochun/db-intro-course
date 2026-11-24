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
WITH active_courses AS (
    SELECT course_id, course_name
    FROM course
    WHERE course_status = 'active'
)
SELECT
    ac.course_name AS course_name,
    p.first_name || ' ' || p.last_name AS professor_name,
    ct.professor_role AS role
FROM active_courses AS ac
JOIN course_teacher AS ct
    ON ct.course_id = ac.course_id
JOIN professor AS prof
    ON prof.professor_id = ct.professor_id
JOIN person AS p
    ON p.person_id = prof.person_id
ORDER BY
    ac.course_name ASC,
    ct.professor_role ASC;
