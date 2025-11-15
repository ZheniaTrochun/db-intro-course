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

EXPLAIN ANALYSE SELECT * FROM books WHERE isbn = '0000000012345';

EXPLAIN ANALYSE SELECT * FROM loans WHERE member_id = 1234 AND status = 'active';

CREATE INDEX idx_loans_member_id_status ON loans(member_id, status);

EXPLAIN ANALYSE SELECT * FROM books WHERE author LIKE 'Author 5%';

CREATE INDEX idx_books_author ON books(author text_pattern_ops);

EXPLAIN ANALYSE SELECT l.*, m.full_name
FROM loans l
         JOIN members m ON l.member_id = m.id
WHERE m.is_active = true
  AND l.loan_date > CURRENT_DATE - INTERVAL '30 days';

CREATE INDEX idx_loans_loan_date ON loans(loan_date);

EXPLAIN ANALYSE
SELECT * FROM books
WHERE genre = 'Fiction'
  AND available_copies > 0
ORDER BY publication_year DESC
LIMIT 20;

CREATE INDEX idx_books_genre_publication_year ON books(genre, publication_year);
    
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


EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 12345
ORDER BY order_date DESC
LIMIT 20;

CREATE INDEX idx_orders_customer_id_order_date ON orders(customer_id, order_date);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);

EXPLAIN ANALYZE
SELECT o.*, c.email, c.full_name
FROM orders o
         JOIN customers c ON o.customer_id = c.id
WHERE o.status IN ('pending', 'processing')
  AND o.order_date > NOW() - INTERVAL '7 days';

CREATE INDEX idx_orders_order_date_status ON orders(order_date, status);

EXPLAIN ANALYZE
SELECT * FROM products
WHERE category = 'Electronics'
  AND is_published = true
  AND stock_quantity > 0
ORDER BY price ASC
LIMIT 50;

CREATE INDEX idx_products_category_stock_quantity ON products(category, price, stock_quantity) where is_published = true;

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

--------------------------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------------------------

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

-- Get size of all indices for a specific table
SELECT
    indexname,
    tablename,
    pg_size_pretty(pg_relation_size(quote_ident(schemaname)||'.'||quote_ident(indexname))) AS index_size
FROM pg_indexes
WHERE tablename = 'orders'
ORDER BY pg_relation_size(quote_ident(schemaname)||'.'||quote_ident(indexname)) DESC;

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


-- Drop all create tables
DROP TABLE order_items;
DROP TABLE orders;
DROP TABLE products;
DROP TABLE customers;

DROP TABLE loans;
DROP TABLE members;
DROP TABLE books;
