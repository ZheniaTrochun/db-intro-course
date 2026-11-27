-- Demo data for a fresh schema (identity values start at 1).
-- All names and contacts below are fictional test data.
BEGIN;

INSERT INTO customers (first_name, last_name, email, phone, created_at) VALUES
    ('Ivan', 'Testov', 'ivan@example.com', '+380000000001', '2026-10-01 10:00'),
    ('Olena', 'Testova', 'olena@example.com', '+380000000002', '2026-10-02 11:00'),
    ('Andrii', 'Testov', 'andrii@example.com', '+380000000003', '2026-10-03 12:00'),
    ('Maria', 'Testova', 'maria@example.com', '+380000000004', '2026-10-04 13:00'),
    ('Dmytro', 'Testov', 'dmytro@example.com', '+380000000005', '2026-10-05 14:00');

INSERT INTO categories (name, description) VALUES
    ('Brakes', 'Brake system parts'),
    ('Filters', 'Oil and air filters'),
    ('Suspension', 'Suspension components'),
    ('Electrical', 'Electrical components'),
    ('Cooling', 'Engine cooling components');

INSERT INTO suppliers (name, email, phone) VALUES
    ('Demo Brake Supply', 'brakes@example.com', '+380000000011'),
    ('Demo Filter Supply', 'filters@example.com', '+380000000012'),
    ('Demo Suspension Supply', 'suspension@example.com', '+380000000013'),
    ('Demo Electric Supply', 'electric@example.com', '+380000000014'),
    ('Demo Cooling Supply', 'cooling@example.com', '+380000000015');

INSERT INTO products (category_id, supplier_id, name, sku, description, price, stock_quantity) VALUES
    (1, 1, 'Brake pads', 'BR-001', 'Front brake pad set', 750.00, 18),
    (1, 1, 'Brake disc', 'BR-002', 'Front brake disc', 1200.00, 8),
    (2, 2, 'Oil filter', 'FL-001', 'Engine oil filter', 500.00, 7),
    (2, 2, 'Air filter', 'FL-002', 'Engine air filter', 350.00, 12),
    (3, 3, 'Shock absorber', 'SU-001', 'Front shock absorber', 2400.00, 4),
    (3, 3, 'Stabilizer link', 'SU-002', 'Front stabilizer link', 650.00, 9),
    (4, 4, 'Spark plug', 'EL-001', 'Ignition spark plug', 250.00, 30),
    (4, 4, 'Headlight bulb', 'EL-002', 'Replacement bulb', 320.00, 0),
    (5, 5, 'Water pump', 'CO-001', 'Engine coolant pump', 1800.00, 3),
    (5, 5, 'Thermostat', 'CO-002', 'Coolant thermostat', 900.00, 6);

INSERT INTO orders (customer_id, order_date, status) VALUES
    (1, '2026-11-01 10:00', 'completed'),
    (2, '2026-11-02 11:00', 'completed'),
    (1, '2026-11-03 12:00', 'confirmed'),
    (3, '2026-11-04 13:00', 'pending'),
    (4, '2026-11-05 14:00', 'cancelled');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 2, 750.00), (1, 3, 1, 400.00),
    (2, 2, 2, 1200.00), (2, 4, 1, 350.00),
    (3, 5, 1, 2400.00), (3, 6, 2, 650.00),
    (4, 7, 4, 250.00), (4, 9, 1, 1800.00),
    (5, 3, 1, 500.00), (5, 10, 1, 900.00);

-- The first order has a failed payment followed by a successful one.
INSERT INTO payments (order_id, amount, payment_date, method, status) VALUES
    (1, 1900.00, '2026-11-01 10:05', 'card', 'failed'),
    (1, 1900.00, '2026-11-01 10:10', 'card', 'successful'),
    (2, 2750.00, '2026-11-02 11:05', 'card', 'successful'),
    (3, 3700.00, '2026-11-03 12:05', 'bank_transfer', 'successful'),
    (4, 2800.00, '2026-11-04 13:05', 'card', 'pending'),
    (5, 1400.00, '2026-11-05 14:05', 'card', 'failed');

COMMIT;
