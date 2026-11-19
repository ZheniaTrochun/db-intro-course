# Лабораторна робота 2: Перетворення ER-діаграми на схему PostgreSQL

## Мета

Метою роботи є перетворення концептуальної ER-моделі даних публічної бібліотеки, що була описана в Лабораторній роботі 1, у реляційну схему СУБД PostgreSQL, реалізувати структури таблиць із забезпеченням повної посилальної та доменної цілісності за допомогою обмежень, наповнити бази тестовими даними та підтвердити працездатність за допомогою SQL-запитів.

## Опис фізичної схеми бази даних

### Типи-перелічування
reader_status: 'active', 'blocked' - статус читацького квитка.
creator_role: 'author', 'translator', 'compiler', 'illustrator' - роль творця відносно видання.
copy_condition: 'good', 'normal', 'bad', 'lost' - фізичний стан примірника.
fine_type: 'overdue', 'damage', 'loss', 'violation' - причина нарахування штрафу.
fine_status: 'unpaid', 'paid', 'waived' - статус сплати нарахування.

### Специфікація таблиць
| Назва таблиці | Первинний ключ (PK) | Зовнішні ключі (FK) | Призначення |
| :--- | :--- | :--- | :--- |
| reader | reader_id (Identity) | - | Реєстр читачів бібліотеки |
| issue | issue_id (Identity) | - | Бібліографічний каталог видань |
| creator | creator_id (Identity) | - | Автори, перекладачі, ілюстратори |
| issue_creator | (issue_id, creator_id, creator_role) | issue_id -> issue creator_id -> creator | Зв'язок M:N між виданнями та їхніми авторами/творцями |
| copy | copy_id (Identity) | issue_id -> issue | Облік фізичних примірників у фонді |
| loan | loan_id (Identity) | reader_id -> reader copy_id -> copy | Фіксація фактів видачі та повернення книг |
| fine | fine_id (Identity) | reader_id -> reader (loan_id, reader_id) -> loan | Штрафні санкції та компенсації |

### Реалізація бізнес-правил
- У таблиці loan BR-LN-04: CHECK ((closed_date IS NULL) = (final_condition IS NULL)) — гарантує, що стан примірника фіксується тоді й тільки тоді, коли проставлено дату повернення.
- У таблиці fine BR-FN-03: CHECK ((closed_date IS NULL) = (fine_status = 'unpaid')) — закриття штрафу зобов'язує змінити статус на сплачений або анульований.
- У таблиці fine BR-FN-04: створено складений зовнішній ключ FOREIGN KEY (loan_id, reader_id) REFERENCES loan(loan_id, reader_id).
- Умови CHECK (end_date >= start_date) та CHECK (closed_date >= start_date) гарантують несуперечливість часових інтервалів.

## Повний SQL-скрипт розгортання бази даних

```sql
create type reader_status as enum ('active', 'blocked'); 
create type creator_role as enum ('author', 'translator', 'compiler', 'illustrator');
create type copy_condition as enum ('good', 'normal', 'bad', 'lost'); 
create type fine_type as enum ('overdue', 'damage', 'loss', 'violation'); 
create type fine_status as enum ('unpaid', 'paid', 'waived');


create table if not exists reader (
    reader_id integer generated always as identity primary key,
    tel_no varchar(32) not null unique,
    first_name varchar(32) not null,
    last_name varchar(32) not null,
    middle_name varchar(32),
    reader_status reader_status not null default 'active',
    reg_date date not null default current_date
);

create table if not exists issue (
    issue_id integer generated always as identity primary key,
    isbn varchar(32) unique,
    title varchar(256) not null check(length(trim(both ' ' from title)) > 0),
    publication_year smallint,
    language varchar(32),
    pages integer not null check(pages > 0),
    genre varchar(32)
);

create table if not exists creator (
    creator_id integer generated always as identity primary key,
    first_name varchar(64) not null,
    last_name varchar(64),
    middle_name varchar(32),
    pseudonym varchar(64)
);

create table if not exists issue_creator (
    issue_id integer not null references issue(issue_id) on delete cascade,
    creator_id integer not null references creator(creator_id) on delete cascade,
    creator_role creator_role not null,
    primary key (issue_id, creator_id, creator_role)
);

create table if not exists copy (
    copy_id integer generated always as identity primary key,
    issue_id integer not null references issue(issue_id),
    barcode varchar(32) not null unique,
    copy_condition copy_condition not null default 'good',
    reg_date date not null default current_date
);

create table if not exists loan (
    loan_id integer generated always as identity primary key,
    reader_id integer not null references reader(reader_id),
    copy_id integer not null references copy(copy_id),
    start_date date not null default current_date,
    end_date date not null check(end_date >= start_date),
    closed_date date check(closed_date is null or closed_date >= start_date),
    final_condition copy_condition,
    check((closed_date is null) = (final_condition is null)),
    unique(loan_id, reader_id)
);

create table if not exists fine (
    fine_id integer generated always as identity primary key,
    reader_id integer not null references reader(reader_id),
    loan_id integer,
    amount numeric(10, 2) not null check(amount > 0),
    start_date date not null default current_date,
    closed_date date check(closed_date is null or closed_date >= start_date),
    fine_type fine_type not null,
    fine_status fine_status not null default 'unpaid',
    description varchar(256) not null check(length(trim(both ' ' from description)) > 0),
    check((closed_date is null) = (fine_status = 'unpaid')),
    foreign key (loan_id, reader_id) references loan (loan_id, reader_id)
);

insert into reader (tel_no, first_name, last_name, middle_name, reader_status) values
('1234567890', 'John', 'Doe', 'A.', 'active'),
('0987654321', 'Jane', 'Smith', null, 'active'),
('3333333333', 'Alice', 'Johnson', 'B.', 'active'),
('4444444444', 'Bob', 'Brown', null, 'active'),
('5555555555', 'Alex', 'Gray', 'J.', 'blocked'),
('+380501112233', 'Олена', 'Коваленко', 'Іванівна', 'active'),
('+380672223344', 'Сергій', 'Мельник', null, 'active'),
('+380633334455', 'Марія', 'Шевченко', 'Петрівна', 'blocked'),
('+12025550143', 'David', 'Miller', 'Edward', 'active'),
('+12025550188', 'Emma', 'Watson', null, 'active'),
('+380994445566', 'Дмитро', 'Бондар', 'Олегович', 'active'),
('+380935556677', 'Анна', 'Ткаченко', null, 'blocked'),
('+380670001122', 'Олександр', 'Сидоренко', 'Петрович', 'active'),
('+380951114477', 'Ірина', 'Мельничук', null, 'active'),
('+380732228899', 'Максим', 'Кравченко', 'Олександрович', 'blocked');

insert into creator (first_name, last_name, middle_name, pseudonym) values
('F. Scott', 'Fitzgerald', null, null),
('Fyodor', 'Dostoevsky', null, null),
('Dan', 'Brown', null, null),
('George', 'Orwell', null, null),
('J.R.R.', 'Tolkien', null, null),
('Antoine', 'de Saint-Exupéry', null, null),
('Haruki', 'Murakami', null, null),
('Jay', 'Rubin', null, null),
('Neil', 'Gaiman', null, null),
('Terry', 'Pratchett', null, null),
('Quentin', 'Blake', null, null),
('Roald', 'Dahl', null, null),
('Stan', 'Lee', null, null),
('Jack', 'Kirby', null, null),
('Тарас', 'Шевченко', 'Григорович', 'Кобзар'),
('Богдан', 'Кравчук', 'Васильович', null),
('Ліна', 'Костенко', 'Василівна', null), 
('Михайло', 'Коцюбинський', 'Михайлович', null),
('Stephen', 'King', null, null),
('Brandon', 'Sanderson', null, null);

insert into issue (isbn, title, publication_year, language, pages, genre) values
('978-3-16-148410-0', 'The Great Gatsby', 1925, 'English', 218, 'Fiction'),
('978-0-14-044913-6', 'Crime and Punishment', 1866, 'Russian', 671, 'Fiction'),
('978-0-7432-7356-5', 'Angels & Demons', 2000, 'English', 616, 'Thriller'),
('978-0-452-28423-4', '1984', 1949, 'English', 328, 'Dystopian'),
('978-0-261-10235-4', 'The Fellowship of the Ring', 1954, 'English', 423, 'Fantasy'),
('978-0-15-601219-5', 'The Little Prince', 1943, 'French', 96, 'Fable'),
('978-0-099-44882-2', 'Norwegian Wood', 1987, 'Japanese', 296, 'Drama'),
('978-0-06-085398-3', 'Good Omens', 1990, 'English', 432, 'Comedy Fantasy'),
('978-0-14-136544-1', 'Matilda', 1988, 'English', 240, 'Children'),
('978-966-03-7123-1', 'Кобзар', 1840, 'Ukrainian', 115, 'Poetry'),
('978-0-7851-8558-1', 'Fantastic Four #1', 1961, 'English', 36, 'Comics'),
('978-966-2355-01-2', 'Антологія української народної казки', 2021, 'Ukrainian', 350, 'Folklore'),
('978-0-385-53785-8', 'Inferno', 2013, 'English', 463, 'Thriller'),
('978-966-03-8200-8', 'Тіні забутих предків', 1912, 'Ukrainian', 192, 'Classics'),
('978-0-7653-2635-5', 'The Way of Kings', 2010, 'English', 1007, 'Fantasy'),
('978-0-385-12167-5', 'The Shining', 1977, 'English', 447, 'Horror');

insert into issue_creator (issue_id, creator_id, creator_role) values
(1, 1, 'author'),
(2, 2, 'author'),
(3, 3, 'author'),
(4, 4, 'author'),
(5, 5, 'author'),
(6, 6, 'author'),
(6, 6, 'illustrator'),
(7, 7, 'author'),
(7, 8, 'translator'),
(8, 9, 'author'),
(8, 10, 'author'),
(9, 12, 'author'),
(9, 11, 'illustrator'),
(10, 15, 'author'),
(10, 15, 'illustrator'),
(11, 13, 'author'),
(11, 14, 'illustrator'),
(12, 16, 'compiler'),
(13, 3, 'author'),
(14, 18, 'author'),
(15, 20, 'author'),
(16, 19, 'author');

insert into copy (issue_id, barcode, copy_condition) values
(1, 'C001', 'good'),
(1, 'C002', 'normal'),
(2, 'C003', 'good'),
(3, 'C004', 'bad'),
(4, 'C005', 'lost'),
(5, 'C006', 'good'),
(5, 'C007', 'normal'),
(6, 'C008', 'good'),
(6, 'C009', 'bad'),
(7, 'C010', 'good'),
(8, 'C011', 'normal'),
(8, 'C012', 'good'),
(9, 'C013', 'good'),
(9, 'C014', 'bad'),
(10, 'C015', 'good'),
(10, 'C016', 'normal'),
(11, 'C017', 'good'),
(12, 'C018', 'good'),
(12, 'C019', 'lost'),
(14, 'C020', 'good'),
(14, 'C021', 'good'),
(15, 'C022', 'good'),
(15, 'C023', 'normal'),
(16, 'C024', 'good'),
(16, 'C025', 'good'),
(3, 'C026', 'good'),
(4, 'C027', 'good');

insert into loan (reader_id, copy_id, start_date, end_date, closed_date, final_condition) values
(1, 2, '2026-01-01', '2026-01-15', '2026-01-10', 'good'),
(2, 3, '2026-02-01', '2026-02-15', '2026-02-20', 'normal'),
(3, 5, '2026-03-01', '2026-03-15', '2026-03-20', 'lost'),
(4, 1, '2026-04-01', '2026-04-15', '2026-04-10', 'good'),
(1, 1, '2026-05-01', '2026-05-15', null, null),
(2, 2, '2026-06-01', '2026-06-15', null, null),
(3, 3, '2026-07-01', '2026-07-15', null, null),
(6, 6, '2026-08-01', '2026-08-15', '2026-08-14', 'good'),
(7, 7, '2026-08-01', '2026-08-15', '2026-08-25', 'normal'),
(8, 8, '2026-08-10', '2026-08-24', '2026-08-20', 'bad'),
(8, 19, '2026-08-15', '2026-08-29', '2026-08-28', 'lost'),
(9, 10, '2026-09-01', '2026-09-15', '2026-09-12', 'good'),
(10, 11, '2026-10-25', '2026-11-15', null, null),
(11, 12, '2026-09-01', '2026-09-15', null, null),
(8, 13, '2026-09-10', '2026-09-24', null, null),
(6, 15, '2026-09-15', '2026-09-29', '2026-09-28', 'good'),
(11, 17, '2026-10-30', '2026-11-13', null, null),
(13, 22, '2026-10-01', '2026-10-15', null, null),
(13, 23, '2026-10-05', '2026-10-20', null, null),
(13, 24, '2026-10-10', '2026-10-25', null, null),
(13, 26, '2026-10-12', '2026-10-26', null, null),
(13, 27, '2026-08-01', '2026-08-15', '2026-08-14', 'good'),
(15, 25, '2026-09-01', '2026-09-15', '2026-10-10', 'bad');

insert into fine (reader_id, loan_id, amount, start_date, fine_type, description, fine_status, closed_date) values
(5, null, 100, '2026-06-04', 'violation', 'Violation of library rules', 'unpaid', null),
(2, 2, 100, '2026-02-15', 'overdue', 'Overdue book', 'paid', '2026-02-20'),
(3, 3, 200, '2026-03-15', 'loss', 'Lost book', 'waived', '2026-03-20'),
(7, 9, 50.00, '2026-08-25', 'overdue', 'Затримка повернення книги на 10 днів', 'paid', '2026-08-26'),
(8, 10, 120.00, '2026-08-20', 'damage', 'Пошкоджено палітурку та кілька сторінок', 'paid', '2026-08-22'),
(8, 11, 450.00, '2026-08-28', 'loss', 'Втрата книги з фонду бібліотеки', 'unpaid', null),
(6, 8, 25.00, '2026-08-16', 'overdue', 'Прострочення через хворобу, надано довідку', 'waived', '2026-08-18'),
(12, null, 150.00, '2026-10-01', 'violation', 'Порушення тиші в читальній залі та відмова показати квиток', 'unpaid', null),
(9, null, 50.00, '2026-09-05', 'violation', 'Відновлення загубленого читацького квитка', 'paid', '2026-09-06'),
(11, null, 300.00, '2026-10-15', 'damage', 'Пошкоджено стіл у загальній залі', 'unpaid', null),
(15, 23, 75.00, '2026-09-16', 'overdue', 'Затримка повернення книги на 25 днів', 'unpaid', null),
(15, 23, 160.00, '2026-10-10', 'damage', 'Пошкоджено палітурку, розірвано кілька сторінок', 'unpaid', null),
(13, null, 50.00, '2026-10-02', 'violation', 'Розмови по гучному зв’язку у читальній залі', 'paid', '2026-10-03');
```

## Результат виконання

ЕR-діаграма була коректно перенесена у фізичну схему PostgreSQL. Усі 7 таблиць та 5 типів-перелічувань створено у схемі.
Кожна таблиця була наповнена тестовим набором даних, що охоплює типові та граничні бізнес-сценарії
Коректність була перевірена в pgAdmin за допомогою SQL-запитів. Результати збережені у папку `tests`.

- перевірка таблиці примірників: lab2\tests\copy.png
- перевірка таблиці творців: lab2\tests\creator.png
- перевірка таблиці штрафів: lab2\tests\fine.png
- перевірка таблиці видання-творці: lab2\tests\issue_creator.png
- перевірка таблиці видання: lab2\tests\issue.png
- перевірка таблиці видача: lab2\tests\loan.png
- перевірка таблиці читачі: lab2\tests\reader.png

## Висновки
Під час виконання лабораторної роботи ER-модель публічної бібліотеки була успішно трансформована у фізичну схему PostgreSQL, повністю верифікована тестовими даними та підготовлена до виконання у наступних роботах.
