-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT 
    t.first_name || ' ' || t.last_name AS professor_name,
    t.role AS job
FROM teachers t
LEFT JOIN groups g ON t.id = g.curator_id
WHERE t.status = 'викладає' 
  AND g.curator_id IS NULL
ORDER BY professor_name ASC;
