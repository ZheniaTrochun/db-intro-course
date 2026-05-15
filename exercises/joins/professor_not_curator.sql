-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT DISTINCT 
    p.first_name || ' ' || p.last_name AS professor_name
FROM campus.professors p
JOIN campus.professor_course pc ON p.id = pc.professor_id
WHERE p.id NOT IN (SELECT curator_id FROM campus.groups WHERE curator_id IS NOT NULL)
ORDER BY professor_name;