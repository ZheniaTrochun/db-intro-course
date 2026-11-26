-- Виконуйте блоки ОКРЕМО після schema.sql та data.sql.
-- Помилка є очікуваним результатом; після неї обов'язково виконайте ROLLBACK.

-- PK: очікується unique_violation (23505).
BEGIN;
INSERT INTO author VALUES (1, 'Тест', 'Дублікат');
ROLLBACK;

-- Складений PK: очікується unique_violation (23505).
BEGIN;
INSERT INTO book_author VALUES (1, 1);
ROLLBACK;

-- Кожен із чотирьох FK: очікується foreign_key_violation (23503).
BEGIN;
INSERT INTO loan VALUES (901, 999, 5, '2026-10-25', '2026-11-08', NULL);
ROLLBACK;
BEGIN;
INSERT INTO loan VALUES (902, 5, 999, '2026-10-25', '2026-11-08', NULL);
ROLLBACK;
BEGIN;
INSERT INTO book_author VALUES (999, 1);
ROLLBACK;
BEGIN;
INSERT INTO book_author VALUES (5, 999);
ROLLBACK;

-- NOT NULL: очікується not_null_violation (23502).
BEGIN;
INSERT INTO member VALUES (901, NULL, 'Тест', NULL, NULL);
ROLLBACK;

-- CHECK: очікується check_violation (23514) у кожному блоці.
BEGIN;
INSERT INTO author VALUES (901, '   ', 'Тест');
ROLLBACK;
BEGIN;
INSERT INTO book VALUES (901, 'Тест', NULL, 0);
ROLLBACK;
BEGIN;
INSERT INTO book VALUES (901, 'Тест', '123', 2020);
ROLLBACK;
BEGIN;
INSERT INTO member VALUES (901, 'Тест', 'Тест', 'invalid', NULL);
ROLLBACK;
BEGIN;
INSERT INTO member VALUES (901, 'Тест', 'Тест', NULL, 'abc');
ROLLBACK;
BEGIN;
INSERT INTO loan VALUES (903, 5, 5, '2026-10-25', '2026-10-24', NULL);
ROLLBACK;
BEGIN;
INSERT INTO loan VALUES (904, 5, 5, '2026-10-25', '2026-11-08', '2026-10-24');
ROLLBACK;

-- Друга незавершена позика: очікується unique_violation (23505).
BEGIN;
INSERT INTO loan VALUES (905, 5, 1, '2026-10-25', '2026-11-08', NULL);
ROLLBACK;

-- Заборона видалення пов'язаних записів: у PostgreSQL 18.6 очікується 23001 (RESTRICT).
BEGIN;
DELETE FROM member WHERE member_id = 1;
ROLLBACK;
BEGIN;
DELETE FROM book WHERE book_id = 1;
ROLLBACK;
BEGIN;
DELETE FROM author WHERE author_id = 1;
ROLLBACK;

-- Позитивні випадки: без помилок, зміни відкочуються.
-- Дозволені NULL, спільні контакти та ISBN; минула прострочена позика.
BEGIN;
INSERT INTO member VALUES (901, 'Тест', 'Тест', 'olena@example.com', NULL);
INSERT INTO book VALUES (901, 'Тест 1', '0306406152', NULL),
                        (902, 'Тест 2', '0306406152', 2020);
INSERT INTO book_author VALUES (901, 1), (902, 1);
INSERT INTO loan VALUES (906, 901, 5, '2026-01-01', '2026-01-02', '2026-01-03');
ROLLBACK;
