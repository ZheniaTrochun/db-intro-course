-- Lab 3: INSERT. Temporary demo records; ROLLBACK restores the initial data.
-- Explicit IDs 9001 are reserved for this demonstration (no sequence changes).
BEGIN;

-- I1. Add a new customer.
INSERT INTO customers (customer_id, first_name, last_name, email, phone)
VALUES (9001, 'Lab', 'Customer', 'lab3@example.com', '+380000009001');
SELECT customer_id, first_name, last_name, email FROM customers WHERE customer_id = 9001;

-- I2. Add a product in the Filters category.
INSERT INTO products (product_id, category_id, supplier_id, name, sku, price, stock_quantity)
VALUES (9001, 2, 2, 'Cabin filter', 'LAB3-001', 450.00, 12);
SELECT product_id, name, sku, price, stock_quantity FROM products WHERE product_id = 9001;

-- I3. Create a pending order for the new customer (default status).
INSERT INTO orders (order_id, customer_id) VALUES (9001, 9001);
SELECT order_id, customer_id, status FROM orders WHERE order_id = 9001;

-- I4. Add two filters, taking the current price from the catalogue.
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price)
SELECT 9001, 9001, product_id, 2, price FROM products WHERE product_id = 9001;
SELECT order_id, product_id, quantity, unit_price, quantity * unit_price AS line_total
FROM order_items WHERE order_item_id = 9001;

-- I5. Register a pending payment for the order.
INSERT INTO payments (payment_id, order_id, amount, method)
SELECT 9001, order_id, SUM(quantity * unit_price), 'card'
FROM order_items WHERE order_id = 9001 GROUP BY order_id;
SELECT payment_id, order_id, amount, method, status FROM payments WHERE payment_id = 9001;

ROLLBACK;
SELECT COUNT(*) AS demo_customers_after_rollback FROM customers WHERE customer_id = 9001;
