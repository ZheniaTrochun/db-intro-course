-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT
    pers.first_name || ' ' || pers.last_name AS professor_name,
    prof.job
FROM professor prof
INNER JOIN person pers ON prof.person_id = pers.person_id
LEFT JOIN student_group s_group ON prof.professor_id = s_group.curator_id
WHERE prof.status = 'викладає' 
  AND s_group.curator_id IS NULL
ORDER BY professor_name;
