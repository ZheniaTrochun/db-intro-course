-- Lab 3: UPDATE. Each change has a before/after SELECT and a specific WHERE.
-- These are separate demonstrations, not a real order fulfilment workflow.
BEGIN;

-- U1. Change the customer's phone number.
SELECT customer_id, phone FROM customers WHERE customer_id = 1;
UPDATE customers SET phone = '+380000009999' WHERE customer_id = 1;
SELECT customer_id, phone FROM customers WHERE customer_id = 1;

-- U2. Change the current oil filter price; historical prices stay unchanged.
SELECT product_id, price FROM products WHERE product_id = 3;
UPDATE products SET price = 550.00 WHERE product_id = 3;
SELECT product_id, price FROM products WHERE product_id = 3;
SELECT order_id, unit_price FROM order_items WHERE order_id = 1 AND product_id = 3;

-- U3. Receive five additional units of brake pads.
SELECT product_id, stock_quantity FROM products WHERE product_id = 1;
UPDATE products SET stock_quantity = stock_quantity + 5 WHERE product_id = 1;
SELECT product_id, stock_quantity FROM products WHERE product_id = 1;

-- U4. Mark a pending payment as failed.
SELECT payment_id, status FROM payments WHERE payment_id = 5;
UPDATE payments SET status = 'failed' WHERE payment_id = 5 AND status = 'pending';
SELECT payment_id, status FROM payments WHERE payment_id = 5;

-- U5. Cancel the pending order after the failed payment.
SELECT order_id, status FROM orders WHERE order_id = 4;
UPDATE orders SET status = 'cancelled' WHERE order_id = 4 AND status = 'pending';
SELECT order_id, status FROM orders WHERE order_id = 4;

ROLLBACK;
SELECT product_id, price, stock_quantity FROM products WHERE product_id IN (1, 3) ORDER BY product_id;
