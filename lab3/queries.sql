-- Q1. Початкові дані всіх п'яти таблиць.
SELECT member_id, first_name, last_name, email, phone
FROM member
ORDER BY member_id;

SELECT author_id, first_name, last_name
FROM author
ORDER BY author_id;

SELECT book_id, title, isbn, publication_year
FROM book
ORDER BY book_id;

SELECT book_id, author_id
FROM book_author
ORDER BY book_id, author_id;

SELECT loan_id, member_id, book_id, loan_date, due_date, return_date
FROM loan
ORDER BY loan_id;

-- Q2. Кількість рядків у кожній таблиці.
SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
UNION ALL
SELECT 'author', COUNT(*) FROM author
UNION ALL
SELECT 'book', COUNT(*) FROM book
UNION ALL
SELECT 'book_author', COUNT(*) FROM book_author
UNION ALL
SELECT 'loan', COUNT(*) FROM loan;

-- Q3. Контакти конкретного читача.
SELECT member_id, first_name, last_name, email, phone
FROM member
WHERE member_id = 1;

-- Q4. Пошук книги за частиною назви.
SELECT book_id, title, publication_year
FROM book
WHERE title ILIKE '%пісня%'
ORDER BY book_id;

-- Q5. Книги автора з ID 2.
SELECT b.book_id, b.title, a.first_name, a.last_name
FROM book b
JOIN book_author ba ON ba.book_id = b.book_id
JOIN author a ON a.author_id = ba.author_id
WHERE a.author_id = 2
ORDER BY b.book_id;

-- Q6. Доступні для видачі книги.
SELECT b.book_id, b.title
FROM book b
WHERE NOT EXISTS (
    SELECT 1 FROM loan l
    WHERE l.book_id = b.book_id AND l.return_date IS NULL
)
ORDER BY b.book_id;

-- Q7. Історія позик читача з ID 1.
SELECT l.loan_id, b.title, l.loan_date, l.due_date, l.return_date
FROM loan l
JOIN book b ON b.book_id = l.book_id
WHERE l.member_id = 1
ORDER BY l.loan_date, l.loan_id;

-- Q8. Прострочені незавершені позики на фіксовану навчальну дату.
SELECT l.loan_id, m.first_name, m.last_name, b.title, l.due_date
FROM loan l
JOIN member m ON m.member_id = l.member_id
JOIN book b ON b.book_id = l.book_id
WHERE l.return_date IS NULL AND l.due_date < DATE '2026-11-25'
ORDER BY l.loan_id;
