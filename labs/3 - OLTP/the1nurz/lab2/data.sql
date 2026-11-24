BEGIN;

INSERT INTO member (member_id, first_name, last_name, email, phone) VALUES
    (1, 'Олена', 'Коваль', 'olena@example.com', '+380501234567'),
    (2, 'Андрій', 'Мельник', 'andrii@example.com', '+380671234568'),
    (3, 'Марія', 'Бондар', NULL, '+380931234569'),
    (4, 'Іван', 'Шевченко', 'ivan@example.com', NULL),
    (5, 'Софія', 'Ткаченко', NULL, NULL);

INSERT INTO author (author_id, first_name, last_name) VALUES
    (1, 'Леся', 'Українка'),
    (2, 'Іван', 'Франко'),
    (3, 'Тарас', 'Шевченко'),
    (4, 'Панас', 'Мирний'),
    (5, 'Іван', 'Білик');

-- ISBN невідомі: не підставляємо вигадані номери видань.
INSERT INTO book (book_id, title, isbn, publication_year) VALUES
    (1, 'Лісова пісня', NULL, 1912),
    (2, 'Захар Беркут', NULL, 1883),
    (3, 'Кобзар', NULL, 1840),
    (4, 'Хіба ревуть воли, як ясла повні?', NULL, 1880),
    (5, 'Борислав сміється', NULL, 1882);

INSERT INTO book_author (book_id, author_id) VALUES
    (1, 1), (2, 2), (3, 3), (4, 4), (4, 5), (5, 2);

INSERT INTO loan (loan_id, member_id, book_id, loan_date, due_date, return_date) VALUES
    (1, 1, 1, '2026-09-01', '2026-09-15', '2026-09-12'),
    (2, 2, 1, '2026-10-01', '2026-10-15', NULL),
    (3, 1, 2, '2026-09-02', '2026-09-16', '2026-09-20'),
    (4, 3, 3, '2026-10-20', '2026-11-03', NULL),
    (5, 4, 4, '2026-10-21', '2026-11-04', NULL);

COMMIT;
