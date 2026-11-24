BEGIN;

CREATE TABLE member (
    member_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL CHECK (btrim(first_name) <> ''),
    last_name VARCHAR(100) NOT NULL CHECK (btrim(last_name) <> ''),
    email VARCHAR(254) CHECK (email ~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$'),
    phone VARCHAR(20) CHECK (phone ~ '^[+]?[0-9]{7,15}$')
);

CREATE TABLE author (
    author_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL CHECK (btrim(first_name) <> ''),
    last_name VARCHAR(100) NOT NULL CHECK (btrim(last_name) <> '')
);

CREATE TABLE book (
    book_id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL CHECK (btrim(title) <> ''),
    isbn VARCHAR(13) CHECK (isbn ~ '^([0-9]{9}[0-9X]|[0-9]{13})$'),
    publication_year INTEGER CHECK (publication_year > 0)
);

CREATE TABLE book_author (
    book_id INTEGER NOT NULL REFERENCES book(book_id) ON DELETE RESTRICT,
    author_id INTEGER NOT NULL REFERENCES author(author_id) ON DELETE RESTRICT,
    PRIMARY KEY (book_id, author_id)
);

CREATE TABLE loan (
    loan_id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL REFERENCES member(member_id) ON DELETE RESTRICT,
    book_id INTEGER NOT NULL REFERENCES book(book_id) ON DELETE RESTRICT,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    CONSTRAINT loan_due_date_check CHECK (due_date >= loan_date),
    CONSTRAINT loan_return_date_check CHECK (return_date >= loan_date)
);

-- Історичні позики дозволені; незавершена позика книги лише одна.
CREATE UNIQUE INDEX loan_one_open_per_book
    ON loan (book_id) WHERE return_date IS NULL;

COMMIT;
