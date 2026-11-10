# ЗВІТ
##### з Лабораторної роботи №2
**Тема:** Перетворення ER-діаграми на схему PostgreSQL
**Предметна область:** Інтернет-магазин одягу  

Виконали студентки групи ІМ-53 : Горічко Марта, Денісова Анна та Денісова Тетяна
---

### 1. Мета роботи
Практичне засвоєння навичок трансляції концептуальної ER-моделі в фізичну схему реляційної бази даних, розробка DDL-скриптів для створення таблиць, визначення первинних та зовнішніх ключів, встановлення обмежень цілісності (`CHECK`, `UNIQUE`, `NOT NULL`, `DEFAULT`), налагодження правил каскадного видалення (`ON DELETE CASCADE`, `RESTRICT`) та перевірка функціонування бази за допомогою DML-запитів (`INSERT`, `SELECT`).

---

### 2. Специфікація таблиць фізичної бази даних

База даних **`clothing_store_db`** складається з 7 взаємопов'язаних таблиць:

| Назва таблиці | Первинний ключ (PK) | Зовнішній ключ (FK) | Правило видалення (ON DELETE) | Обмеження цілісності (Constraints) |
| :--- | :--- | :--- | :--- | :--- |
| **`category`** | `category_id` | — | — | `category_name` (NOT NULL, UNIQUE) |
| **`customer`** | `customer_id` | — | — | `email` (NOT NULL, UNIQUE) |
| **`product`** | `product_id` | `category_id` $\to$ `category` | `RESTRICT` | `product_price` $\ge 0$ |
| **`product_item`** | `product_item_id` | `product_id` $\to$ `product` | `CASCADE` | `product_item_stock_quantity` $\ge 0$ |
| **`order`** | `order_id` | `customer_id` $\to$ `customer` | `RESTRICT` | `order_price` $\ge 0$, `order_status` IN (...) |
| **`order_item`** | `order_item_id` | `order_id` $\to$ `order`<br>`product_item_id` $\to$ `product_item` | `CASCADE`<br>`RESTRICT` | `order_item_quantity` $> 0$<br>`order_item_unit_price` $\ge 0$ |
| **`payment`** | `payment_id` | `order_id` $\to$ `order` | `CASCADE` | `order_id` (UNIQUE), `payment_amount` $\ge 0$ |

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


--Категрії товарів
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

 --Покупці (Клієнти)
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL
);

--Товари (Загальна інформація)
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES category(category_id) ON DELETE RESTRICT,
    product_name VARCHAR(150) NOT NULL,
    product_description TEXT,
    product_price NUMERIC(10, 2) NOT NULL CHECK (product_price >= 0)
);

--Варіація товару (розмір,колір,залишки на складі)
CREATE TABLE product_item (
    product_item_id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    product_item_size VARCHAR(20) NOT NULL,
    product_item_color VARCHAR(30) NOT NULL,
    product_item_stock_quantity INTEGER NOT NULL CHECK (product_item_stock_quantity >= 0)
);

--Замовлення
CREATE TABLE "order" (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_price NUMERIC(10, 2) NOT NULL CHECK (order_price >= 0),
    order_status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (
        order_status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned')
    )
);

--Деталі/позиції замовлення
CREATE TABLE order_item (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES "order"(order_id) ON DELETE CASCADE,
    product_item_id INTEGER NOT NULL REFERENCES product_item(product_item_id) ON DELETE RESTRICT,
    order_item_quantity INTEGER NOT NULL CHECK (order_item_quantity > 0),
    order_item_unit_price NUMERIC(10, 2) NOT NULL CHECK (order_item_unit_price >= 0)
);

--Платежі
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE REFERENCES "order"(order_id) ON DELETE CASCADE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_amount NUMERIC(10, 2) NOT NULL CHECK (payment_amount >= 0),
    payment_method VARCHAR(50) NOT NULL
);

--тестові дані
INSERT INTO category (category_id, category_name) VALUES
    (1, 'Верхній одяг'),
    (2, 'Джинси та штани'),
    (3, 'Футболки та поло');

INSERT INTO customer (customer_id, first_name, last_name, email, phone) VALUES
    (1, 'Марта', 'Горічко', 'marta.gorichko@example.com', '+380501112233'),
    (2, 'Анна', 'Денісова', 'anna.denisova@example.com', '+380672223344'),
    (3, 'Тетяна', 'Денісова', 'tetiana.denisova@example.com', '+380933334455');

INSERT INTO product (product_id, category_id, product_name, product_description, product_price) VALUES
    (1, 1, 'Джинсова куртка Classic', 'Стильна куртка з деніму вільного крою', 1899.00),
    (2, 2, 'Джинси Slim Fit', 'Зручні повсякденні джинси', 1450.00),
    (3, 3, 'Базова футболка Basic', 'Бавовняна однотонна футболка', 499.00);

INSERT INTO product_item (product_item_id, product_id, product_item_size, product_item_color, product_item_stock_quantity) VALUES
    (1, 1, 'M', 'Синій', 15),
    (2, 1, 'L', 'Синій', 8),
    (3, 2, '32/32', 'Чорний', 12),
    (4, 3, 'S', 'Білий', 25),
    (5, 3, 'M', 'Білий', 30);

INSERT INTO "order" (order_id, customer_id, order_date, order_price, order_status) VALUES
    (101, 1, '2026-10-25 10:15:00', 2398.00, 'Processing'),
    (102, 2, '2026-10-26 14:30:00', 1450.00, 'Delivered'),
    (103, 3, '2026-10-28 09:00:00', 499.00, 'Pending');

INSERT INTO order_item (order_item_id, order_id, product_item_id, order_item_quantity, order_item_unit_price) VALUES
    (1, 101, 1, 1, 1899.00),
    (2, 101, 4, 1, 499.00),
    (3, 102, 3, 1, 1450.00),
    (4, 103, 5, 1, 499.00);

INSERT INTO payment (payment_id, order_id, payment_date, payment_amount, payment_method) VALUES
    (1, 101, '2026-10-25 10:18:00', 2398.00, 'Apple Pay'),
    (2, 102, '2026-10-26 14:35:00', 1450.00, 'Credit Card');
```

---

### 4. Обґрунтування захисних механізмів та бізнес-правил

1. **Захист від руйнування критичних даних (`ON DELETE RESTRICT`):**
   * Для зв'язку `category` $\to$ `product` та `customer` $\to$ `order` встановлено правило `RESTRICT`. Це унеможливлює випадкове видалення клієнта із системою за наявності активних чи минулих замовлень або видалення категорії, до якої прив'язані товари.
2. **Каскадне видалення залежних структур (`ON DELETE CASCADE`):**
   * При видаленні замовлення (`order`) автоматично видаляються пов'язані з ним позиції (`order_item`) та платіжна транзакція (`payment`), що запобігає появі «записів-сиріт».
3. **Фіксація ціни на момент покупки (`order_item_unit_price`):**
   * Поле `order_item_unit_price` зберігає точну ціну одиниці товару під час створення замовлення. Подальше редагування `product_price` у таблиці `product` не змінює фінансові звіти за минулими покупками.
4. **Валідація за допомогою обмежень `CHECK`:**
   * Заборонено введення від'ємних цін, залишків та нульових кількостей у замовленні (`CHECK >= 0`, `CHECK > 0`).
   * Статус замовлення обмежено фіксованим списком бізнес-станів: `'Pending'`, `'Processing'`, `'Shipped'`, `'Delivered'`, `'Cancelled'`, `'Returned'`.
5. **Гарантія зв'язку $1:0..1$ для платежу:**
   * Зовнішній ключ `order_id` у таблиці `payment` має обмеження `UNIQUE`, що робить неможливим повторну прив'язку кількох платежів до одного замовлення.

---

### 5. Висновок

У ході лабораторної роботи №2 було успішно реалізовано фізичну базу даних `clothing_store_db` у  PostgreSQL. Створено 7 таблиць із чітко визначеними первинними та зовнішніми ключами. Реалізовані обмеження цілісності (`CHECK`, `UNIQUE`, `ON DELETE CASCADE/RESTRICT`) гарантують надійний захист даних від некоректного введення та втрати зв'язків. Тестування бази даних за допомогою `INSERT` та `SELECT` запитів підтвердило повну функціональність розгорнутої системи.