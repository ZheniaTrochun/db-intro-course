# Лабораторна робота №5. Нормалізація бази даних

**Виконали:** студенти групи ІМ-54 — Дрига О.О., Голубков В.С., Ретізник А.Є.
**Перевірив:** Хмельницький А.А.

**Тема:** Нормалізація бази даних до третьої нормальної форми (3НФ) на прикладі схеми онлайн-книжкового магазину (PostgreSQL).

**Мета:** Проаналізувати наявну схему бази даних книжкового магазину, виявити надлишковість даних та аномалії вставки, оновлення й видалення, визначити функціональні залежності та поточну нормальну форму таблиць. Після цього послідовно привести схему до 1НФ, 2НФ і 3НФ шляхом усунення повторюваних груп, часткових і транзитивних залежностей. Результатом має стати цілісна схема, у якій кожен факт зберігається лише один раз, із відповідними `CREATE TABLE`-скриптами та оновленою ER-діаграмою.

## Підсумок аналізу таблиць

| Таблиця | Початкова нормальна форма | Що змінено |
|---|---|---|
| `customer` | не відповідає 1НФ | адресу винесено в `address`, міста в `city` |
| `orders` | не відповідає 1НФ, порушує 3НФ | `shipping_address` замінено на `shipping_address_id`, видалено похідний `total_amount` |
| `author` | 3НФ формально | країну винесено в довідник `country` |
| `publisher` | 3НФ формально | країну винесено в довідник `country` |
| `category` | 3НФ | без змін |
| `book` | 3НФ | без змін |
| `book_author` | 3НФ | без змін |
| `book_category` | 3НФ | без змін |
| `order_item` | 3НФ | без змін |
| `review` | 2НФ (порушує 3НФ) | видалено `book_id`, змінено обмеження |

Нові таблиці: `country`, `city`, `address`.

---

## Таблиця customer

**Початковий SQL-скрипт:**

```sql
CREATE TABLE customer (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    registration_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipping_address_default VARCHAR(255)
);
```

**Схема початкової таблиці:** `customer(PK customer_id, first_name, last_name, UQ email, UQ phone, registration_date, shipping_address_default)`

**Ключі таблиці (кандидат-ключі):**

1. `customer_id` — первинний ключ (`PRIMARY KEY`).
2. `email` — унікальний ключ (`UNIQUE NOT NULL`).
3. `phone` — унікальний ключ (`UNIQUE NOT NULL`).

**Функціональні залежності (ФЗ):**

- `customer_id → first_name, last_name, email, phone, registration_date, shipping_address_default`
- `email → customer_id`
- `phone → customer_id`

**Оцінка початкової нормальної форми та виявлення аномалій:**

- **Початкова нормальна форма:** не відповідає 1НФ (порушує вимогу атомарності).
- **Порушення 1НФ:** атрибут `shipping_address_default` зберігає повну адресу одним рядком (наприклад, `'м. Київ, вул. Хрещатик, 15, кв. 4'`). Це неатомарне значення, яке поєднує в собі місто, вулицю, номер будинку та квартири. Така структура ускладнює пошук і фільтрацію за містом або вулицею, а також породжує надмірність даних і ризик різного написання одних і тих самих назв (наприклад, `'м. Київ'` та `'Київ'`).
- **Аномалії на рівні 3НФ:** навіть після розбиття адреси на окремі колонки в межах таблиці `customer` назви міст повторюватимуться для кожного клієнта. Це створює аномалію оновлення (при перейменуванні міста доведеться змінювати всі рядки клієнтів із цього міста), аномалію вставки (неможливо додати місто в систему без клієнта) та аномалію видалення (видалення останнього клієнта з міста призведе до втрати інформації про саме місто).

**Покрокова нормалізація:**

**Етап 1 (Перехід до 1НФ):** забезпечуємо атомарність усіх значень. Виконуємо декомпозицію: прибираємо складене поле `shipping_address_default` і виносимо адресу в окрему таблицю `address` з неподільними стовпцями (`city_name`, `street`, `building`, `apartment`), а в `customer` залишаємо посилання `default_address_id`.

**Схеми:**

```
customer(PK customer_id, first_name, last_name, UQ email, UQ phone, registration_date, FK default_address_id)
address(PK address_id, city_name, street, building, apartment)
```

**Етап 2 (Перехід до 2НФ):** обидві таблиці знаходяться в 1НФ і мають одинарні первинні ключі (`customer_id` та `address_id`), тому часткових залежностей не існує. Усі неключові атрибути повністю функціонально залежать від первинного ключа.

**Схеми:**

```
customer(PK customer_id, first_name, last_name, UQ email, UQ phone, registration_date, FK default_address_id)
address(PK address_id, city_name, street, building, apartment)
```

**Етап 3 (Перехід до 3НФ):** усуваємо дублювання назв міст та пов'язані з ним аномалії за допомогою декомпозиції таблиці `address`. Виносимо міста в окрему таблицю-довідник `city`, а в таблиці `address` зберігаємо лише зовнішній ключ `city_id`. Тепер кожен факт (назва міста) зберігається в базі лише один раз, а транзитивних залежностей немає.

**Фінальні схеми (3НФ):**

```
city(PK city_id, UQ city_name)
address(PK address_id, FK city_id, street, building, apartment)
customer(PK customer_id, first_name, last_name, UQ email, UQ phone, registration_date, FK default_address_id)
```

**SQL-команди для створення нових таблиць та зміни customer (`CREATE TABLE`, `ALTER TABLE`):**

```sql
CREATE TABLE city (
    city_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE address (
    address_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    city_id INT NOT NULL REFERENCES city(city_id) ON DELETE RESTRICT,
    street VARCHAR(150) NOT NULL,
    building VARCHAR(20) NOT NULL,
    apartment VARCHAR(20)
);

ALTER TABLE customer DROP COLUMN shipping_address_default;
ALTER TABLE customer ADD COLUMN default_address_id INT REFERENCES address(address_id) ON DELETE SET NULL;
```

**Перероблений SQL-скрипт створення таблиці customer (`CREATE TABLE` у 3НФ):**

```sql
CREATE TABLE customer (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    registration_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    default_address_id INT REFERENCES address(address_id) ON DELETE SET NULL
);
```

---

## Таблиця orders

**Початковий SQL-скрипт:**

```sql
CREATE TABLE orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status order_status NOT NULL DEFAULT 'Pending',
    shipping_address VARCHAR(255) NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0)
);
```

**Схема початкової таблиці:** `orders(PK order_id, FK customer_id, order_date, status, shipping_address, total_amount)`

**Ключі таблиці:**

1. `order_id` — первинний ключ (`PRIMARY KEY`).

**Функціональні залежності (ФЗ):**

- `order_id → customer_id, order_date, status, shipping_address, total_amount`
- `order_item(quantity, price_at_purchase) → total_amount` (похідна залежність: загальна сума замовлення однозначно визначається позиціями цього замовлення в таблиці `order_item`)

**Оцінка початкової нормальної форми та виявлення аномалій:**

- **Початкова нормальна форма:** не відповідає 1НФ (та має порушення на рівні 3НФ).
- **Порушення 1НФ:** поле `shipping_address`, аналогічно до таблиці `customer`, містить неатомарний текстовий рядок з повною адресою доставки, що призводить до дублювання адрес і неможливості їх коректного аналізу.
- **2НФ (виконано після приведення до 1НФ):** первинний ключ `order_id` складається з одного атрибута, тому часткових залежностей немає.
- **Порушення 3НФ (надмірність даних та аномалія оновлення):** атрибут `total_amount` є похідним, оскільки загальна вартість замовлення завжди обчислюється на основі рядків таблиці `order_item` за формулою `SUM(quantity * price_at_purchase)`. Зберігання обчислюваної суми в `orders` порушує цілісність даних і створює аномалію оновлення: якщо змінити кількість товару або видалити позицію в `order_item` і не перерахувати `total_amount` у таблиці `orders`, дані в базі стануть суперечливими.

**Покрокова нормалізація:**

**Етап 1 (Перехід до 1НФ):** видаляємо неатомарне текстове поле `shipping_address` та замінюємо його зовнішнім ключем `shipping_address_id`, який посилається на вже створену нормалізовану таблицю `address`.

**Схема:** `orders(PK order_id, FK customer_id, order_date, status, FK shipping_address_id, total_amount)`

**Етап 2 (Перехід до 2НФ):** ключ `order_id` одинарний, кожен неключовий атрибут повністю залежить від первинного ключа — додаткових змін не потрібно.

**Схема:** `orders(PK order_id, FK customer_id, order_date, status, FK shipping_address_id, total_amount)`

**Етап 3 (Перехід до 3НФ):** видаляємо похідний атрибут `total_amount`, щоб усунути надмірність та аномалію оновлення. Загальну суму замовлення слід обчислювати динамічно під час виконання запитів до таблиці `order_item`. Усі залишені атрибути залежать виключно від первинного ключа `order_id`.

**Фінальна схема (3НФ):** `orders(PK order_id, FK customer_id, order_date, status, FK shipping_address_id)`

**SQL-команди для зміни існуючої таблиці orders (`ALTER TABLE`):**

```sql
ALTER TABLE orders DROP COLUMN shipping_address;
ALTER TABLE orders DROP COLUMN total_amount;
ALTER TABLE orders ADD COLUMN shipping_address_id INT NOT NULL REFERENCES address(address_id) ON DELETE RESTRICT;
```

**Перероблений SQL-скрипт створення таблиці orders (`CREATE TABLE` у 3НФ):**

```sql
CREATE TABLE orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    order_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status order_status NOT NULL DEFAULT 'Pending',
    shipping_address_id INT NOT NULL REFERENCES address(address_id) ON DELETE RESTRICT
);
```

---

## Таблиця author

**Початковий SQL-скрипт:**

```sql
CREATE TABLE author (
    author_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    country VARCHAR(50)
);
```

**Схема початкової таблиці:** `author(PK author_id, first_name, last_name, country)`

**Ключі таблиці:**

1. `author_id` — первинний ключ (`PRIMARY KEY`).

**Функціональні залежності (ФЗ):**

- `author_id → first_name, last_name, country`
- `(first_name, last_name) → country` не є ФЗ, бо тезки можуть бути з різних країн.

**Оцінка початкової нормальної форми та виявлення аномалій:**

- **Початкова нормальна форма:** 3НФ формально, але країна записана текстом, через це є аномалії.
- **1НФ (виконано):** усі значення атомарні: у `country` одна країна, а не список. Повторюваних груп немає, є первинний ключ.
- **2НФ (виконано):** первинний ключ `author_id` складається з одного стовпця, тому часткова залежність неможлива.
- **Порушення 3НФ (формальне):** країна це окрема сутність, яка зберігається текстом у двох таблицях (`author` і `publisher`). Це дає ланцюжок `author_id → country → iso_code` (як тільки в країни з'являються власні атрибути) та аномалії. Аномалія вставки: ніщо не контролює написання, тому «USA» і «Сша» база вважає різними країнами, а країну не можна додати без автора чи видавця. Аномалія оновлення: «США» повторюється в багатьох рядках `author` і `publisher`, тому при перейменуванні можна змінити не всі. Аномалія видалення: «Велика Британія» є лише в двох авторів, і після їх видалення інформація про країну зникне. Також країна дублюється в двох таблицях без єдиного джерела істини.

**Покрокова нормалізація:**

**Етап 1 (Перехід до 1НФ):** усі значення атомарні, повторюваних груп немає, змін не потрібно.

**Схема:** `author(PK author_id, first_name, last_name, country)`

**Етап 2 (Перехід до 2НФ):** ключ простий, часткових залежностей немає, змін не потрібно.

**Схема:** `author(PK author_id, first_name, last_name, country)`

**Етап 3 (Перехід до 3НФ):** виносимо країну в окремий довідник `country` із сурогатним ключем, унікальним ISO-кодом і унікальною назвою, а в `author` залишаємо лише зовнішній ключ `country_id`. Тепер кожна країна зберігається в базі лише один раз.

**Фінальні схеми (3НФ):**

```
country(PK country_id, UQ iso_code, UQ name_country)
author(PK author_id, first_name, last_name, FK country_id)
```

**SQL-команди для створення нової таблиці та зміни author (`CREATE TABLE`, `ALTER TABLE`):**

```sql
CREATE TABLE country (
    country_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    iso_code     CHAR(2)      NOT NULL UNIQUE
                 CONSTRAINT chk_country_iso CHECK (iso_code ~ '^[A-Z]{2}$'),
    name_country VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO country (iso_code, name_country) VALUES
    ('UA', 'Україна'),
    ('US', 'США'),
    ('GB', 'Велика Британія');

ALTER TABLE author
    ADD COLUMN country_id INT,
    ADD CONSTRAINT fk_author_country
        FOREIGN KEY (country_id) REFERENCES country(country_id)
        ON DELETE RESTRICT;

UPDATE author a
SET country_id = c.country_id
FROM country c
WHERE c.name_country = a.country;

ALTER TABLE author DROP COLUMN country;
CREATE INDEX idx_author_country ON author(country_id);
```

**Перероблений SQL-скрипт створення таблиці author (`CREATE TABLE` у 3НФ):**

```sql
CREATE TABLE author (
    author_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    country_id INT,
    CONSTRAINT fk_author_country
        FOREIGN KEY (country_id) REFERENCES country(country_id)
        ON DELETE RESTRICT
);
```

---

## Таблиця publisher

**Початковий SQL-скрипт:**

```sql
CREATE TABLE publisher (
    publisher_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name_publisher VARCHAR(100) UNIQUE NOT NULL,
    country_publisher VARCHAR(50)
);
```

**Схема початкової таблиці:** `publisher(PK publisher_id, UQ name_publisher, country_publisher)`

**Ключі таблиці (кандидат-ключі):**

1. `publisher_id` — первинний ключ (`PRIMARY KEY`).
2. `name_publisher` — унікальний ключ (`UNIQUE NOT NULL`).

**Функціональні залежності (ФЗ):**

- `publisher_id → name_publisher, country_publisher`
- `name_publisher → publisher_id, country_publisher`

**Оцінка початкової нормальної форми та виявлення аномалій:**

- **Початкова нормальна форма:** 3НФ формально, але країна записана текстом, через це є аномалії.
- **1НФ (виконано):** усі значення атомарні, повторюваних груп немає, є первинний ключ.
- **2НФ (виконано):** обидва ключі (`publisher_id` та `name_publisher`) складаються з одного поля, тому залежність від частини ключа неможлива.
- **Порушення 3НФ (формальне):** країна видавця зберігається текстом у стовпці `country_publisher`, так само як у таблиці `author`. Це створює ті самі аномалії вставки, оновлення, видалення і дублювання: «США» повторюється у видавців O'Reilly Media і Penguin Random House, а написання країни ніщо не контролює.

**Покрокова нормалізація:**

**Етап 1 (Перехід до 1НФ):** усі значення атомарні, змін не потрібно.

**Схема:** `publisher(PK publisher_id, UQ name_publisher, country_publisher)`

**Етап 2 (Перехід до 2НФ):** обидва ключі прості, часткових залежностей немає, змін не потрібно.

**Схема:** `publisher(PK publisher_id, UQ name_publisher, country_publisher)`

**Етап 3 (Перехід до 3НФ):** замість текстового `country_publisher` використовуємо посилання на довідник `country`, створений під час нормалізації таблиці `author`. Країна більше не зберігається текстом у `publisher`.

**Фінальна схема (3НФ):** `publisher(PK publisher_id, UQ name_publisher, FK country_id)`

**SQL-команди для зміни існуючої таблиці publisher (`ALTER TABLE`):**

```sql
ALTER TABLE publisher
    ADD COLUMN country_id INT,
    ADD CONSTRAINT fk_publisher_country
        FOREIGN KEY (country_id) REFERENCES country(country_id)
        ON DELETE RESTRICT;

UPDATE publisher p
SET country_id = c.country_id
FROM country c
WHERE c.name_country = p.country_publisher;

ALTER TABLE publisher DROP COLUMN country_publisher;
CREATE INDEX idx_publisher_country ON publisher(country_id);
```

**Перероблений SQL-скрипт створення таблиці publisher (`CREATE TABLE` у 3НФ):**

```sql
CREATE TABLE publisher (
    publisher_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name_publisher VARCHAR(100) UNIQUE NOT NULL,
    country_id INT,
    CONSTRAINT fk_publisher_country
        FOREIGN KEY (country_id) REFERENCES country(country_id)
        ON DELETE RESTRICT
);
```

---

## Таблиця category

**Початковий SQL-скрипт:**

```sql
CREATE TABLE category (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name_category VARCHAR(50) UNIQUE NOT NULL
);
```

**Схема таблиці:** `category(PK category_id, UQ name_category)`

**Ключі таблиці (кандидат-ключі):**

1. `category_id` — первинний ключ (`PRIMARY KEY`).
2. `name_category` — унікальний ключ (`UNIQUE NOT NULL`).

**Функціональні залежності (ФЗ):**

- `category_id → name_category`
- `name_category → category_id`

**Перевірка нормальних форм:**

- **Початкова нормальна форма:** 3НФ (навіть BCNF).
- **1НФ (виконано):** у таблиці всього два стовпці, і в кожній клітинці лежить одне значення. Списків і повторюваних груп немає.
- **2НФ (виконано):** первинний ключ `category_id` складається з одного стовпця, тому залежність від частини ключа неможлива.
- **3НФ (виконано):** неключовий стовпець лише один (`name_category`) і залежить тільки від ключа. Транзитивна залежність потребує двох неключових стовпців.
- **BCNF (виконано):** в обох залежностях зліва стоїть ключ, що є умовою BCNF.

**Висновок:** таблиця `category` уже перебуває у 3НФ і не потребує змін (`ALTER TABLE` не потрібен).

---

## Таблиця book

**Початковий SQL-скрипт:**

```sql
CREATE TABLE book (
    book_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    publisher_id INT NOT NULL REFERENCES publisher(publisher_id) ON DELETE RESTRICT,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    publication_year SMALLINT NOT NULL CHECK (publication_year BETWEEN -2000 AND 2100),
    price NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock_quantity SMALLINT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0)
);
```

**Схема таблиці:** `book(PK book_id, FK publisher_id, UQ isbn, title, publication_year, price, stock_quantity)`

**Ключі таблиці:**

1. `book_id` — головний ключ (`PRIMARY KEY`).
2. `isbn` — унікальний ключ (`UNIQUE NOT NULL`).

**Функціональні залежності (ФЗ):**

- `book_id → publisher_id, isbn, title, publication_year, price, stock_quantity`
- `isbn → book_id` (оскільки `isbn` унікальний, за ним теж можна однозначно знайти книгу та всі її дані).

**Перевірка нормальних форм:**

- **Початкова нормальна форма:** 3НФ.
- **1НФ (виконано):** усі стовпці містять по одному простому значенню, списків чи повторюваних груп немає.
- **2НФ (виконано):** обидва ключі (`book_id` та `isbn`) складаються з одного поля, тому залежність від частини ключа неможлива.
- **3НФ (виконано):** звичайні стовпці залежать тільки від ключів і не визначають одне одного. Залежність полів від `isbn` не порушує 3НФ, оскільки `isbn` є унікальним ключем таблиці.

**Висновок:** таблиця `book` уже перебуває у 3НФ і не потребує змін (`ALTER TABLE` не потрібен).

---

## Таблиця book_author

**Початковий SQL-скрипт:**

```sql
CREATE TABLE book_author (
    book_id INT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
    author_id INT NOT NULL REFERENCES author(author_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);
```

**Схема таблиці:** `book_author(PK, FK book_id, PK, FK author_id)`

**Функціональні залежності (ФЗ):**

- `(book_id, author_id) → book_id, author_id` (складений ключ визначає сам себе; інших залежностей немає, бо в таблиці немає неключових полів).

**Перевірка нормальних форм:**

- **Початкова нормальна форма:** 3НФ.
- **1НФ (виконано):** обидва поля зберігають прості цілі числа (`INT`), списків немає.
- **2НФ (виконано):** у таблиці немає неключових стовпців, які могли б залежати від частини складеного ключа.
- **3НФ (виконано):** немає неключових стовпців, які могли б залежати одне від одного.

**Висновок:** зв'язувальна таблиця `book_author` уже перебуває у 3НФ і не потребує змін (`ALTER TABLE` не потрібен).

---

## Таблиця book_category

**Початковий SQL-скрипт:**

```sql
CREATE TABLE book_category (
    book_id INT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
    category_id INT NOT NULL REFERENCES category(category_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, category_id)
);
```

**Схема таблиці:** `book_category(PK, FK book_id, PK, FK category_id)`

**Функціональні залежності (ФЗ):**

- `(book_id, category_id) → book_id, category_id` (складений ключ визначає сам себе; інших залежностей немає).

**Перевірка нормальних форм:**

- **Початкова нормальна форма:** 3НФ.
- **1НФ (виконано):** обидва поля зберігають прості цілі числа (`INT`), списків немає.
- **2НФ (виконано):** неключових стовпців немає, тому залежність від частини ключа неможлива.
- **3НФ (виконано):** неключових стовпців немає, тому залежність між ними неможлива.

**Висновок:** зв'язувальна таблиця `book_category` уже перебуває у 3НФ і не потребує змін (`ALTER TABLE` не потрібен).

---

## Таблиця order_item

**Початковий SQL-скрипт:**

```sql
CREATE TABLE order_item (
    order_item_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    book_id INT NOT NULL REFERENCES book(book_id) ON DELETE RESTRICT,
    quantity SMALLINT NOT NULL CHECK (quantity > 0),
    price_at_purchase NUMERIC(10,2) NOT NULL CHECK (price_at_purchase >= 0),
    CONSTRAINT uq_order_book UNIQUE (order_id, book_id)
);
```

**Схема таблиці:** `order_item(PK order_item_id, FK order_id, FK book_id, quantity, price_at_purchase)`

**Ключі таблиці:**

1. `order_item_id` — головний ключ (`PRIMARY KEY`).
2. `(order_id, book_id)` — унікальна пара (`UNIQUE (order_id, book_id)`).

**Функціональні залежності (ФЗ):**

- `order_item_id → order_id, book_id, quantity, price_at_purchase`
- `(order_id, book_id) → order_item_id` (оскільки ця пара унікальна, вона також однозначно визначає `quantity` та `price_at_purchase`).

**Перевірка нормальних форм:**

- **Початкова нормальна форма:** 3НФ.
- **1НФ (виконано):** усі стовпці містять по одному простому значенню (`INT`, `SMALLINT`, `NUMERIC`).
- **2НФ (виконано):** головний ключ `order_item_id` одинарний. Від унікальної пари `(order_id, book_id)` кількість і ціна покупки також залежать повністю (`price_at_purchase` фіксує ціну саме в момент цього замовлення, а не поточну ціну книги в каталозі).
- **3НФ (виконано):** стовпці `quantity` та `price_at_purchase` залежать лише від ключів і не визначають одне одного.

**Висновок:** таблиця `order_item` уже перебуває у 3НФ і не потребує змін (`ALTER TABLE` не потрібен).

---

## Таблиця review

**Початковий SQL-скрипт:**

```sql
CREATE TABLE review (
    review_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    book_id INT NOT NULL REFERENCES book(book_id) ON DELETE CASCADE,
    order_item_id INT REFERENCES order_item(order_item_id) ON DELETE SET NULL,
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_customer_book_review UNIQUE (customer_id, book_id)
);
```

**Схема початкової таблиці:** `review(PK review_id, FK customer_id, FK book_id, FK order_item_id, rating, comment, review_date)`

**Ключі початкової таблиці:**

1. `review_id` — головний ключ (`PRIMARY KEY`).
2. `(customer_id, book_id)` — унікальна пара (`UNIQUE (customer_id, book_id)`).

**Функціональні залежності (ФЗ) початкової схеми:**

- `review_id → customer_id, book_id, order_item_id, rating, comment, review_date`
- `(customer_id, book_id) → review_id`
- `order_item_id → book_id` (у таблиці `order_item` кожна позиція замовлення вже прив'язана до конкретної книги, що створює транзитивний ланцюжок `review_id → order_item_id → book_id`).

**Оцінка початкової нормальної форми та виявлення аномалій:**

- **Початкова нормальна форма:** 2НФ (порушує 3НФ).
- **1НФ (виконано):** усі стовпці містять по одному простому значенню, списків немає.
- **2НФ (виконано):** головний ключ `review_id` одинарний, а від унікальної пари `(customer_id, book_id)` усі інші стовпці залежать повністю.
- **Порушення 3НФ (транзитивна залежність і дублювання даних):** у таблиці одночасно зберігаються `order_item_id` та `book_id`. Але запис `order_item_id` у таблиці `order_item` уже вказує, яка саме книга була куплена (`order_item_id → book_id`). Через це виникає зайва залежність `review_id → order_item_id → book_id`. Вона призводить до аномалій вставки та оновлення: у базу можна помилково записати відгук, де `order_item_id` посилається на одну книгу, а `book_id` — на іншу.

**Покрокова нормалізація:**

**Етап 1 (Перехід до 1НФ):** змін не потрібно, усі поля вже містять прості значення.

**Схема:** `review(PK review_id, FK customer_id, FK book_id, FK order_item_id, rating, comment, review_date)`

**Етап 2 (Перехід до 2НФ):** змін не потрібно, залежностей від частини ключа немає.

**Схема:** `review(PK review_id, FK customer_id, FK book_id, FK order_item_id, rating, comment, review_date)`

**Етап 3 (Перехід до 3НФ):** видаляємо зайвий стовпець `book_id` та старе обмеження `uq_customer_book_review`. Поле `order_item_id` робимо обов'язковим (`NOT NULL`) і додаємо правило унікальності на пару `(customer_id, order_item_id)`, щоб покупець міг залишити лише один відгук на одну куплену позицію. Тепер книгу завжди можна однозначно дізнатися через таблицю `order_item`, і суперечливі дані більше не з'являться.

**Фінальна схема (3НФ):** `review(PK review_id, FK customer_id, FK order_item_id, rating, comment, review_date)`

**SQL-команди для зміни існуючої таблиці (`ALTER TABLE`):**

```sql
ALTER TABLE review DROP CONSTRAINT uq_customer_book_review;
ALTER TABLE review DROP COLUMN book_id;

ALTER TABLE review DROP CONSTRAINT review_order_item_id_fkey;
ALTER TABLE review ALTER COLUMN order_item_id SET NOT NULL;
ALTER TABLE review ADD CONSTRAINT review_order_item_id_fkey
    FOREIGN KEY (order_item_id) REFERENCES order_item(order_item_id) ON DELETE CASCADE;

ALTER TABLE review ADD CONSTRAINT uq_customer_order_item
    UNIQUE (customer_id, order_item_id);
```

**Перероблений SQL-скрипт створення таблиці (`CREATE TABLE` у 3НФ):**

```sql
CREATE TABLE review (
    review_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    order_item_id INT NOT NULL REFERENCES order_item(order_item_id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_customer_order_item UNIQUE (customer_id, order_item_id)
);
```

## Висновок

У ході лабораторної роботи було проаналізовано схему бази даних книжкового магазину, визначено функціональні залежності та виявлено порушення 2НФ і 3НФ, що спричиняли надлишковість і аномалії даних. Схему було послідовно приведено до 1НФ, 2НФ і 3НФ шляхом декомпозиції таблиць, а також створено SQL-скрипти та оновлену ER-діаграму. У результаті кожен факт зберігається лише в одному місці, що підвищило цілісність даних, хоча й збільшило кількість з'єднань у запитах.
