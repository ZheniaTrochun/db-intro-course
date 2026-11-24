-- Виконайте весь файл разом: наприкінці зміни відкочуються.
BEGIN;

-- D1. Реєстрація читача.
INSERT INTO member (member_id, first_name, last_name, email, phone)
VALUES (1001, 'Дмитро', 'Савчук', 'dmytro@example.com', '+380501112233');

SELECT member_id, first_name, last_name, email, phone
FROM member WHERE member_id = 1001;

-- D2. Додавання автора.
INSERT INTO author (author_id, first_name, last_name)
VALUES (1001, 'Навчальний', 'Автор');

SELECT author_id, first_name, last_name
FROM author WHERE author_id = 1001;

-- D3. Книга та її авторство додаються в одній транзакції.
INSERT INTO book (book_id, title, isbn, publication_year)
VALUES (1001, 'Навчальна книга', NULL, 2025);

SELECT book_id, title, isbn, publication_year
FROM book WHERE book_id = 1001;

INSERT INTO book_author (book_id, author_id)
VALUES (1001, 1001);

SELECT book_id, author_id
FROM book_author WHERE book_id = 1001 AND author_id = 1001;

-- D4. Перевірка доступності та видача книги 5.
SELECT b.book_id, b.title
FROM book b
WHERE b.book_id = 5 AND NOT EXISTS (
    SELECT 1 FROM loan l
    WHERE l.book_id = b.book_id AND l.return_date IS NULL
);

INSERT INTO loan (loan_id, member_id, book_id, loan_date, due_date, return_date)
VALUES (1001, 1001, 5, '2026-11-25', '2026-12-09', NULL);

SELECT loan_id, member_id, book_id, loan_date, due_date, return_date
FROM loan WHERE loan_id = 1001;

-- D5. Зміна контактів читача.
SELECT member_id, email, phone
FROM member WHERE member_id = 1001;

UPDATE member
SET email = 'dmytro.new@example.com', phone = '+380671112233'
WHERE member_id = 1001;

SELECT member_id, email, phone
FROM member WHERE member_id = 1001;

-- D6. Уточнення року видання навчальної книги.
SELECT book_id, title, publication_year
FROM book WHERE book_id = 1001;

UPDATE book
SET publication_year = 2026
WHERE book_id = 1001;

SELECT book_id, title, publication_year
FROM book WHERE book_id = 1001;

-- D7. Продовження строку відкритої позики.
SELECT loan_id, due_date, return_date
FROM loan WHERE loan_id = 1001 AND return_date IS NULL;

UPDATE loan
SET due_date = '2026-12-16'
WHERE loan_id = 1001 AND return_date IS NULL;

SELECT loan_id, due_date, return_date
FROM loan WHERE loan_id = 1001;

-- D8. Повернення книги зі збереженням історії.
SELECT loan_id, book_id, return_date
FROM loan WHERE loan_id = 1001 AND return_date IS NULL;

UPDATE loan
SET return_date = '2026-11-26'
WHERE loan_id = 1001 AND return_date IS NULL;

SELECT loan_id, book_id, return_date
FROM loan WHERE loan_id = 1001;

SELECT book_id, title
FROM book b
WHERE b.book_id = 5 AND NOT EXISTS (
    SELECT 1 FROM loan l
    WHERE l.book_id = b.book_id AND l.return_date IS NULL
);

-- D9. Видалення авторства лише навчальної книги, яку далі видаляємо.
SELECT book_id, author_id
FROM book_author WHERE book_id = 1001 AND author_id = 1001;

DELETE FROM book_author
WHERE book_id = 1001 AND author_id = 1001;

SELECT book_id, author_id
FROM book_author WHERE book_id = 1001 AND author_id = 1001;

-- D10. Видалення навчальної книги без позик і авторства.
SELECT book_id, title
FROM book WHERE book_id = 1001;

DELETE FROM book
WHERE book_id = 1001;

SELECT book_id, title
FROM book WHERE book_id = 1001;

-- D11. Видалення автора, який більше не пов'язаний із книгами.
SELECT author_id, first_name, last_name
FROM author WHERE author_id = 1001;

DELETE FROM author
WHERE author_id = 1001;

SELECT author_id, first_name, last_name
FROM author WHERE author_id = 1001;

ROLLBACK;
