SELECT title, isbn, publication_year
FROM Book
WHERE publication_year > 2010;

SELECT copy_id, book_id, status
FROM BookCopy
WHERE status = 'available';

SELECT loan_id, reader_id, copy_id, issue_date, due_date
FROM Loan
WHERE return_date IS NULL;


INSERT INTO Reader (full_name, email, phone)
VALUES ('Франко Іван Якович', 'franko.ivan@example.com', '+380675556677');

SELECT reader_id, full_name, email, phone
FROM Reader
WHERE email = 'franko.ivan@example.com';

INSERT INTO Book (title, isbn, publication_year, category_id)
VALUES ('1984', '978-0451524935', 1949, 2);

INSERT INTO BookCopy (book_id, status)
VALUES (5, 'available');

SELECT book_id, title, isbn, publication_year FROM Book WHERE book_id = 5;
SELECT copy_id, book_id, status FROM BookCopy WHERE book_id = 5;


SELECT loan_id, reader_id, copy_id, issue_date, due_date, return_date
FROM Loan
WHERE loan_id = 1;


UPDATE Loan
SET return_date = CURRENT_DATE
WHERE loan_id = 1;

UPDATE BookCopy
SET status = 'available'
WHERE copy_id = 1;

SELECT loan_id, copy_id, return_date FROM Loan WHERE loan_id = 1;
SELECT copy_id, book_id, status FROM BookCopy WHERE copy_id = 1;

INSERT INTO Reader (full_name, email, phone)
VALUES ('Тестовий Користувач', 'test.delete@example.com', '+380990000000');

SELECT reader_id, full_name, email
FROM Reader
WHERE email = 'test.delete@example.com';

DELETE FROM Reader
WHERE email = 'test.delete@example.com';

SELECT reader_id, full_name, email
FROM Reader
WHERE email = 'test.delete@example.com';
