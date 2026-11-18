# ЗВІТ
##### з Лабораторної роботи №2

**Тема:** Перетворення ER-діаграми на схему PostgreSQL

**Предметна область:** Інтернет-магазин одягу

Виконали студентки групи ІМ-53: Горічко Марта, Денісова Анна та Денісова Тетяна

---

### 1. Мета роботи

Практичне засвоєння навичок трансляції концептуальної ER-моделі у фізичну схему реляційної бази даних, розробка DDL-скриптів для створення користувацьких типів даних (`ENUM`) і таблиць, визначення первинних та зовнішніх ключів, встановлення обмежень цілісності (`CHECK`, `UNIQUE`, `NOT NULL`, `DEFAULT`), а також перевірка функціонування бази за допомогою DML-запитів (`INSERT`, `SELECT`).

---

### 2. Специфікація таблиць фізичної бази даних

База даних **`clothing_store_db`** складається з користувацького типу даних `order_status` (`ENUM`) та 7 взаємопов'язаних таблиць:

| Назва таблиці | Первинний ключ (PK) | Зовнішній ключ (FK) | Правило видалення (ON DELETE) | Обмеження цілісності (Constraints) |
| --- | --- | --- | --- | --- |
| **`category`** | `category_id` (`IDENTITY`) | — | — | `category_name` (`NOT NULL`, `UNIQUE`) |
| **`customer`** | `customer_id` (`IDENTITY`) | — | — | `first_name`, `last_name`, `phone` (`NOT NULL`), `email` (`NOT NULL`, `UNIQUE`) |
| **`product`** | `product_id` (`IDENTITY`) | `category_id` $\to$ `category` | `NO ACTION` (за замовчуванням) | `product_name` (`NOT NULL`), `product_price` (`NOT NULL`, $\ge 0$) |
| **`product_item`** | `product_item_id` (`IDENTITY`) | `product_id` $\to$ `product` | `NO ACTION` (за замовчуванням) | `product_item_size`, `product_item_color` (`NOT NULL`), `product_item_stock_quantity` ($\ge 0$) |
| **`"order"`** | `order_id` (`IDENTITY`) | `customer_id` $\to$ `customer` | `NO ACTION` (за замовчуванням) | `order_date` (`DEFAULT now()`), `order_price` ($\ge 0$), `order_status` (тип `order_status` ENUM) |
| **`order_item`** | `order_item_id` (`IDENTITY`) | `order_id` $\to$ `"order"`<br>

<br>`product_item_id` $\to$ `product_item` | `NO ACTION` (за замовчуванням) | `order_item_quantity` ($> 0$)<br>

<br>`order_item_unit_price` ($\ge 0$) |
| **`payment`** | `payment_id` (`IDENTITY`) | `order_id` $\to$ `"order"` | `NO ACTION` (за замовчуванням) | `payment_date` (`DEFAULT now()`), `payment_amount` ($\ge 0$), `payment_method` (`NOT NULL`) |

---

### 3. Повний SQL-скрипт розгортання бази даних (DDL & DML)

```sql
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS order_item CASCADE;
DROP TABLE IF EXISTS "order" CASCADE;
DROP TABLE IF EXISTS product_item CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TYPE IF EXISTS order_status CASCADE;

CREATE TYPE order_status AS ENUM ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned');

CREATE TABLE category (
    category_id int generated always as identity primary key,
    category_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE customer (
    customer_id int generated always as identity primary key,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone varchar(20) NOT NULL
);
CREATE TABLE product (
    product_id int generated always as identity primary key,
    category_id int NOT NULL REFERENCES category(category_id),
    product_name VARCHAR(150) NOT NULL,
    product_description TEXT,
    product_price NUMERIC(10, 2) NOT NULL CHECK (product_price >= 0)
);
CREATE TABLE product_item (
    product_item_id int generated always as identity primary key,
    product_id int NOT NULL REFERENCES product(product_id),
    product_item_size VARCHAR(5) NOT NULL,
    product_item_color VARCHAR(20) NOT NULL,
    product_item_stock_quantity int NOT NULL CHECK (product_item_stock_quantity >= 0)
);
CREATE TABLE "order" (
    order_id int generated always as identity primary key,
    customer_id int NOT NULL REFERENCES customer(customer_id),
    order_date TIMESTAMP DEFAULT now(),
    order_price NUMERIC(10, 2) NOT NULL CHECK (order_price >= 0),
    order_status order_status not null
);
CREATE TABLE order_item (
    order_item_id int generated always as identity primary key,
    order_id int NOT NULL REFERENCES "order"(order_id),
    product_item_id int NOT NULL REFERENCES product_item(product_item_id),
    order_item_quantity int NOT NULL CHECK (order_item_quantity > 0),
    order_item_unit_price NUMERIC(10, 2) NOT NULL CHECK (order_item_unit_price >= 0)
);
CREATE TABLE payment (
    payment_id int generated always as identity primary key,
    order_id INTEGER NOT NULL REFERENCES "order"(order_id),
    payment_date TIMESTAMP DEFAULT now(),
    payment_amount NUMERIC(10, 2) NOT NULL CHECK (payment_amount >= 0),
    payment_method VARCHAR(50) NOT NULL
);

INSERT INTO category (category_name) VALUES
    ('Верхній одяг'),
    ('Джинси та штани'),
    ('Футболки та поло');

INSERT INTO customer (first_name, last_name, email, phone) VALUES
    ('Марта', 'Горічко', 'marta.gorichko@example.com', '+380501112233'),
    ('Анна', 'Денісова', 'anna.denisova@example.com', '+380672223344'),
    ('Тетяна', 'Денісова', 'tetiana.denisova@example.com', '+380933334455');

INSERT INTO product (category_id, product_name, product_description, product_price) VALUES
    (1, 'Джинсова куртка Classic', 'Стильна куртка з деніму вільного крою', 1899.00),
    (2, 'Джинси Slim Fit', 'Зручні повсякденні джинси', 1450.00),
    (3, 'Базова футболка Basic', 'Бавовняна однотонна футболка', 499.00);

INSERT INTO product_item (product_id, product_item_size, product_item_color, product_item_stock_quantity) VALUES
    (1, 'M', 'Синій', 15),
    (1, 'L', 'Синій', 8),
    (2, '32/32', 'Чорний', 12),
    (3, 'S', 'Білий', 25),
    (3, 'M', 'Білий', 30);

INSERT INTO "order" (customer_id, order_date, order_price, order_status) VALUES
    (1, '2026-10-25 10:15:00', 2398.00, 'Processing'),
    (2, '2026-10-26 14:30:00', 1450.00, 'Delivered'),
    (3, '2026-10-28 09:00:00', 499.00, 'Pending');

INSERT INTO order_item (order_id, product_item_id, order_item_quantity, order_item_unit_price) VALUES
    (1, 1, 1, 1899.00), 
    (1, 4, 1, 499.00),
    (2, 3, 1, 1450.00), 
    (3, 5, 1, 499.00);  

INSERT INTO payment (order_id, payment_date, payment_amount, payment_method) VALUES
    (1, '2026-10-25 10:18:00', 2398.00, 'Apple Pay'),
    (2, '2026-10-26 14:35:00', 1450.00, 'Credit Card');

```

---

### 4. Обґрунтування захисних механізмів та бізнес-правил

1. **Сучасна автогенерація первинних ключів (`GENERATED ALWAYS AS IDENTITY`):**
* Для всіх первинних ключів використано стандартну конструкцію SQL `INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY` замість застарілого `SERIAL`. Це захищає ідентифікатори від випадкового ручного перезапису під час вставки даних.


2. **Контроль статусів на рівні типів даних (`CREATE TYPE ... AS ENUM`):**
* Замість звичайного текстового поля з перевіркою `CHECK`, для атрибута `order_status` створено окремий перераховуваний тип `order_status`. Це оптимізує зберігання даних і гарантує, що замовлення може набувати виключно валідних бізнес-станів: `'Pending'`, `'Processing'`, `'Shipped'`, `'Delivered'`, `'Cancelled'`, `'Returned'`.


3. **Захист посилальної цілісності за замовчуванням (`ON DELETE NO ACTION`):**
* Усі зовнішні ключі (`REFERENCES`) використовують стандартну поведінку PostgreSQL (`NO ACTION`), яка блокує видалення батьківського запису (наприклад, клієнта, категорії чи замовлення), якщо на нього посилаються дочірні записи. Це запобігає випадковій втраті історії покупок і фінансової звітності.


4. **Фіксація ціни на момент покупки (`order_item_unit_price`):**
* Поле `order_item_unit_price` зберігає точну ціну одиниці товару під час оформлення замовлення. Подальше редагування `product_price` у таблиці `product` не спотворює суми вже здійснених продажів.


5. **Валідація числових значень за допомогою обмежень `CHECK` та унікальності (`UNIQUE`):**
* Обмеження `CHECK (>= 0)` для цін (`product_price`, `order_price`, `order_item_unit_price`, `payment_amount`) та складських залишків (`product_item_stock_quantity`), а також `CHECK (> 0)` для кількості товарів у замовленні (`order_item_quantity`) виключають аномалії від'ємних або нульових значень.
* Обмеження `UNIQUE` для `category_name` та `email` гарантує відсутність дублікатів категорій і облікових записів клієнтів.



---

### 5. Висновок

У ході лабораторної роботи №2 було успішно спроєктовано та реалізовано фізичну базу даних `clothing_store_db` у СУБД PostgreSQL. Створено користувацький тип `order_status` (`ENUM`) та 7 нормалізованих таблиць із первинними ключами `IDENTITY` і зовнішніми ключами. Реалізовані обмеження цілісності (`CHECK`, `UNIQUE`, `NOT NULL`, `REFERENCES`) забезпечують надійний захист даних від некоректного введення та порушення зв'язків. Наповнення таблиць тестовими даними за допомогою `INSERT` та перевірка вибірками підтвердили коректну роботу розгорнутої схеми.

---
