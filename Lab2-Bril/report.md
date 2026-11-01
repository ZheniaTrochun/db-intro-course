# Лабораторна робота №2
# iCARus 


## 1. Мета роботи 
Метою роботи є перетворення ER-моделі системи оренди автомобілів iCARus на реляційну схему PostgreSQL. У цій роботі потрібно створити таблиці відповідно до визначених сутностей і зв’язків, задати типи даних, первинні та зовнішні ключі, а також обмеження цілісності. Додатково потрібно заповнити таблиці тестовими даними та перевірити коректність їх створення і взаємодії один з одним.


## 2. Специфікація таблиць

У базі даних створено п'ять таблиць: `customer`, `car_model`, `car`, `rental` та `payment`.

### 2.1. Таблиця `customer` (клієнти)

| Стовпець | Тип даних | Обмеження |
|---|---|---|
| `customer_id` | INT | PK, GENERATED ALWAYS AS IDENTITY |
| `first_name` | VARCHAR(100) | NOT NULL |
| `last_name` | VARCHAR(100) | NOT NULL |
| `email` | VARCHAR(100) | NOT NULL, UNIQUE |
| `phone` | VARCHAR(20) | NOT NULL |
| `address` | VARCHAR(100) | NOT NULL |

### 2.2. Таблиця `car_model` (моделі автомобілів)

| Стовпець | Тип даних | Обмеження |
|---|---|---|
| `car_model_id` | INT | PK, GENERATED ALWAYS AS IDENTITY |
| `brand` | VARCHAR(100) | NOT NULL |
| `model` | VARCHAR(100) | NOT NULL |
| `category` | VARCHAR(50) | NOT NULL |
| `description` | TEXT | — |
| `daily_rate` | NUMERIC(10, 2) | NOT NULL, CHECK (daily_rate >= 0) |

### 2.3. Таблиця `car` (автомобілі)

| Стовпець | Тип даних | Обмеження |
|---|---|---|
| `car_id` | INT | PK, GENERATED ALWAYS AS IDENTITY |
| `car_model_id` | INT | NOT NULL, FK → `car_model(car_model_id)` |
| `status` | car_status (ENUM) | NOT NULL, DEFAULT 'available' |

### 2.4. Таблиця `rental` (оренди)

| Стовпець | Тип даних | Обмеження |
|---|---|---|
| `rental_id` | INT | PK, GENERATED ALWAYS AS IDENTITY |
| `customer_id` | INT | NOT NULL, FK → `customer(customer_id)` |
| `car_id` | INT | NOT NULL, FK → `car(car_id)` |
| `start_date` | TIMESTAMP | NOT NULL |
| `end_date` | TIMESTAMP | NOT NULL, CHECK (end_date > start_date) |
| `price` | NUMERIC(10, 2) | NOT NULL, CHECK (price >= 0) |
| `status` | rental_status (ENUM) | NOT NULL, DEFAULT 'scheduled' |

### 2.5. Таблиця `payment` (платежі)

| Стовпець | Тип даних | Обмеження |
|---|---|---|
| `payment_id` | INT | PK, GENERATED ALWAYS AS IDENTITY |
| `rental_id` | INT | NOT NULL, FK → `rental(rental_id)` |
| `amount` | NUMERIC(10, 2) | NOT NULL, CHECK (amount > 0) |
| `payment_date` | TIMESTAMP | NOT NULL |
| `status` | payment_status (ENUM) | NOT NULL, DEFAULT 'pending_confirmation' |

### 2.6. Зв'язки між таблицями

- `customer` → `rental`: один клієнт може мати декілька оренд, кожна оренда належить одному клієнту (1:N).
- `car` → `rental`: один автомобіль може фігурувати в декількох орендах у різні періоди, кожна оренда стосується одного автомобіля (1:N).
- `car_model` → `car`: одна модель може відповідати декільком автомобілям, кожен автомобіль належить до однієї моделі (1:N).
- `rental` → `payment`: одна оренда може мати декілька платежів, кожен платіж належить одній оренді (1:N).



## 3. Повний SQL-скрипт розгортання бази даних (DDL)

**Файл:** [`schema.sql`](schema.sql)

```sql
CREATE TYPE car_status AS ENUM ('available', 'rented', 'maintenance', 'unavailable');
CREATE TYPE rental_status AS ENUM ('active', 'finished', 'cancelled', 'scheduled');
CREATE TYPE payment_status AS ENUM ('paid', 'cancelled', 'pending_confirmation');

CREATE TABLE customer (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    address VARCHAR(100) NOT NULL
);

CREATE TABLE car_model (
    car_model_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    daily_rate NUMERIC(10, 2) NOT NULL CHECK (daily_rate >= 0)
);

CREATE TABLE car (
    car_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    car_model_id INT NOT NULL REFERENCES car_model(car_model_id),
    status car_status NOT NULL DEFAULT 'available'
);

CREATE TABLE rental (
    rental_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id),
    car_id INT NOT NULL REFERENCES car(car_id),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL CHECK (end_date > start_date),
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    status rental_status NOT NULL DEFAULT 'scheduled'
);

CREATE TABLE payment (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rental_id INT NOT NULL REFERENCES rental(rental_id),
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_date TIMESTAMP NOT NULL,
    status payment_status NOT NULL DEFAULT 'pending_confirmation'
);
```



## 4. Тестові дані (DML)

**Файл:** [`test_data.sql`](test_data.sql)

```sql
INSERT INTO customer (first_name, last_name, email, phone, address) VALUES
    ('Ivan', 'Petrenko', 'ivan.petrenko@gmail.com', '+380661234567', 'Kyiv...'),
    ('Olena', 'Kovalenko', 'ole.koval22@gmail.com', '+380677645634', 'Lviv...'),
    ('Andrii', 'Shevchenko', 'shevaANDRI@gmail.com', '+380503545065', 'Odesa...'),
    ('Lionel', 'Messi', 'messiiilliinno12@gmail.com', '+380999999999', 'Kharkiv...'),
    ('Alex', 'Patriot', 'hhfgdfdf435@gmail.com', '+380631234567', 'Dnipro...');



INSERT INTO car_model (brand, model, category, description, daily_rate) VALUES
    ('Toyota', 'Land Cruiser 300', 'SUV', 'Full-size off-road SUV...', 7000.00),
    ('BMW', 'X5 G05', 'SUV', 'Premium luxury SUV...', 7000.00),
    ('Volkswagen', 'Passat B8', 'Sedan', 'Comfortable family sedan...', 3600.00),
    ('Mercedes-Benz', 'E-Class W213', 'Sedan', 'Executive luxury sedan...', 9000.00),
    ('Audi', 'Q7', 'SUV', 'Premium family SUV...', 7600.00);



INSERT INTO car (car_model_id, status) VALUES
    (1, 'available'),
    (2, 'rented'),
    (3, 'available'),
    (4, 'maintenance'),
    (5, 'unavailable');



INSERT INTO rental (customer_id, car_id, start_date, end_date, price, status) VALUES
    (1, 1, '2026-01-10 09:00:00', '2026-01-15 09:00:00', 35000.00, 'finished'),
    (2, 2, '2026-10-28 10:00:00', '2026-11-02 10:00:00', 35000.00, 'active'),
    (3, 3, '2026-11-05 12:00:00', '2026-11-10 12:00:00', 18000.00, 'scheduled'),
    (4, 4, '2026-02-01 08:00:00', '2026-02-04 08:00:00', 27000.00, 'cancelled'),
    (1, 1, '2026-03-15 09:00:00', '2026-03-18 09:00:00', 21000.00, 'finished');



INSERT INTO payment (rental_id, amount, payment_date, status) VALUES
    (1, 35000.00, '2026-01-09 14:30:00', 'paid'),
    (2, 17500.00, '2026-10-27 12:00:00', 'paid'),
    (2, 17500.00, '2026-10-28 09:00:00', 'paid'),
    (3, 18000.00, '2026-11-04 15:00:00', 'pending_confirmation'),
    (4, 27000.00, '2026-01-31 16:00:00', 'cancelled'),
    (5, 21000.00, '2026-03-14 11:00:00', 'paid');
```


## 5. Важливі обмеження та припущення

Під час створення схеми бази даних було використано такі обмеження та припущення:

- Для кожної таблиці визначено первинний ключ, який забезпечує унікальну ідентифікацію записів.
- Електронна адреса клієнта (`email`) має бути унікальною.
- Обов'язкові поля визначено як `NOT NULL`.
- Для числових значень, зокрема вартості оренди та денної ставки, використано тип `NUMERIC(10, 2)`.
- Для статусів автомобілів, оренди та платежів використано перелічувані типи (`ENUM`), що обмежують можливі значення.
- Вартість оренди (`price`) зберігається окремо від стандартної денної ставки моделі автомобіля (`daily_rate`). Таким чином, загальна ціна конкретної оренди не залежить від подальшої зміни стандартного тарифу.
- Дата завершення оренди повинна бути пізнішою за дату її початку (`end_date > start_date`).
- Фіксована стандартна ціна оренди за один день не може бути від'ємною (`daily_rate >= 0`).
- Загальна ціна оренди не може бути від'ємною (`price >= 0`).
- Сума платежу повинна бути більшою за нуль (`amount > 0`).
- У лабораторній роботі №1 тип ідентифікаторів було зазначено як `string` на рівні ER-моделі. Під час переходу до фізичної реалізації бази даних їх було конкретизовано як `INT` із `GENERATED ALWAYS AS IDENTITY`.
- Для таблиць `car`, `rental` та `payment` визначено значення статусів за замовчуванням: `available`, `scheduled` та `pending_confirmation` відповідно.



## Результат виконання

Коректність створення та заповнення таблиць було перевірено в pgAdmin за допомогою SQL-запитів. 
Результати виконання запитів збережено у папці `photo_report`.

- Перевірка таблиці клієнтів --- **файл:** [`customer_test.png`](photo_report/customer_test.png)
- Перевірка автомобілів і моделей --- **файл:** [`car_test.png`](photo_report/car_test.png)
- Перевірка оренд --- **файл:** [`rental_test.png`](photo_report/rental_test.png)
- Перевірка платежів --- **файл:** [`payment_test.png`](photo_report/payment_test.png)
- Комплексна перевірка зв'язків між таблицями --- **файл:** [`main_test.png`](photo_report/main_test.png)