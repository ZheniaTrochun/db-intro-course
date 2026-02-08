# Лекція 8. Індекси

## Вступ

Індекси є ключовим інструментом оптимізації запитів у системах управління базами даних (СУБД).  
Вони дозволяють значно пришвидшити операції пошуку, сортування та вибірки даних, особливо у великих таблицях.  
Індекс - це окрема структура даних, яка зберігає копії проіндексованих значень у впорядкованому вигляді та містить посилання на відповідні рядки оригінальної таблиці.

---

## 1. Призначення індексів

Індекс - це допоміжна структура даних, призначена для оптимізації виконання запитів.  
Він дозволяє уникати повного сканування таблиці (Full Table Scan) і натомість швидко знаходити потрібні рядки.

### Основні властивості:
- Індекси зберігаються окремо від таблиці, але синхронізуються з нею.
- Кожен елемент індекса містить:
  - значення ключа (наприклад, значення колонки `name`),
  - посилання на відповідний рядок у таблиці.
- Індекси можуть створюватися, оновлюватися або видалятися незалежно від таблиць.

### Загальна дуже спрощена структура індекса:
| Значення ключа | Посилання на рядок |
|-----------------|--------------------|
| 'Anna'          | Row #105           |
| 'Bohdan'        | Row #220           |
| 'Kateryna'      | Row #315           |

---

## 2. Типи індексів

### 2.1. B-Tree Index

B-Tree (Balanced Tree) - найбільш розповсюджений тип індекса.  
Він зберігає дані у впорядкованому вигляді у збалансованому дереві, що містить багато нащадків у кожному вузлі (зазвичай до 256 нащадків).  

Підтримувані операції:
- `=` - рівність
- `>`, `<`, `BETWEEN` - порівняння
- `LIKE 'abc%'` - пошук за префіксом
- `ORDER BY` - сортування

Приклад створення:
```sql
CREATE INDEX idx_courses_name 
ON course (name);
```

Переваги:
- універсальний тип, використовується за замовчуванням
- підходить для більшості запитів SELECT
- підтримує порівняння та сортування


####  Структура B-Tree

B-Tree складається з вершин двох основних типів:

1. Branch nodes (проміжні вузли) - зберігають проміжні ключі, які визначають діапазони значень у дочірніх вузлах, та вказівники на нижчі рівні.
2. Leaf nodes (листові вузли) - містять реальні значення ключів, посилання на рядки таблиці та посилання на сусідні листи.

Кожна вершина дерева має впорядковані ключі та B-Tree завжди залишається збалансованим, тобто відстань від кореня до будь-якого листка відрізняється не більше ніж на 1.

Кожен вузол зазвичай займає 8 КБ (типовий розмір сторінки у PostgreSQL), і може містити сотні ключів.  
Завдяки великій кількості нащадків кожного вузла, навіть для таблиць з мільйонами записів, висота дерева зазвичай не перевищує 3–4 рівні, що гарантує швидкий пошук — O(log n).

#### Більше інформації про B-Tree можна знайти за посиланнями
[use-the-index-luke.com/sql/anatomy/the-leaf-nodes](https://use-the-index-luke.com/sql/anatomy/the-leaf-nodes)
[use-the-index-luke.com/sql/anatomy/the-tree](https://use-the-index-luke.com/sql/anatomy/the-tree)


---

### 2.2. Hash Index

Hash-індекси побудовані на основі хеш-таблиць.  
Вони використовуються виключно для перевірки рівності (`=`).  
Не підходять для порівнянь (`>`, `<`), сортування або пошуку за префіксом.

```sql
CREATE INDEX idx_user_hash 
ON users USING HASH (email);
```

Перевага: працює дещо швидше ніж B-Tree для операцій рівності.  
Недолік: обмежений функціонал.

---

### 2.3. Спеціалізовані індекси

- GiST (Generalized Search Tree) - для геометричних і геолокаційних даних.
- GIN (Generalized Inverted Index) - для JSON, масивів, повнотекстового пошуку.
- SP-GiST, BRIN - для специфічних типів даних або великих послідовних таблиць.

---

## 3. Створення індекса

Індекс створюється за допомогою команди `CREATE INDEX`.

```sql
CREATE INDEX idx_active_courses_by_name 
ON course (name) 
WHERE is_active = true;
```

Тут:
- `idx_active_courses_by_name` - ім'я індекса
- `course` - таблиця
- `(name)` - колонка для індексації
- `WHERE is_active = true` - предикат (умова для часткового індекса)

---

## 4. Часткові індекси (Partial Indexes)

Частковий індекс створюється лише для підмножини рядків таблиці, які відповідають певній умові.  
Це дозволяє економити пам'ять та не індексувати дані, які не використовуються для запитів.

```sql
CREATE INDEX idx_active_courses_by_name 
ON course (name) 
WHERE is_active = true;
```

### Пояснення:
- Індекс міститиме лише ті курси, де `is_active = true`.
- Запит без предиката `is_active = true` НЕ використовуватиме індекс:
```sql
SELECT * FROM course WHERE name = 'Бази даних'; -- індекс не використовується
SELECT * FROM course WHERE name = 'Бази даних' AND is_active = true; -- індекс використовується
```

### Переваги часткових індексів:
- Зменшують використання пам'яті
- Менше дублювання даних
- Підвищення ефективності для частих умов фільтрації

---

## 5. Композитні індекси (Composite Indexes)

Індекси, створені для кількох колонок одночасно.  

```sql
CREATE INDEX idx_some_name 
ON some_table (col1, col2, col3);
```

Ефективні запити:
```sql
SELECT * FROM some_table WHERE col1 = ?;
SELECT * FROM some_table WHERE col1 = ? AND col2 = ?;
SELECT * FROM some_table WHERE col1 = ? AND col2 = ? AND col3 = ?;
```

НЕ ефективні:
```sql
SELECT * FROM some_table WHERE col2 = ?;
SELECT * FROM some_table WHERE col3 = ?;
```

### Оптимальний порядок колонок в композитному індексі:
1. Колонки з умовами рівності (`=`) - на початку.
2. Колонки з порівняннями (`>`, `<`) - наприкінці.
3. Колонки з більшою кардинальністю (кількістю унікальних значень) - на початку.

---

## 6. Переваги та недоліки індексів

### Переваги:
- Підвищення швидкодії SELECT-запитів (пошуку за ключами)
- Оптимізація сортування (`ORDER BY`) та об'єднань (`JOIN`)

### Недоліки:
- Займають додаткову пам'ять
- Сповільнюють `INSERT`, `UPDATE`, `DELETE`, бо кожна зміна в таблиці потребує оновлення індекса
- Можуть потребувати періодичного обслуговування (VACUUM, REINDEX)

---

## 7. Коли індекси шкідливі

### При великій кількості записів (Write-heavy workload)
Кожен `INSERT` провокує фізичні записи на диск:
1. Запис даних у таблицю
2. Оновлення індекса первинного ключа (`PRIMARY KEY`)
3. Оновлення всіх інших індексів

Таким чином, один логічний запис (`INSERT`) може породити 3+ фізичні записи на диск.

### При частих оновленнях проіндексованих колонок
У PostgreSQL при оновленні рядка створюється нова версія (механізм MVCC).  
В індексі стара версія позначається як *мертва (dead tuple)*, а нова додається.  
Це призводить до явища "index bloat" - роздування індекса. PostgreSQL усуває його через фоновий процес `AUTOVACUUM`.

### При низькій кардинальності колонки
Якщо колонка має мало унікальних значень (наприклад, `is_active`), індекс неефективний, бо:
- Пошуки за індексом -> багато випадкових доступів до даних на диску (random I/O)
- Пошуки без використання індексу -> повне сканування даних таблиці (sequential I/O).

Sequential I/O завжди швидше ніж random I/O. Навіть якщо обʼєм даних, що вичитується, у 3-4 рази більший - sequential I/O всеодно може бути швидше. 

**PostgreSQL самостійно вирішує, коли використовувати, а коли не використовувати індекс.**

---

## 8. Аналіз плану запиту

Для того, щоб зрозуміти, чому запит повільний - потрібно проглянути план його виконання.

### Команди:
```sql
EXPLAIN SELECT * FROM course WHERE name = 'Бази даних';
EXPLAIN ANALYZE SELECT * FROM course WHERE name = 'Бази даних';
```

### Типи сканування:
| Тип | Опис                                                                                                             | Швидкодія                                           |
|------|------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|
| Seq Scan | Повне сканування таблиці.                                                                                        | Добре для малих таблиць. Дуже повільно для великих. |
| Index Scan | Пошук по індексу, потім читання рядків з таблиці.                                                                | Швидко.                                             |
| Index Only Scan | Читання лише з індекса (якщо всі дані у ньому).                                                                  | Найшвидший варіант.                                 |
| Bitmap Index Scan | Комбіноване використання кількох індексів. Читання індексу для підготовки до швидкого сканування всієї таблички. | Повільніше ніж Index Scan                           |

---

## 9. Практичні поради використання індексів

### Варто:
- Створювати індекси, коли ефективність SELECT-запитів критична
- Створювати індекси для `FOREIGN KEY`
- Індексувати колонки, які часто використовуються у `WHERE`, `JOIN`, `ORDER BY`
- Використовувати часткові індекси для умов, які часто повторюються (наприклад, `is_active = true` для soft deletion)

### Не варто:
- Індексувати всі колонки "про всяк випадок"
- Створювати надлишкові індекси (якщо є `idx(a,b,c)` - то `idx(a,b)` зайвий)
- Індексувати колонки, що часто оновлюються
- Індексувати колонки з низькою варіативністю (наприклад, `is_active`)
- Створювати індекси для запитів, які повертають >20% таблиці - послідовно прочитати всі дані з таблиці буде швидше
- Використовувати `SELECT *`, бо це у більшості випадків унеможливлює `Index Only Scan`

### Важливо:
Перед і після додавання індекса перевіряйте ефективність за допомогою:
```sql
EXPLAIN ANALYSE <запит>;
```

Іноді використання індексу не прискорює запит, а навпаки - сповільнює його. Такі індекси варто видаляти, адже вони повністю шкідливі.

---

## 10. Підсумки

- Індекси - критично важливий інструмент підвищення продуктивності баз даних.  
- Основний тип - B-Tree, універсальний і використовується найчастіше.  
- Hash-індекси швидкі, але обмежені у функціональності.  
- Часткові індекси допомагають економити ресурси при частих патернах фільтрацій.  
- Композитні індекси ефективні для запитів за кількома полями.  
- Важливо збалансовано використовувати індекси, враховуючи швидкодію та витрати пам'яті.
- Планувальник PostgreSQL самостійно вирішує, коли використовувати, а коли не використовувати індекс.

---

## 11. Практична частина лекції

Для демонстрації, було підготовано 2 набори табличок та згенеровано синтетичні дані.

```sql
--------------------------------------------------------------------------------------------------
-- Example 1
--------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS books (
                                   id SERIAL PRIMARY KEY,
                                   title VARCHAR(255) NOT NULL,
  isbn VARCHAR(13) UNIQUE,
  author VARCHAR(100),
  publisher VARCHAR(100),
  publication_year INTEGER,
  genre VARCHAR(50),
  pages INTEGER,
  available_copies INTEGER DEFAULT 0
  );

CREATE TABLE IF NOT EXISTS members (
                                     id SERIAL PRIMARY KEY,
                                     email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  membership_type VARCHAR(20) CHECK (membership_type IN ('student', 'faculty', 'public')),
  join_date DATE DEFAULT CURRENT_DATE,
  is_active BOOLEAN DEFAULT true,
  late_fees DECIMAL(10,2) DEFAULT 0
  );

CREATE TABLE IF NOT EXISTS loans (
                                   id SERIAL PRIMARY KEY,
                                   book_id INTEGER NOT NULL REFERENCES books(id),
  member_id INTEGER NOT NULL REFERENCES members(id),
  loan_date DATE NOT NULL DEFAULT CURRENT_DATE,
  due_date DATE NOT NULL,
  return_date DATE,
  status VARCHAR(20) CHECK (status IN ('active', 'returned', 'overdue')) DEFAULT 'active'
  );

-- 50,000 books
INSERT INTO books (title, isbn, author, publisher, publication_year, genre, pages, available_copies)
SELECT
  'Book Title ' || i,
  LPAD(i::text, 13, '0'),
  'Author ' || (random() * 1000)::int,
  'Publisher ' || (random() * 100)::int,
  1950 + (random() * 75)::int,
  (ARRAY['Fiction', 'Non-Fiction', 'Science', 'History', 'Biography', 'Mystery', 'Romance', 'Thriller'])[1 + (random() * 7)::int],
    100 + (random() * 900)::int,
    (random() * 10)::int
FROM generate_series(1, 50000) i;

-- 100,000 members
INSERT INTO members (email, full_name, membership_type, join_date, is_active, late_fees)
SELECT
  'member' || i || '@email.com',
  'Member ' || i,
  (ARRAY['student', 'faculty', 'public'])[1 + (random() * 2)::int],
    CURRENT_DATE - (random() * 1825)::int,
    random() > 0.1, -- 90% active
    CASE WHEN random() > 0.8 THEN (random() * 50)::decimal(10,2) ELSE 0 END
FROM generate_series(1, 100000) i;

-- 500,000 loans (mix of 20% active, 40% returned, 40% overdue)
INSERT INTO loans (book_id, member_id, loan_date, due_date, return_date, status)
SELECT
  1 + (random() * 49999)::int,
  1 + (random() * 99999)::int,
  CURRENT_DATE - (random() * 365)::int,
  CURRENT_DATE - (random() * 365)::int + 14,
  CASE
    WHEN random() > 0.2 THEN CURRENT_DATE - (random() * 300)::int
        ELSE NULL
END,
    CASE
        WHEN random() > 0.8 THEN 'active'
        WHEN random() > 0.6 THEN 'overdue'
        ELSE 'returned'
END
FROM generate_series(1, 500000) i;


--------------------------------------------------------------------------------------------------
-- Example 2
--------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS customers (
                                       id SERIAL PRIMARY KEY,
                                       email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(100),
  country VARCHAR(2), -- ISO country code
  registration_date TIMESTAMP DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  total_orders INTEGER DEFAULT 0
  );

CREATE TABLE IF NOT EXISTS products (
                                      id SERIAL PRIMARY KEY,
                                      sku VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(50),
  subcategory VARCHAR(50),
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INTEGER DEFAULT 0,
  is_published BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
  );

CREATE TABLE IF NOT EXISTS orders (
                                    id SERIAL PRIMARY KEY,
                                    customer_id INTEGER NOT NULL REFERENCES customers(id),
  order_date TIMESTAMP DEFAULT NOW(),
  status VARCHAR(20) CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')) DEFAULT 'pending',
  total_amount DECIMAL(10,2) NOT NULL,
  shipping_country VARCHAR(2),
  payment_method VARCHAR(20)
  );

CREATE TABLE IF NOT EXISTS order_items (
                                         id SERIAL PRIMARY KEY,
                                         order_id INTEGER NOT NULL REFERENCES orders(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  discount_percent DECIMAL(5,2) DEFAULT 0
  );

-- 200,000
INSERT INTO customers (email, full_name, country, registration_date, is_active)
SELECT
  'customer' || i || '@shop.com',
  'Customer ' || i,
  (ARRAY['US', 'UK', 'CA', 'DE', 'FR', 'JP', 'AU'])[1 + (random() * 6)::int],
    NOW() - ((random() * 730)::int || ' days')::interval,
    random() > 0.05
FROM generate_series(1, 200000) i;

-- 100,000
INSERT INTO products (sku, name, category, subcategory, price, stock_quantity, is_published)
SELECT
  'SKU-' || LPAD(i::text, 8, '0'),
  'Product ' || i,
  (ARRAY['Electronics', 'Clothing', 'Books', 'Home', 'Sports', 'Toys'])[1 + (random() * 5)::int],
    'Subcategory ' || (random() * 20)::int,
    (random() * 1000 + 10)::decimal(10,2),
    (random() * 1000)::int,
    random() > 0.1
FROM generate_series(1, 100000) i;

-- 2,000,000
INSERT INTO orders (customer_id, order_date, status, total_amount, shipping_country, payment_method)
SELECT
  1 + (random() * 199999)::int,
  NOW() - ((random() * 365)::int || ' days')::interval,
    (ARRAY['pending', 'processing', 'shipped', 'delivered', 'cancelled'])[
        CASE
            WHEN random() < 0.05 THEN 1 -- 5% pending
            WHEN random() < 0.10 THEN 2 -- 5% processing
            WHEN random() < 0.20 THEN 3 -- 10% shipped
            WHEN random() < 0.90 THEN 4 -- 70% delivered
            ELSE 5                       -- 10% cancelled
END
],
    (random() * 500 + 20)::decimal(10,2),
    (ARRAY['US', 'UK', 'CA', 'DE', 'FR', 'JP', 'AU'])[1 + (random() * 6)::int],
    (ARRAY['credit_card', 'paypal', 'bank_transfer'])[1 + (random() * 2)::int]
FROM generate_series(1, 2000000) i;

-- 5,000,000
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_percent)
SELECT
  1 + (random() * 1999999)::int,
  1 + (random() * 99999)::int,
  1 + (random() * 5)::int,
  (random() * 500 + 10)::decimal(10,2),
  (ARRAY[0, 0, 0, 5, 10, 15, 20])[1 + (random() * 6)::int]
FROM generate_series(1, 5000000) i;
```

На основі даних таблиць та даних, було проаналізовано план виконання SQL запитів:

```sql
--------------------------------------------------------------------------------------------------
-- Example 1
--------------------------------------------------------------------------------------------------

EXPLAIN ANALYSE SELECT * FROM books WHERE isbn = '0000000012345';

EXPLAIN ANALYSE SELECT * FROM loans WHERE member_id = 1234 AND status = 'active';

EXPLAIN ANALYSE SELECT * FROM books WHERE author LIKE 'Author 5%';

EXPLAIN ANALYSE SELECT l.*, m.full_name
FROM loans l
         JOIN members m ON l.member_id = m.id
WHERE m.is_active = true
  AND l.loan_date > CURRENT_DATE - INTERVAL '30 days';

EXPLAIN ANALYSE
SELECT * FROM books
WHERE genre = 'Fiction'
  AND available_copies > 0
ORDER BY publication_year DESC
LIMIT 20;


--------------------------------------------------------------------------------------------------
-- Example 2
--------------------------------------------------------------------------------------------------

EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 12345
ORDER BY order_date DESC
  LIMIT 20;

EXPLAIN ANALYZE
SELECT o.*, c.email, c.full_name
FROM orders o
       JOIN customers c ON o.customer_id = c.id
WHERE o.status IN ('pending', 'processing')
  AND o.order_date > NOW() - INTERVAL '7 days';

EXPLAIN ANALYZE
SELECT * FROM products
WHERE category = 'Electronics'
  AND is_published = true
  AND stock_quantity > 0
ORDER BY price ASC
  LIMIT 50;

EXPLAIN ANALYSE
SELECT c.email, c.full_name, COUNT(o.id) as order_count, SUM(o.total_amount) as total_spent
FROM customers c
       JOIN orders o ON o.customer_id = c.id
WHERE o.status = 'delivered'
  AND o.order_date > NOW() - INTERVAL '90 days'
GROUP BY c.id, c.email, c.full_name
ORDER BY order_count DESC
  LIMIT 100;

EXPLAIN ANALYZE
SELECT p.*, COUNT(oi.id) as times_ordered
FROM products p
       JOIN order_items oi ON p.id = oi.product_id
       JOIN orders o ON oi.order_id = o.id
WHERE o.status = 'delivered'
  AND o.order_date > NOW() - INTERVAL '30 days'
GROUP BY p.id
ORDER BY times_ordered DESC
  LIMIT 20;
```

На основі аналізу запитів було створено індекси, що роблять наведені запити значно ефективнішими.

```sql
--------------------------------------------------------------------------------------------------
-- Example 1
--------------------------------------------------------------------------------------------------

CREATE INDEX idx_loans_member_id_status ON loans(member_id, status);

CREATE INDEX idx_books_author ON books(author text_pattern_ops);

CREATE INDEX idx_loans_loan_date ON loans(loan_date);

CREATE INDEX idx_books_genre_publication_year ON books(genre, publication_year);
    

--------------------------------------------------------------------------------------------------
-- Example 2
--------------------------------------------------------------------------------------------------

CREATE INDEX idx_orders_customer_id_order_date ON orders(customer_id, order_date);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

CREATE INDEX idx_orders_order_date_status ON orders(order_date, status);

CREATE INDEX idx_products_category_stock_quantity ON products(category, price, stock_quantity) where is_published = true;
```

Всі запити також можна знайти у [файлі](../../scripts/indices.sql).

---

## Додаткові матеріали

[Use The Index, Luke! (SQL Indexing and Tuning e-Book)](https://use-the-index-luke.com)
[Sequential I/O vs Random I/O](https://storedbits.com/sequential-vs-random-data/)
[Bit Map Index Scan](https://gelovolro.medium.com/what-is-a-bitmap-scan-in-postgresql-4d4876003cda)

Утилітарні запити для отримання розміру індексів та таблиць:
```sql
-- Get size of all tables in current database
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS indexes_size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Get detailed index information with sizes
SELECT
    t.tablename,
    i.indexname,
    pg_size_pretty(pg_relation_size(quote_ident(i.schemaname)||'.'||quote_ident(i.indexname))) AS index_size,
    idx.indisunique AS is_unique,
    idx.indisprimary AS is_primary,
    array_to_string(array_agg(a.attname), ', ') AS column_names
FROM pg_tables t
JOIN pg_indexes i ON t.tablename = i.tablename
JOIN pg_class c ON i.indexname = c.relname
JOIN pg_index idx ON c.oid = idx.indexrelid
JOIN pg_attribute a ON a.attrelid = idx.indrelid AND a.attnum = ANY(idx.indkey)
WHERE t.schemaname = 'public'
GROUP BY t.tablename, i.indexname, quote_ident(i.schemaname)||'.'||quote_ident(i.indexname), idx.indisunique, idx.indisprimary
ORDER BY pg_relation_size(quote_ident(i.schemaname)||'.'||quote_ident(i.indexname)) DESC;
```
