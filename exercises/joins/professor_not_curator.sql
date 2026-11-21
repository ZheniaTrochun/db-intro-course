-- Завдання:
--      Знайти викладачів зі статусом 'active', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job_title)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
WITH active_professors AS (
    SELECT p.professor_id, p.job_title, per.first_name, per.last_name
    FROM professor AS p
    JOIN person AS per
        ON per.person_id = p.person_id
    WHERE p.professor_status = 'active'
)
SELECT
    ap.first_name || ' ' || ap.last_name AS professor_name,
    ap.job_title AS job_title
FROM active_professors AS ap
LEFT JOIN student_group AS sg
    ON sg.curator_id = ap.professor_id
WHERE sg.group_id IS NULL
ORDER BY professor_name ASC;
