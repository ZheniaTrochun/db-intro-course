## data.sql 

```sql
--- Згенеровано автоматично AI, сподвіваюсь так можно
-- 1. Заповнюємо контакти (для викладачів та студентів)
INSERT INTO contact_data (email, phone) VALUES
('shevchenko@uni.edu.ua', '+380501112233'),   -- id 1 (Викладач)
('frank@uni.edu.ua', '+380679998877'),        -- id 2 (Викладач)
('tesla@uni.edu.ua', '+380635554433'),        -- id 3 (Викладач)
('student1@gmail.com', '+380991000001'),      -- id 4 (Студент)
('student2@gmail.com', '+380991000002'),      -- id 5
('student3@gmail.com', '+380991000003'),      -- id 6
('student4@gmail.com', '+380991000004'),      -- id 7
('student5@gmail.com', '+380991000005'),      -- id 8
('student6@gmail.com', '+380991000006'),      -- id 9
('student7@gmail.com', '+380991000007'),      -- id 10
('student8@gmail.com', '+380991000008'),      -- id 11
('student9@gmail.com', '+380991000009'),      -- id 12
('student10@gmail.com', '+380991000010'),     -- id 13
('doomslayer@hell.com', '+666666666666'),     -- id 14
('gordon@blackmesa.com', '+10000000000');     -- id 15

-- 2. Заповнюємо викладачів
-- Посилаємось на contact_data_id 1, 2, 3
-- Використовуємо твій ENUM qualification_name
INSERT INTO teacher (name, surname, contact_data_id, qualification) VALUES
('Тарас', 'Шевченко', 1, 'доктор наук'),
('Іван', 'Франко', 2, 'доктор філософії'),
('Нікола', 'Тесла', 3, 'магістр');

-- 3. Заповнюємо групи
-- CHECK (name LIKE '__-%') -> Наприклад 'CS-23'
-- Куратори посилаються на teacher_id 1, 2, 3
INSERT INTO student_group (name, start_year, curator_id) VALUES
('CS-2023', 2023, 1), -- id 1
('KN-2024', 2024, 2), -- id 2
('AM-2023', 2023, 3); -- id 3

-- 4. Заповнюємо студентів
-- Посилаємось на контакти 4-15 та групи 1-3
INSERT INTO student (name, surname, contact_data_id, group_id) VALUES
('Валерій', 'Залужний', 4, 1),
('Ліна', 'Костенко', 5, 1),
('Богдан', 'Хмельницький', 6, 1),
('Ілон', 'Маск', 7, 2),
('Марк', 'Цукерберг', 8, 2),
('Джефф', 'Безос', 9, 2),
('Алан', 'Тюрінг', 10, 3),
('Ада', 'Лавлейс', 11, 3),
('Грейс', 'Гоппер', 12, 3),
('Кат', 'Року', 14, 1),
('Гордон', 'Фрімен', 15, 2);

-- 5. Заповнюємо курси
-- CHECK (credits > 0 AND credits < 100)
-- Посилаємось на teacher_id
INSERT INTO course (name, credits, student_year, is_active, teacher_id) VALUES
('Бази даних', 5, 2, true, 1),            -- id 1
('Алгоритми і структури', 6, 1, true, 2), -- id 2
('Вища математика', 8, 1, true, 3),       -- id 3
('Філософія', 3, 2, false, 2),            -- id 4 (не активний)
('Web-розробка', 4, 3, true, 1);          -- id 5

-- 6. Заповнюємо пререквізити (залежності курсів)
-- Щоб вчити БД (id 1), треба знати Алгоритми (id 2)
-- Щоб вчити Алгоритми (id 2), треба Математику (id 3)
INSERT INTO course_prerequisite (course_id, prerequisite_course_id) VALUES
(1, 2),
(2, 3),
(5, 1);

-- 7. Заповнюємо успішність (enrolment)
-- Студенти (id 1-11) записуються на курси
INSERT INTO enrolment (course_id, student_id, grade) VALUES
-- Курс 1 (БД)
(1, 1, 95), (1, 2, 88), (1, 3, 60), (1, 4, 75), (1, 10, 100),
-- Курс 2 (Алгоритми)
(2, 1, 90), (2, 2, 92), (2, 5, 65), (2, 6, 81), (2, 11, NULL), -- NULL означає ще не склав
-- Курс 3 (Математика)
(3, 7, 99), (3, 8, 98), (3, 9, 97);
```

## groupby.sql

<img width="262" height="92" alt="image" src="https://github.com/user-attachments/assets/0bc84173-4e50-4fdd-8e36-9f87af101642" />

<img width="691" height="287" alt="image" src="https://github.com/user-attachments/assets/ffeed072-caa0-4b87-b234-29c172c9ebe7" />

<img width="553" height="116" alt="image" src="https://github.com/user-attachments/assets/dba3a4cd-3291-426b-ab57-74f571885dcf" />

## subqueries.sql

<img width="322" height="168" alt="image" src="https://github.com/user-attachments/assets/66c5ccd4-6204-4414-8bc3-7b0b3273b80f" />

<img width="658" height="92" alt="image" src="https://github.com/user-attachments/assets/de12710b-fb43-4ffd-8b55-09590b72cd40" />

<img width="460" height="272" alt="image" src="https://github.com/user-attachments/assets/b51a7b60-357b-4a32-9f41-6a53de97036d" />







