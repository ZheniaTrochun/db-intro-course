-- Перегляд усіх таблиць.
SELECT * FROM member ORDER BY member_id;
SELECT * FROM author ORDER BY author_id;
SELECT * FROM book ORDER BY book_id;
SELECT * FROM book_author ORDER BY book_id, author_id;
SELECT * FROM loan ORDER BY loan_id;

-- Очікувані кількості: 5, 5, 5, 6, 5.
SELECT 'member' AS table_name, count(*) AS row_count FROM member
UNION ALL SELECT 'author', count(*) FROM author
UNION ALL SELECT 'book', count(*) FROM book
UNION ALL SELECT 'book_author', count(*) FROM book_author
UNION ALL SELECT 'loan', count(*) FROM loan;

-- Обидві сторони M:N: книга 4 має двох авторів; автор 2 має дві книги.
SELECT b.book_id, b.title, a.first_name, a.last_name
FROM book b
JOIN book_author ba ON ba.book_id = b.book_id
JOIN author a ON a.author_id = ba.author_id
ORDER BY b.book_id, a.author_id;

-- Доступні книги: у початкових даних 2 і 5.
SELECT b.* FROM book b
WHERE NOT EXISTS (
    SELECT 1 FROM loan l WHERE l.book_id = b.book_id AND l.return_date IS NULL
) ORDER BY b.book_id;

-- Прострочення залежить від фактичної дати виконання.
SELECT * FROM loan WHERE return_date IS NULL AND due_date < CURRENT_DATE;

-- B9: результат має бути порожнім. FK сам по собі не гарантує автора кожній книзі.
SELECT b.book_id, b.title FROM book b
WHERE NOT EXISTS (SELECT 1 FROM book_author ba WHERE ba.book_id = b.book_id);

-- Визначення PK, FK, CHECK та індексу в поточній схемі.
SELECT c.relname AS table_name, con.conname, pg_get_constraintdef(con.oid) AS definition
FROM pg_constraint con JOIN pg_class c ON c.oid = con.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = current_schema()
  AND c.relname IN ('member', 'author', 'book', 'book_author', 'loan')
ORDER BY c.relname, con.conname;
SELECT tablename, indexname, indexdef FROM pg_indexes
WHERE schemaname = current_schema() AND tablename = 'loan';
