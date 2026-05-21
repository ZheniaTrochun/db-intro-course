-- Завдання:
--      Знайти викладачів зі статусом 'викладає', які не є куратором жодної студентської групи
--      Очікувані колонки результату:
--          - повне ім'я викладача (professor_name)
--          - посада (job)
--      Результат відсортувати за:
--          - повним іменем викладача

-- Рішення:
-- Через конфлікт кодувань між моїм комп'ютером та сервером бази даних, 
-- прямий фільтр c.status = 'активний' падав із помилкою. 
-- Щоб обійти цей баг локалі, я передала слово в універсальному шістнадцятковому (HEX) форматі 
-- та примусово змусила PostgreSQL розшифрувати його всередині бази через UTF-8.
SELECT p.first_name || ' ' || p.last_name as professor_name, pr.job as job
  FROM professor as pr 
  JOIN person p ON pr.person_id = p.person_id
  LEFT JOIN student_group sg ON pr.professor_id = sg.curator_id
WHERE pr.status::text = convert_from('\xd0b2d0b8d0bad0bbd0b0d0b4d0b0d194'::bytea, 'UTF8') 
  AND sg.curator_id IS NULL
ORDER BY professor_name;
