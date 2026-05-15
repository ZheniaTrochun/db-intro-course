-- Завдання:
--      Вивести список усіх активних курсів разом з іменами їхніх викладачів та їхніми ролями
--      Очікувані колонки результату:
--          - назва курсу (course_name)
--          - повне ім'я викладача (professor_name)
--          - роль викладача на курсі (role)
--      Включити тільки курси зі статусом 'активний'
--      Результат відсортувати за:
--          - назвою курсу, потім за роллю викладача

-- Рішення:
SET client_encoding TO 'UTF8';
SELECT p.first_name || ' ' || p.last_name AS professor_name, pr.job
FROM professor pr
JOIN person p ON pr.person_id = p.person_id
LEFT JOIN student_group gr ON p.person_id = gr.curator_id
WHERE pr.status = 'викладає' AND gr.curator_id IS NULL
ORDER BY professor_name;