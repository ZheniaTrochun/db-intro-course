-- Lab 3: DELETE. Demonstrate deletion of the cancelled test order 5.
-- Delete dependent rows before the parent because the schema has foreign keys.
-- A cancelled order would normally be retained for audit; this is a rolled-back demo.
BEGIN;

-- D1. Delete the failed payment of order 5 (1 row).
SELECT payment_id, order_id, status FROM payments WHERE order_id = 5 AND status = 'failed';
DELETE FROM payments WHERE order_id = 5 AND status = 'failed';
SELECT payment_id, order_id FROM payments WHERE order_id = 5;

-- D2. Delete the order items (2 rows).
SELECT order_item_id, order_id, product_id FROM order_items WHERE order_id = 5;
DELETE FROM order_items WHERE order_id = 5;
SELECT order_item_id, order_id FROM order_items WHERE order_id = 5;

-- D3. Delete the cancelled order (1 row).
SELECT order_id, status FROM orders WHERE order_id = 5 AND status = 'cancelled';
DELETE FROM orders WHERE order_id = 5 AND status = 'cancelled';
SELECT order_id, status FROM orders WHERE order_id = 5;

ROLLBACK;
SELECT order_id, status FROM orders WHERE order_id = 5;
