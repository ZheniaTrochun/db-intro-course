# Лабораторна робота №2 - Перетворення ER-діаграми на схему PostgreSQL

**Предметна область:** інтернет-магазин комп'ютерних комплектуючих (PC Components Store)  
**Студентка:** Мосендз Белла  
**Група:** ІМ-о51

## Мета роботи

Перетворити ER-діаграму, створену в лабораторній №1, на реляційну схему PostgreSQL: визначити типи даних, первинні та зовнішні ключі, обмеження цілісності; заповнити кожну таблицю тестовими записами та перевірити результат SQL-запитами

## SQL-файли та порядок виконання

1. [`01_create_tables.sql`](01_create_tables.sql) створює вісім таблиць і обмеження (DDL)
2. [`02_insert_data.sql`](02_insert_data.sql) заповнює всі таблиці прикладами (INSERT INTO)
3. [`03_verify.sql`](03_verify.sql) перевіряє структуру, кількість записів, зв'язки та обмеження (SELECT)

## Структура таблиць

Позначення: **PK** - первинний ключ; **FK** - зовнішній ключ; **UQ** - унікальне значення; **NULL** - допускається відсутність значення

### 1. `customer` - покупці

| Стовпець | Тип | Ключі та обмеження |
|---|---|---|
| `customer_id` | `INTEGER` (IDENTITY) | **PK** |
| `full_name` | `VARCHAR(120)` | `NOT NULL` |
| `email` | `VARCHAR(255)` | **UQ**, `NOT NULL` |
| `phone` | `VARCHAR(30)` | `NULL` |
| `registered_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` |

### 2. `category` - категорії товарів

| Стовпець | Тип | Ключі та обмеження |
|---|---|---|
| `category_id` | `INTEGER` (IDENTITY) | **PK** |
| `name` | `VARCHAR(100)` | **UQ**, `NOT NULL` |
| `description` | `TEXT` | `NULL` |

### 3. `product` - товари

| Стовпець | Тип | Ключі та обмеження |
|---|---|---|
| `product_id` | `INTEGER` (IDENTITY) | **PK** |
| `sku` | `VARCHAR(40)` | **UQ**, `NOT NULL` |
| `name` | `VARCHAR(180)` | `NOT NULL` |
| `description` | `TEXT` | `NULL` |
| `current_price` | `NUMERIC(10,2)` | `NOT NULL`, `CHECK (current_price >= 0)` |
| `stock_quantity` | `INTEGER` | `NOT NULL`, `DEFAULT 0`, `CHECK (stock_quantity >= 0)` |
| `is_active` | `BOOLEAN` | `NOT NULL`, `DEFAULT TRUE` |

`sku` - артикул товару. Перевірку залишку додано окремим оператором `ALTER TABLE`.

### 4. `customer_order` - замовлення

| Стовпець | Тип | Ключі та обмеження |
|---|---|---|
| `order_id` | `INTEGER` (IDENTITY) | **PK** |
| `customer_id` | `INTEGER` | **FK** → `customer.customer_id`, `NOT NULL` |
| `ordered_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` |
| `status` | `VARCHAR(20)` | `NOT NULL`, `DEFAULT 'new'`, `CHECK` переліку статусів |
| `delivery_address` | `VARCHAR(255)` | `NOT NULL` |
| `delivery_city` | `VARCHAR(100)` | `NOT NULL` |

Дозволені статуси замовлення: `new`, `paid`, `shipped`, `delivered`, `cancelled`.

### 5. `order_item` - товарні позиції замовлення

| Стовпець | Тип | Ключі та обмеження |
|---|---|---|
| `order_id` | `INTEGER` | **PK (частина)**, **FK** → `customer_order.order_id` |
| `product_id` | `INTEGER` | **PK (частина)**, **FK** → `product.product_id` |
| `quantity` | `INTEGER` | `NOT NULL`, `CHECK (quantity > 0)` |
| `unit_price` | `NUMERIC(10,2)` | `NOT NULL`, `CHECK (unit_price >= 0)` |

Складений первинний ключ **(`order_id`, `product_id`)** не дозволяє повторити той самий товар окремим рядком у межах одного замовлення. `unit_price` зберігає ціну на момент покупки, незалежно від подальших змін `product.current_price`.

### 6. `product_category` - зв'язок товарів із категоріями

| Стовпець | Тип | Ключі та обмеження |
|---|---|---|
| `product_id` | `INTEGER` | **PK (частина)**, **FK** → `product.product_id` |
| `category_id` | `INTEGER` | **PK (частина)**, **FK** → `category.category_id` |

Складений первинний ключ **(`product_id`, `category_id`)** гарантує унікальність пари товар–категорія. Ця таблиця разом із `order_item` реалізує зв'язки M:N через два зв'язки 1:N.

### 7. `payment` - платежі / спроби оплати

| Стовпець | Тип | Ключі та обмеження |
|---|---|---|
| `payment_id` | `INTEGER` (IDENTITY) | **PK** |
| `order_id` | `INTEGER` | **FK** → `customer_order.order_id`, `NOT NULL` |
| `amount` | `NUMERIC(10,2)` | `NOT NULL`, `CHECK (amount > 0)` |
| `method` | `VARCHAR(30)` | `NOT NULL`, `CHECK` способів оплати |
| `status` | `VARCHAR(20)` | `NOT NULL`, `CHECK` статусів |
| `paid_at` | `TIMESTAMPTZ` | `NULL`; заповнений для статусу `completed` |

Способи: `card`, `bank_transfer`, `cash_on_delivery`. Статуси: `pending`, `failed`, `completed`. Оскільки одне замовлення може мати повторні спроби оплати, `payment.order_id` не є `UNIQUE`.

### 8. `shipment` - доставки

| Стовпець | Тип | Ключі та обмеження |
|---|---|---|
| `shipment_id` | `INTEGER` (IDENTITY) | **PK** |
| `order_id` | `INTEGER` | **FK** → `customer_order.order_id`, **UQ**, `NOT NULL` |
| `carrier` | `VARCHAR(100)` | `NOT NULL` |
| `tracking_number` | `VARCHAR(100)` | **UQ**, `NULL` |
| `status` | `VARCHAR(20)` | `NOT NULL`, `CHECK` статусів |
| `shipped_at` | `TIMESTAMPTZ` | `NULL` |
| `delivered_at` | `TIMESTAMPTZ` | `NULL`; `CHECK` послідовності дат |

Статуси: `created`, `shipped`, `delivered`. `UNIQUE` для `order_id` обмежує модель **не більше однією доставкою на замовлення**.

## Відповідність зв'язкам ER-діаграми

- `customer` 1 → 0..N `customer_order`: FK `customer_order.customer_id`.
- `customer_order` 1 → 1..N `order_item`: FK `order_item.order_id`.
- `product` 1 → 0..N `order_item`: FK `order_item.product_id`.
- `product` 1 → 1..N `product_category`: FK `product_category.product_id`.
- `category` 1 → 0..N `product_category`: FK `product_category.category_id`.
- `customer_order` 1 → 0..N `payment`: FK `payment.order_id`.
- `customer_order` 1 → 0..1 `shipment`: FK `shipment.order_id` із `UNIQUE`.

## Обмеження та припущення

1. Ціни та суми не можуть бути від'ємними; сума платежу й кількість товару в замовленні мають бути більшими за нуль
2. Один email позначає одного покупця; SKU товару й назва категорії є унікальними
3. У замовленні зберігається адреса на момент оформлення та історична ціна кожної позиції
4. Модель підтримує декілька спроб оплати, але лише одну доставку на замовлення

## Висновок

ER-модель інтернет-магазину перенесено в реляційну схему PostgreSQL з 8 таблиць. Для кожної таблиці обрано типи даних і первинний ключ; реалізовано зовнішні ключі, складені ключі таблиць сполучення, а також обмеження `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`. Підготовлено тестові дані та перевірочні SQL-запити
