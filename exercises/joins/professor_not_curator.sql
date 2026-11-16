-- Завдання:
--      Знайти викладачів зі статусом 'active', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job_title)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
SELECT
    p.first_name || ' ' || p.last_name AS professor_name,
    prof.job_title
FROM professor prof
JOIN person p ON prof.person_id = p.person_id
WHERE prof.professor_status = 'active'
  AND NOT EXISTS (
      SELECT 1
      FROM student_group sg
      WHERE sg.curator_id = prof.professor_id
  )
ORDER BY
    professor_name;