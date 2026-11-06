-- Лабораторна 5: міграція існуючої БД до 3НФ (без видалення таблиць)
-- Усуваємо транзитивну залежність student_id -> group_id -> faculty_id

BEGIN;

-- 1. Нові таблиці
CREATE TABLE faculty (
    faculty_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE student_group (
    group_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_id INTEGER     NOT NULL,
    name       VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT fk_student_group_faculty
        FOREIGN KEY (faculty_id) REFERENCES faculty (faculty_id)
);

-- 2. Перенесення даних зі збереженням наявних id
-- (реальних назв у старій схемі немає, тому використано назви-заглушки)
INSERT INTO faculty (faculty_id, name)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT faculty_id, 'Факультет ' || faculty_id
FROM student
WHERE faculty_id IS NOT NULL;

INSERT INTO student_group (group_id, faculty_id, name)
OVERRIDING SYSTEM VALUE
SELECT DISTINCT group_id, faculty_id, 'Група ' || group_id
FROM student
WHERE group_id IS NOT NULL;

-- Справжня назва факультета (усі студенти з ФІОТ, faculty_id = 1)
UPDATE faculty SET name = 'ФІОТ' WHERE faculty_id = 1;

-- 3. Вирівнювання лічильників identity
SELECT setval(pg_get_serial_sequence('faculty', 'faculty_id'),
              COALESCE(MAX(faculty_id), 0) + 1, false) FROM faculty;
SELECT setval(pg_get_serial_sequence('student_group', 'group_id'),
              COALESCE(MAX(group_id), 0) + 1, false) FROM student_group;

-- 4. Зв'язок student -> student_group
ALTER TABLE student
    ADD CONSTRAINT fk_student_group
    FOREIGN KEY (group_id) REFERENCES student_group (group_id);

-- 5. Перевірка перед видаленням стовпця (якщо дані розійшлися, транзакція відкотиться)
DO $$
BEGIN
    IF EXISTS (SELECT 1
               FROM student s
               JOIN student_group g ON g.group_id = s.group_id
               WHERE g.faculty_id IS DISTINCT FROM s.faculty_id) THEN
        RAISE EXCEPTION 'faculty_id у student не збігається з student_group';
    END IF;
END $$;

-- 6. Видаляємо транзитивно залежний стовпець
ALTER TABLE student DROP COLUMN faculty_id;

COMMIT;