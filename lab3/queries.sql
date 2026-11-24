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
