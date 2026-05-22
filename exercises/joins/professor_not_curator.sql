-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT
    per.first_name || ' ' || per.last_name AS professor_name,
    p.job                                  AS job
FROM professor p
JOIN person per ON per.person_id = p.person_id
WHERE p.status = 'викладає'
  AND p.professor_id NOT IN (
      SELECT curator_id
      FROM student_group
      WHERE curator_id IS NOT NULL
  )
ORDER BY professor_name;