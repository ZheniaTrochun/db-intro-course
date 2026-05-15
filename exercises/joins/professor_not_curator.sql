-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT p.first_name ||' '|| p.last_name as professor_name, p2.job FROM person p 
JOIN professor p2 ON p.person_id = p2.person_id
WHERE p2.professor_id NOT IN (select p3.professor_id FROM professor p3
JOIN student_group g ON p3.professor_id = g.curator_id) AND p2.status = 'викладає'
ORDER BY professor_name
