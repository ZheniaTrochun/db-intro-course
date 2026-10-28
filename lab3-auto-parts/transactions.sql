-- Lab 3: two order transactions. Run once on the initial data after CRUD demos.
-- T1 commits a successful order. T2 demonstrates rejection and rollback.
-- IDs 9002 and 9003 are reserved for the scenarios.

-- T1. Customer 5 buys two brake pad sets. Stock: 18 -> 16; total: 1500.
BEGIN;
SELECT product_id, price, stock_quantity FROM products WHERE product_id = 1;
INSERT INTO orders (order_id, customer_id) VALUES (9002, 5);

-- The conditional UPDATE locks the product row and prevents negative stock.
-- If stock is insufficient, the exception aborts the whole transaction.
DO $$
BEGIN
    UPDATE products SET stock_quantity = stock_quantity - 2
    WHERE product_id = 1 AND stock_quantity >= 2;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Not enough stock for order 9002';
    END IF;
END;
$$;

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price)
SELECT 9002, 9002, product_id, 2, price FROM products WHERE product_id = 1;
INSERT INTO payments (payment_id, order_id, amount, method, status)
SELECT 9002, order_id, SUM(quantity * unit_price), 'card', 'successful'
FROM order_items WHERE order_id = 9002 GROUP BY order_id;
UPDATE orders SET status = 'confirmed' WHERE order_id = 9002 AND status = 'pending';
COMMIT;

SELECT o.order_id, o.status, oi.product_id, oi.quantity, oi.unit_price,
       p.stock_quantity, pay.amount, pay.status AS payment_status
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN payments pay ON pay.order_id = o.order_id
WHERE o.order_id = 9002;

-- T2. Attempt to buy an out-of-stock headlight bulb (product 8).
BEGIN;
SELECT product_id, stock_quantity FROM products WHERE product_id = 8;
-- The nested block rolls back its changes when our stock exception is caught.
DO $$
BEGIN
    BEGIN
        INSERT INTO orders (order_id, customer_id) VALUES (9003, 5);
        UPDATE products SET stock_quantity = stock_quantity - 1
        WHERE product_id = 8 AND stock_quantity >= 1;
        IF NOT FOUND THEN
            RAISE EXCEPTION USING ERRCODE = 'P7501', MESSAGE = 'Not enough stock for order 9003';
        END IF;
        RAISE EXCEPTION 'Test expected insufficient stock, but the update succeeded';
    EXCEPTION WHEN SQLSTATE 'P7501' THEN
        RAISE NOTICE 'PASS T2: insufficient stock; order creation rolled back';
    END;
END;
$$;
SELECT COUNT(*) AS rejected_order_count FROM orders WHERE order_id = 9003;
SELECT product_id, stock_quantity FROM products WHERE product_id = 8;
ROLLBACK;
