-- Lab 3: run after all five previous scripts, including the committed order.
-- The CHECK constraint on the temporary table makes any failed test an error.
BEGIN;
CREATE TEMP TABLE lab3_checks (
    test_no INTEGER PRIMARY KEY,
    test_name TEXT NOT NULL,
    passed BOOLEAN NOT NULL CHECK (passed)
) ON COMMIT DROP;

INSERT INTO lab3_checks (test_no, test_name, passed) VALUES
    (1, 'customers: 5 rows', (SELECT COUNT(*) = 5 FROM customers)),
    (2, 'categories: 5 rows', (SELECT COUNT(*) = 5 FROM categories)),
    (3, 'suppliers: 5 rows', (SELECT COUNT(*) = 5 FROM suppliers)),
    (4, 'products: 10 rows', (SELECT COUNT(*) = 10 FROM products)),
    (5, 'orders: 6 rows', (SELECT COUNT(*) = 6 FROM orders)),
    (6, 'order_items: 11 rows', (SELECT COUNT(*) = 11 FROM order_items)),
    (7, 'payments: 7 rows', (SELECT COUNT(*) = 7 FROM payments)),
    (8, 'INSERT demo rolled back', NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = 9001)
        AND NOT EXISTS (SELECT 1 FROM products WHERE product_id = 9001)
        AND NOT EXISTS (SELECT 1 FROM orders WHERE order_id = 9001)
        AND NOT EXISTS (SELECT 1 FROM order_items WHERE order_item_id = 9001)
        AND NOT EXISTS (SELECT 1 FROM payments WHERE payment_id = 9001)),
    (9, 'UPDATE demo rolled back', EXISTS (SELECT 1 FROM customers WHERE customer_id = 1 AND phone = '+380000000001')
        AND EXISTS (SELECT 1 FROM products WHERE product_id = 3 AND price = 500)
        AND EXISTS (SELECT 1 FROM orders WHERE order_id = 4 AND status = 'pending')
        AND EXISTS (SELECT 1 FROM payments WHERE payment_id = 5 AND status = 'pending')),
    (10, 'DELETE demo rolled back', EXISTS (SELECT 1 FROM orders WHERE order_id = 5 AND status = 'cancelled')
        AND (SELECT COUNT(*) = 2 FROM order_items WHERE order_id = 5)
        AND EXISTS (SELECT 1 FROM payments WHERE order_id = 5 AND status = 'failed')),
    (11, 'Committed order and item', EXISTS (SELECT 1 FROM orders WHERE order_id = 9002 AND customer_id = 5 AND status = 'confirmed')
        AND EXISTS (SELECT 1 FROM order_items WHERE order_id = 9002 AND product_id = 1 AND quantity = 2 AND unit_price = 750)),
    (12, 'Stock decreased to 16', EXISTS (SELECT 1 FROM products WHERE product_id = 1 AND stock_quantity = 16)),
    (13, 'Successful payment: 1500', EXISTS (SELECT 1 FROM payments WHERE order_id = 9002 AND amount = 1500 AND status = 'successful' AND method = 'card')),
    (14, 'Rejected order left no records', NOT EXISTS (SELECT 1 FROM orders WHERE order_id = 9003)
        AND NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = 9003)
        AND NOT EXISTS (SELECT 1 FROM payments WHERE order_id = 9003)
        AND EXISTS (SELECT 1 FROM products WHERE product_id = 8 AND stock_quantity = 0)),
    (15, 'Historical price: 400; current: 500', EXISTS (
        SELECT 1 FROM order_items oi JOIN products p ON p.product_id = oi.product_id
        WHERE oi.order_id = 1 AND oi.product_id = 3 AND oi.unit_price = 400 AND p.price = 500)),
    (16, 'Successful payments total: 9850', (SELECT COALESCE(SUM(amount), 0) = 9850 FROM payments WHERE status = 'successful')),
    (17, 'No empty orders', NOT EXISTS (SELECT 1 FROM orders o WHERE NOT EXISTS (
        SELECT 1 FROM order_items oi WHERE oi.order_id = o.order_id))),
    (18, 'No negative stock', NOT EXISTS (SELECT 1 FROM products WHERE stock_quantity < 0));

SELECT test_no, test_name, CASE WHEN passed THEN 'PASS' ELSE 'FAIL' END AS result
FROM lab3_checks ORDER BY test_no;
SELECT COUNT(*) AS passed_tests FROM lab3_checks WHERE passed;
COMMIT;
