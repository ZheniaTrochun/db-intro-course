DROP TABLE IF EXISTS Book_Author CASCADE;
DROP TABLE IF EXISTS Loan CASCADE;
DROP TABLE IF EXISTS BookCopy CASCADE;
DROP TABLE IF EXISTS Book CASCADE;
DROP TABLE IF EXISTS Author CASCADE;
DROP TABLE IF EXISTS Category CASCADE;
DROP TABLE IF EXISTS Reader CASCADE;

CREATE TABLE Category (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Author (
    author_id   SERIAL PRIMARY KEY,
    author_name VARCHAR(150) NOT NULL
);

CREATE TABLE Reader (
    reader_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email     VARCHAR(150) NOT NULL UNIQUE,
    phone     VARCHAR(20)  NOT NULL UNIQUE
);

CREATE TABLE Book (
    book_id          SERIAL PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    isbn             VARCHAR(20)  NOT NULL UNIQUE,
    publication_year INTEGER      NOT NULL CHECK (publication_year >= 1450 AND publication_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    category_id      INTEGER      NOT NULL REFERENCES Category(category_id) ON DELETE RESTRICT
);

CREATE TABLE Book_Author (
    book_id   INTEGER NOT NULL REFERENCES Book(book_id) ON DELETE CASCADE,
    author_id INTEGER NOT NULL REFERENCES Author(author_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE BookCopy (
    copy_id SERIAL PRIMARY KEY,
    book_id INTEGER     NOT NULL REFERENCES Book(book_id) ON DELETE CASCADE,
    status  VARCHAR(20) NOT NULL DEFAULT 'available'
            CHECK (status IN ('available', 'borrowed', 'restoration', 'lost'))
);

CREATE TABLE Loan (
    loan_id     SERIAL PRIMARY KEY,
    reader_id   INTEGER NOT NULL REFERENCES Reader(reader_id) ON DELETE RESTRICT,
    copy_id     INTEGER NOT NULL REFERENCES BookCopy(copy_id) ON DELETE RESTRICT,
    issue_date  DATE    NOT NULL DEFAULT CURRENT_DATE,
    due_date    DATE    NOT NULL CHECK (due_date >= issue_date),
    return_date DATE    NULL     CHECK (return_date IS NULL OR return_date >= issue_date)
);


INSERT INTO Category (category_name) VALUES
    ('Програмування'),
    ('Наукова фантастика'),
    ('Історія'),
    ('Психологія');

INSERT INTO Author (author_name) VALUES
    ('Роберт Мартін'),
    ('Ендрю Хант'),
    ('Девід Томас'),
    ('Френк Герберт'),
    ('Юваль Ной Харарі');

INSERT INTO Reader (full_name, email, phone) VALUES
    ('Козорог Єгор Євгенійович', 'kozoroh.yehor@example.com', '+380671112233'),
    ('Глазкова Ілона Андріївна', 'hlazkova.ilona@example.com', '+380502223344'),
    ('Шевченко Тарас Григорович', 'shevchenko.taras@example.com', '+380933334455'),
    ('Косач Лариса Петрівна', 'kosach.larysa@example.com', '+380634445566');

INSERT INTO Book (title, isbn, publication_year, category_id) VALUES
    ('Чистий код', '978-0132350884', 2008, 1),
    ('Прагматичний програміст', '978-0135957059', 2019, 1),
    ('Дюна', '978-0441172719', 1965, 2),
    ('Sapiens: Людина розумна', '978-0062316097', 2011, 3);

INSERT INTO Book_Author (book_id, author_id) VALUES
    (1, 1),
    (2, 2),
    (2, 3),
    (3, 4),
    (4, 5);

INSERT INTO BookCopy (book_id, status) VALUES
    (1, 'borrowed'),
    (1, 'available'),
    (2, 'available'),
    (3, 'borrowed'),
    (4, 'restoration');

INSERT INTO Loan (reader_id, copy_id, issue_date, due_date, return_date) VALUES
    (1, 1, '2026-11-10', '2026-11-24', NULL),
    (2, 4, '2026-11-15', '2026-11-29', NULL),
    (3, 2, '2026-10-01', '2026-10-15', '2026-10-14'),
    (4, 3, '2026-10-05', '2026-10-19', '2026-10-21');
