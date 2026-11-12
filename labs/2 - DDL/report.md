# Лабораторна робота № 2: Перетворення ER-діаграми на реляційну схему PostgreSQL

**Предметна область:** Інформаційна система кінотеатру  
**Виконав:** Круковський Володимир Шон Ігорович, група ІМ-51  

---

## 1. Мета роботи

Перетворення концептуальної ER-діаграми предметної області кінотеатру на фізичну реляційну схему бази даних у середовищі СУБД **PostgreSQL**. У межах роботи визначено типи даних атрибутів, налаштовано первинні (`PRIMARY KEY`) та зовнішні (`FOREIGN KEY`) ключі, реалізовано бізнес-правила та обмеження цілісності (`NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`), а також виконано наповнення таблиць тестовими даними та перевірку їхньої коректності у **pgAdmin 4**.

---

## 2. Опис структури реляційної схеми та обмежень

Реляційна схема складається з **7 нормалізованих таблиць**, які відображають усі сутності та зв'язки ER-моделі.

### 2.1. Таблиця `HALL` (Кінозали)
Зберігає довідкову інформацію про доступні зали кінотеатру та їхню місткість.

| Стовпець | Тип даних | Ключі та обмеження | Опис призначення |
| :--- | :--- | :--- | :--- |
| `HallID` | `SERIAL` | `PRIMARY KEY` | Унікальний автоінкрементний ідентифікатор залу. |
| `HallNumber` | `VARCHAR(50)` | `NOT NULL` | Назва або номер залу (наприклад, `Зал 1 (2D)`). |
| `TotalSeats` | `INTEGER` | `NOT NULL`, `CHECK (TotalSeats > 0)` | Загальна кількість місць. Обмеження гарантує додатну місткість. |

### 2.2. Таблиця `SEAT` (Посадкові місця)
Описує конфігурацію місць у кожному конкретному залі (зв'язок `1:N` від `HALL` до `SEAT`).

| Стовпець | Тип даних | Ключі та обмеження | Опис призначення |
| :--- | :--- | :--- | :--- |
| `SeatID` | `SERIAL` | `PRIMARY KEY` | Унікальний ідентифікатор посадкового місця. |
| `HallID` | `INTEGER` | `NOT NULL`, `FK -> HALL(HallID)` | Зовнішній ключ, що прив'язує місце до конкретного залу. |
| `RowNumber` | `INTEGER` | `NOT NULL`, `CHECK (RowNumber > 0)` | Номер ряду в залі (суворо більше нуля). |
| `SeatNumber` | `INTEGER` | `NOT NULL`, `CHECK (SeatNumber > 0)` | Номер місця в ряду (суворо більше нуля). |
| `SeatType` | `VARCHAR(50)` | `NOT NULL`, `DEFAULT 'Standard'` | Категорія комфорту місця (`Standard`, `Comfort`, `VIP`). |

### 2.3. Таблиця `CLIENT` (Клієнти)
Містить персональні та контактні дані зареєстрованих відвідувачів кінотеатру.

| Стовпець | Тип даних | Ключі та обмеження | Опис призначення |
| :--- | :--- | :--- | :--- |
| `ClientID` | `SERIAL` | `PRIMARY KEY` | Унікальний ідентифікатор клієнта. |
| `FullName` | `VARCHAR(100)` | `NOT NULL` | Повне ім'я та прізвище клієнта. |
| `Email` | `VARCHAR(100)` | `UNIQUE`, `NOT NULL` | Електронна пошта. `UNIQUE` запобігає дублюванню акаунтів. |
| `Phone` | `VARCHAR(20)` | `NOT NULL` | Контактний номер телефону клієнта. |

### 2.4. Таблиця `MOVIE` (Фільми)
Каталог кінострічок, доступних у прокаті кінотеатру.

| Стовпець | Тип даних | Ключі та обмеження | Опис призначення |
| :--- | :--- | :--- | :--- |
| `MovieID` | `SERIAL` | `PRIMARY KEY` | Унікальний ідентифікатор фільму. |
| `Title` | `VARCHAR(150)` | `NOT NULL` | Назва фільму. |
| `Genre` | `VARCHAR(100)` | `NOT NULL` | Жанр кінострічки. |
| `ReleaseYear` | `INTEGER` | `CHECK (ReleaseYear > 1900)` | Рік випуску. Виключає некоректні дати до початку ери кінематографа. |
| `BasePrice` | `NUMERIC(8,2)` | `NOT NULL`, `CHECK (BasePrice >= 0)` | Базова ціна квитка з фіксованою точністю; дозволяє нульову ціну для акцій, але блокує від'ємні суми. |

### 2.5. Таблиця `"ORDER"` (Замовлення)
Фіксує факт оформлення замовлення клієнтом. Назва таблиці взята в подвійні лапки, оскільки `ORDER` є зарезервованим ключовим словом SQL.

| Стовпець | Тип даних | Ключі та обмеження | Опис призначення |
| :--- | :--- | :--- | :--- |
| `OrderID` | `SERIAL` | `PRIMARY KEY` | Унікальний номер замовлення. |
| `ClientID` | `INTEGER` | `NOT NULL`, `FK -> CLIENT(ClientID)` | Зовнішній ключ на клієнта, який здійснив замовлення. |
| `OrderDate` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Дата та час створення замовлення (автоматично фіксується поточний час). |

### 2.6. Таблиця `TICKET` (Квитки)
Реалізує деталізацію замовлення та пов'язує замовлення, фільм, конкретне місце в залі та час сеансу.

| Стовпець | Тип даних | Ключі та обмеження | Опис призначення |
| :--- | :--- | :--- | :--- |
| `TicketID` | `SERIAL` | `PRIMARY KEY` | Унікальний номер квитка. |
| `OrderID` | `INTEGER` | `NOT NULL`, `FK -> "ORDER"(OrderID)` | Посилання на замовлення, в межах якого придбано квиток. |
| `MovieID` | `INTEGER` | `NOT NULL`, `FK -> MOVIE(MovieID)` | Посилання на обраний фільм. |
| `SeatID` | `INTEGER` | `NOT NULL`, `FK -> SEAT(SeatID)` | Посилання на заброньоване посадкове місце. |
| `Showtime` | `TIMESTAMP` | `NOT NULL` | Дата та час початку кіносеансу. |

### 2.7. Таблиця `PAYMENT` (Платежі)
Зберігає інформацію про фінансові транзакції за оформленими замовленнями.

| Стовпець | Тип даних | Ключі та обмеження | Опис призначення |
| :--- | :--- | :--- | :--- |
| `PaymentID` | `SERIAL` | `PRIMARY KEY` | Унікальний ідентифікатор платіжної транзакції. |
| `OrderID` | `INTEGER` | `NOT NULL`, `FK -> "ORDER"(OrderID)` | Посилання на оплачуване замовлення. |
| `Amount` | `NUMERIC(10,2)` | `NOT NULL`, `CHECK (Amount > 0)` | Фактична сума оплати. Обмеження гарантує, що платіж є суворо додатним. |
| `PaymentDate` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Дата та час проведення платежу. |
| `PaymentMethod` | `VARCHAR(50)` | `NOT NULL` | Спосіб оплати (`Credit Card`, `Apple Pay`, `Cash`). |

---

## 3. SQL-скрипт створення структури бази даних (DDL)

Таблиці створюються строго від батьківських до дочірніх, щоб забезпечити коректну ініціалізацію зовнішніх ключів.

```sql
-- Очищення попередніх версій таблиць
DROP TABLE IF EXISTS PAYMENT CASCADE;
DROP TABLE IF EXISTS "ORDER" CASCADE;
DROP TABLE IF EXISTS TICKET CASCADE;
DROP TABLE IF EXISTS MOVIE CASCADE;
DROP TABLE IF EXISTS SEAT CASCADE;
DROP TABLE IF EXISTS HALL CASCADE;
DROP TABLE IF EXISTS CLIENT CASCADE;

-- 1. Таблиця кінозалів
CREATE TABLE HALL (
    HallID SERIAL PRIMARY KEY,
    HallNumber VARCHAR(50) NOT NULL,
    TotalSeats INTEGER NOT NULL CHECK (TotalSeats > 0)
);

-- 2. Таблиця посадкових місць у залах
CREATE TABLE SEAT (
    SeatID SERIAL PRIMARY KEY,
    HallID INTEGER NOT NULL REFERENCES HALL(HallID),
    RowNumber INTEGER NOT NULL CHECK (RowNumber > 0),
    SeatNumber INTEGER NOT NULL CHECK (SeatNumber > 0),
    SeatType VARCHAR(50) NOT NULL DEFAULT 'Standard'
);

-- 3. Таблиця клієнтів
CREATE TABLE CLIENT (
    ClientID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20) NOT NULL
);

-- 4. Таблиця фільмів
CREATE TABLE MOVIE (
    MovieID SERIAL PRIMARY KEY,
    Title VARCHAR(150) NOT NULL,
    Genre VARCHAR(100) NOT NULL,
    ReleaseYear INTEGER CHECK (ReleaseYear > 1900),
    BasePrice NUMERIC(8,2) NOT NULL CHECK (BasePrice >= 0)
);

-- 5. Таблиця замовлень
CREATE TABLE "ORDER" (
    OrderID SERIAL PRIMARY KEY,
    ClientID INTEGER NOT NULL REFERENCES CLIENT(ClientID),
    OrderDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 6. Таблиця квитків
CREATE TABLE TICKET (
    TicketID SERIAL PRIMARY KEY,
    OrderID INTEGER NOT NULL REFERENCES "ORDER"(OrderID),
    MovieID INTEGER NOT NULL REFERENCES MOVIE(MovieID),
    SeatID INTEGER NOT NULL REFERENCES SEAT(SeatID),
    Showtime TIMESTAMP NOT NULL
);

-- 7. Таблиця платежів
CREATE TABLE PAYMENT (
    PaymentID SERIAL PRIMARY KEY,
    OrderID INTEGER NOT NULL REFERENCES "ORDER"(OrderID),
    Amount NUMERIC(10,2) NOT NULL CHECK (Amount > 0),
    PaymentDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PaymentMethod VARCHAR(50) NOT NULL
);
```

---

## 4. SQL-скрипт наповнення таблиць тестовими даними (DML)

Порядок вставки записів відповідає ієрархії залежностей: спочатку заповнюються батьківські таблиці (`HALL`, `CLIENT`, `MOVIE`), а потім — дочірні (`SEAT`, `"ORDER"`, `TICKET`, `PAYMENT`).

```sql
-- Наповнення таблиці HALL
INSERT INTO HALL (HallNumber, TotalSeats) VALUES
('Зал 1 (2D)', 100),
('Зал 2 (3D)', 60),
('Зал 3 (VIP)', 30);

-- Наповнення таблиці SEAT
INSERT INTO SEAT (HallID, RowNumber, SeatNumber, SeatType) VALUES
(1, 1, 5, 'Standard'),
(1, 1, 6, 'Standard'),
(2, 3, 10, 'Comfort'),
(3, 2, 2, 'VIP');

-- Наповнення таблиці CLIENT
INSERT INTO CLIENT (FullName, Email, Phone) VALUES
('Йосип Бігуді', 'yosip@example.com', '+380691122333'),
('Марія Потужна', 'maria@example.com', '+380672223344'),
('Іван Переможний', 'ivan@example.com', '+380523334455');

-- Наповнення таблиці MOVIE
INSERT INTO MOVIE (Title, Genre, ReleaseYear, BasePrice) VALUES
('Залаштунки', 'психологічний хоррор', 2026, 250.00),
('Бійцівський клуб', 'психологічний трилер', 1999, 200.00),
('Потяг "Червона рута"', 'комедія', 2026, 180.00);

-- Наповнення таблиці "ORDER"
INSERT INTO "ORDER" (ClientID) VALUES
(1),
(2),
(3);

-- Наповнення таблиці TICKET
INSERT INTO TICKET (OrderID, MovieID, SeatID, Showtime) VALUES
(1, 1, 1, '2026-06-10 18:00:00'),
(1, 1, 2, '2026-06-10 18:00:00'),
(2, 2, 3, '2026-06-11 20:30:00'),
(3, 3, 4, '2026-06-12 15:00:00');

-- Наповнення таблиці PAYMENT
INSERT INTO PAYMENT (OrderID, Amount, PaymentMethod) VALUES
(1, 500.00, 'Credit Card'),
(2, 180.00, 'Apple Pay'),
(3, 200.00, 'Cash');
```

---

## 5. Тестування та перевірка даних у pgAdmin 4

Усі DDL- та DML-інструкції виконано в **Query Tool** середовища pgAdmin 4 без помилок. Для перевірки цілісності зв'язків та наповнення таблиць виконано контрольні запити:

```sql
-- Перевірка вмісту таблиць
SELECT * FROM HALL;
SELECT * FROM SEAT;
SELECT * FROM CLIENT;
SELECT * FROM MOVIE;
SELECT * FROM "ORDER";
SELECT * FROM TICKET;
SELECT * FROM PAYMENT;

-- Контрольний аналітичний запит: кількість проданих квитків за фільмами
SELECT 
    m.Title AS MovieTitle,
    COUNT(t.TicketID) AS TotalTickets
FROM MOVIE m
JOIN TICKET t ON m.MovieID = t.MovieID
GROUP BY m.Title;
```
## 6. Висновки

Під час виконання лабораторної роботи № 2 концептуальну ER-модель інформаційної системи кінотеатру було успішно перетворено на реляційну схему бази даних у СУБД **PostgreSQL**. Створено 7 взаємопов'язаних таблиць із коректно підібраними типами даних (`NUMERIC` для грошових сум із фіксованою точністю, `TIMESTAMP` для часових міток, `SERIAL` для первинних ключів), налаштовано посилальну цілісність (`FOREIGN KEY`) та бізнес-обмеження (`NOT NULL`, `UNIQUE`, `DEFAULT`, `CHECK`). Тестове заповнення таблиць та виконання контрольних вибірок у pgAdmin 4 підтвердили коректність архітектури схеми.
