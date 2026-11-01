# Лабораторна робота №2
## Перетворення ER-діаграми на схему PostgreSQL

**Тема:** Інтернет-магазин.

**Виконали, група ІМ-51:**
- Брижниченко Злата Володимирівна;
- Дмитрієнко Вікторія Андріївна;
- Бескровна Олександра Вікторівна.

## 1. Мета роботи

Перетворити ER-модель інтернет-магазину з лабораторної роботи №1
на реляційну схему PostgreSQL: створити таблиці, визначити типи
даних, ключі та обмеження, додати тестові дані й перевірити
коректність роботи бази.

## Предметна область

Магазин веде каталог товарів, зберігає адреси покупців, склад замовлень, платежі та відгуки.

## Структура бази даних

### `customer`

Клієнти магазину.

| Поле | Тип | Обмеження |
|---|---|---|
| `customer_id` | `INTEGER` | `GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `first_name` | `VARCHAR(100)` | `NOT NULL CHECK (btrim(first_name) <> '')` |
| `last_name` | `VARCHAR(100)` | `NOT NULL CHECK (btrim(last_name) <> '')` |
| `email` | `VARCHAR(254)` | `NOT NULL UNIQUE CHECK (btrim(email) <> '')` |
| `phone` | `VARCHAR(30)` | Необов’язкове поле |
| `registered_at` | `TIMESTAMP` | `NOT NULL DEFAULT CURRENT_TIMESTAMP` |

### `address`

Адреси доставки клієнтів.

| Поле | Тип | Обмеження |
|---|---|---|
| `address_id` | `INTEGER` | `GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `customer_id` | `INTEGER` | `NOT NULL` |
| `city` | `VARCHAR(100)` | `NOT NULL CHECK (btrim(city) <> '')` |
| `street` | `VARCHAR(150)` | `NOT NULL CHECK (btrim(street) <> '')` |
| `building` | `VARCHAR(20)` | `NOT NULL CHECK (btrim(building) <> '')` |
| `postal_code` | `VARCHAR(20)` | `NOT NULL CHECK (btrim(postal_code) <> '')` |

- `FOREIGN KEY (customer_id) REFERENCES customer (customer_id)`

- `UNIQUE (address_id, customer_id)`

### `category`

Категорії товарів.

| Поле | Тип | Обмеження |
|---|---|---|
| `category_id` | `INTEGER` | `GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `name` | `VARCHAR(100)` | `NOT NULL UNIQUE CHECK (btrim(name) <> '')` |
| `description` | `TEXT` | Необов’язкове поле |

### `product`

Товари магазину.

| Поле | Тип | Обмеження |
|---|---|---|
| `product_id` | `INTEGER` | `GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `category_id` | `INTEGER` | `NOT NULL` |
| `name` | `VARCHAR(150)` | `NOT NULL CHECK (btrim(name) <> '')` |
| `description` | `TEXT` | Необов’язкове поле |
| `price` | `NUMERIC(10, 2)` | `NOT NULL CHECK (price > 0)` |
| `stock_qty` | `INTEGER` | `NOT NULL DEFAULT 0 CHECK (stock_qty >= 0)` |

- `FOREIGN KEY (category_id) REFERENCES category (category_id)`

### `orders`

Замовлення клієнтів.

| Поле | Тип | Обмеження |
|---|---|---|
| `order_id` | `INTEGER` | `GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `customer_id` | `INTEGER` | `NOT NULL` |
| `address_id` | `INTEGER` | `NOT NULL` |
| `order_date` | `TIMESTAMP` | `NOT NULL DEFAULT CURRENT_TIMESTAMP` |
| `status` | `VARCHAR(20)` | `NOT NULL DEFAULT 'new' CHECK (status IN ( 'new', 'paid', 'shipped', 'delivered', 'cancelled' ))` |

- `FOREIGN KEY (customer_id) REFERENCES customer (customer_id)`

- `FOREIGN KEY (address_id, customer_id) REFERENCES address (address_id, customer_id)`

### `order_item`

Товари, що входять до замовлення.

| Поле | Тип | Обмеження |
|---|---|---|
| `order_id` | `INTEGER` | `NOT NULL` |
| `product_id` | `INTEGER` | `NOT NULL` |
| `quantity` | `INTEGER` | `NOT NULL CHECK (quantity >= 1)` |
| `unit_price` | `NUMERIC(10, 2)` | `NOT NULL CHECK (unit_price > 0)` |

- `PRIMARY KEY (order_id, product_id)`

- `FOREIGN KEY (order_id) REFERENCES orders (order_id)`

- `FOREIGN KEY (product_id) REFERENCES product (product_id)`

### `payment`

Платежі за замовленнями.

| Поле | Тип | Обмеження |
|---|---|---|
| `payment_id` | `INTEGER` | `GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `order_id` | `INTEGER` | `NOT NULL` |
| `amount` | `NUMERIC(10, 2)` | `NOT NULL CHECK (amount > 0)` |
| `method` | `VARCHAR(20)` | `NOT NULL CHECK (method IN ('card', 'bank_transfer', 'cash'))` |
| `paid_at` | `TIMESTAMP` | Обов’язкове для `successful`; для `pending` і `failed` — `NULL` |
| `status` | `VARCHAR(20)` | `NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'successful', 'failed'))` |

- `FOREIGN KEY (order_id) REFERENCES orders (order_id)`

- `CHECK ( (status = 'successful' AND paid_at IS NOT NULL) OR (status IN ('pending', 'failed') AND paid_at IS NULL) )`

### `review`

Відгуки клієнтів про товари.

| Поле | Тип | Обмеження |
|---|---|---|
| `review_id` | `INTEGER` | `GENERATED ALWAYS AS IDENTITY PRIMARY KEY` |
| `customer_id` | `INTEGER` | `NOT NULL` |
| `product_id` | `INTEGER` | `NOT NULL` |
| `rating` | `INTEGER` | `NOT NULL CHECK (rating BETWEEN 1 AND 5)` |
| `comment` | `TEXT` | Необов’язкове поле |
| `created_at` | `TIMESTAMP` | `NOT NULL DEFAULT CURRENT_TIMESTAMP` |

- `FOREIGN KEY (customer_id) REFERENCES customer (customer_id)`

- `FOREIGN KEY (product_id) REFERENCES product (product_id)`

- `UNIQUE (customer_id, product_id)`

## Основні обмеження

- Замовлення можна оформити лише на адресу самого покупця:
  пара (address_id, customer_id) у orders має відповідати запису в address.
- Один товар може бути в замовленні лише в одній позиції.
  Це забезпечує первинний ключ (order_id, product_id) у order_item.
  Кількість одиниць зберігається в quantity і має бути не меншою за 1.
- Ціна товару має бути більшою за нуль, а залишок на складі може бути нульовим,
  але не від’ємним.
- Для успішного платежу paid_at обов’язкове. Для платежів зі статусом
  pending або failed це поле має бути NULL.
- Покупець може залишити лише один відгук на конкретний товар.
  Оцінка має бути від 1 до 5.

## Тестові дані

seed.sql додає 5 клієнтів, 6 адрес, 5 категорій, 7 товарів, 5 замовлень, 8 позицій замовлень, 8 платежів і 5 відгуків.

## Запуск і перевірка в pgAdmin

1. Створити нову порожню базу й відкрити для неї Query Tool.
2. Виконати [schema.sql](./schema.sql), щоб створити таблиці.
3. Один раз виконати [seed.sql](./seed.sql), щоб додати дані.
4. У Query Tool виконати наведені нижче запити по одному та переглянути записи кожної таблиці у вкладці Data Output.

```sql
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM category;
SELECT * FROM product;
SELECT * FROM orders;
SELECT * FROM order_item;
SELECT * FROM payment;
SELECT * FROM review;
```