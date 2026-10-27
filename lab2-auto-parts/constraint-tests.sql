-- Run after schema.sql and data.sql. Each invalid update must fail.
-- An unexpected result raises an error; successful tests leave data unchanged.
BEGIN;
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM customers) <> 5
       OR (SELECT COUNT(*) FROM categories) <> 5
       OR (SELECT COUNT(*) FROM suppliers) <> 5
       OR (SELECT COUNT(*) FROM products) <> 10
       OR (SELECT COUNT(*) FROM orders) <> 5
       OR (SELECT COUNT(*) FROM order_items) <> 10
       OR (SELECT COUNT(*) FROM payments) <> 6 THEN
        RAISE EXCEPTION 'Unexpected row counts: load demo data first';
    END IF;

    BEGIN
        UPDATE customers SET customer_id = 1 WHERE customer_id = 2;
        RAISE EXCEPTION 'FAIL: 01 duplicate primary key';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PASS: 01 duplicate primary key';
    END;

    BEGIN
        UPDATE customers SET email = 'ivan@example.com' WHERE customer_id = 2;
        RAISE EXCEPTION 'FAIL: 02 duplicate email';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PASS: 02 duplicate email';
    END;

    BEGIN
        UPDATE customers SET first_name = NULL WHERE customer_id = 1;
        RAISE EXCEPTION 'FAIL: 03 required name';
    EXCEPTION WHEN not_null_violation THEN
        RAISE NOTICE 'PASS: 03 required name';
    END;

    BEGIN
        UPDATE products SET sku = 'BR-001' WHERE product_id = 2;
        RAISE EXCEPTION 'FAIL: 04 duplicate SKU';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PASS: 04 duplicate SKU';
    END;

    BEGIN
        UPDATE products SET price = -1 WHERE product_id = 1;
        RAISE EXCEPTION 'FAIL: 05 invalid price';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: 05 invalid price';
    END;

    BEGIN
        UPDATE products SET stock_quantity = -1 WHERE product_id = 1;
        RAISE EXCEPTION 'FAIL: 06 negative stock';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: 06 negative stock';
    END;

    BEGIN
        UPDATE products SET category_id = 99999 WHERE product_id = 1;
        RAISE EXCEPTION 'FAIL: 07 missing category';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: 07 missing category';
    END;

    BEGIN
        UPDATE products SET supplier_id = 99999 WHERE product_id = 1;
        RAISE EXCEPTION 'FAIL: 08 missing supplier';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: 08 missing supplier';
    END;

    BEGIN
        UPDATE orders SET customer_id = 99999 WHERE order_id = 1;
        RAISE EXCEPTION 'FAIL: 09 missing customer';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: 09 missing customer';
    END;

    BEGIN
        UPDATE orders SET status = 'unknown' WHERE order_id = 1;
        RAISE EXCEPTION 'FAIL: 10 invalid order status';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: 10 invalid order status';
    END;

    BEGIN
        UPDATE order_items SET order_id = 99999 WHERE order_item_id = 1;
        RAISE EXCEPTION 'FAIL: 11 missing order in item';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: 11 missing order in item';
    END;

    BEGIN
        UPDATE order_items SET product_id = 99999 WHERE order_item_id = 1;
        RAISE EXCEPTION 'FAIL: 12 missing product';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: 12 missing product';
    END;

    BEGIN
        UPDATE order_items SET quantity = 0 WHERE order_item_id = 1;
        RAISE EXCEPTION 'FAIL: 13 zero quantity';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: 13 zero quantity';
    END;

    BEGIN
        UPDATE order_items SET unit_price = 0 WHERE order_item_id = 1;
        RAISE EXCEPTION 'FAIL: 14 zero unit price';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: 14 zero unit price';
    END;

    BEGIN
        UPDATE order_items SET product_id = 1 WHERE order_item_id = 2;
        RAISE EXCEPTION 'FAIL: 15 duplicate order/product pair';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PASS: 15 duplicate order/product pair';
    END;

    BEGIN
        UPDATE payments SET order_id = 99999 WHERE payment_id = 1;
        RAISE EXCEPTION 'FAIL: 16 missing order in payment';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: 16 missing order in payment';
    END;

    BEGIN
        UPDATE payments SET amount = -1 WHERE payment_id = 1;
        RAISE EXCEPTION 'FAIL: 17 negative payment';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: 17 negative payment';
    END;

    BEGIN
        UPDATE payments SET method = 'unknown' WHERE payment_id = 1;
        RAISE EXCEPTION 'FAIL: 18 invalid payment method';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: 18 invalid payment method';
    END;

    BEGIN
        UPDATE payments SET status = 'unknown' WHERE payment_id = 1;
        RAISE EXCEPTION 'FAIL: 19 invalid payment status';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: 19 invalid payment status';
    END;

    -- Check defaults in a temporary update; the outer transaction is rolled back.
    UPDATE orders SET status = DEFAULT WHERE order_id = 1;
    UPDATE products SET stock_quantity = DEFAULT WHERE product_id = 1;
    UPDATE payments SET status = DEFAULT WHERE payment_id = 1;
    IF (SELECT status FROM orders WHERE order_id = 1) IS DISTINCT FROM 'pending'
       OR (SELECT stock_quantity FROM products WHERE product_id = 1) IS DISTINCT FROM 0
       OR (SELECT status FROM payments WHERE payment_id = 1) IS DISTINCT FROM 'pending' THEN
        RAISE EXCEPTION 'FAIL: 20 default values';
    END IF;
    RAISE NOTICE 'PASS: 20 default values';
    RAISE NOTICE 'All 20 constraint/default tests passed';
END;
$$;
ROLLBACK;
