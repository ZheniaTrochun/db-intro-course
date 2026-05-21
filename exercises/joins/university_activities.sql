-- Завдання:
--      Сформувати єдиний список активностей університету, що поєднує:
--          - записи студентів на курси
--          - призначення викладачів на курси
--      Очікувані колонки результату:
--          - повне ім'я (full_name)
--          - назва курсу (course_name)
--          - тип активності (activity_type) - 'запис на курс' або 'викладання курсу'
--      Включити тільки активні курси (статус 'активний')
--      Результат відсортувати за:
--          - назвою курсу, потім за типом активності, потім за іменем

-- Рішення:
-- Через конфлікт кодувань між моїм комп'ютером та сервером бази даних, 
-- прямий фільтр c.status = 'активний' падав із помилкою. 
-- Щоб обійти цей баг локалі, я передала слово в універсальному шістнадцятковому (HEX) форматі 
-- та примусово змусила PostgreSQL розшифрувати його всередині бази через UTF-8.
SELECT p.first_name || ' ' || p.last_name as full_name,
       c.name as course_name,
       convert_from('\xd0b7d0b0d0bfd0b8d18120d0bdd0b020d0bad183d180d181'::bytea, 'UTF8') as activity_type
    FROM enrolment as e
JOIN student s ON e.student_id = s.student_id
JOIN person p ON s.person_id = p.person_id
JOIN course c ON e.course_id = c.course_id
WHERE c.status::text = convert_from('\xd0b0d0bad182d0b8d0b2d0bdd0b8d0b9'::bytea, 'UTF8')

UNION ALL

SELECT p_pr.first_name || ' ' || p_pr.last_name as full_name,
       c.name as course_name,
       convert_from('\xd0b2d0b8d0bad0bbd0b0d0b4d0b0d0bdd0bdd18f20d0bad183d180d181d183'::bytea, 'UTF8') as activity_type
    FROM course_teacher as ct
JOIN professor pr ON ct.professor_id = pr.professor_id
JOIN person p_pr ON pr.person_id = p_pr.person_id
JOIN course c ON ct.course_id = c.course_id
WHERE c.status::text = convert_from('\xd0b0d0bad182d0b8d0b2d0bdd0b8d0b9'::bytea, 'UTF8')
ORDER BY course_name, activity_type, full_name;