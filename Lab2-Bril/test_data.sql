INSERT INTO customer (first_name, last_name, email, phone, address) VALUES
    ('Ivan', 'Petrenko', 'ivan.petrenko@gmail.com', '+380661234567', 'Kyiv...'),
    ('Olena', 'Kovalenko', 'ole.koval22@gmail.com', '+380677645634', 'Lviv...'),
    ('Andrii', 'Shevchenko', 'shevaANDRI@gmail.com', '+380503545065', 'Odesa...'),
    ('Lionel', 'Messi', 'messiiilliinno12@gmail.com', '+380999999999', 'Kharkiv...'),
    ('Alex', 'Patriot', 'hhfgdfdf435@gmail.com', '+380631234567', 'Dnipro...');



INSERT INTO car_model (brand, model, category, description, daily_rate) VALUES
    ('Toyota', 'Land Cruiser 300', 'SUV', 'Full-size off-road SUV...', 7000.00),
    ('BMW', 'X5 G05', 'SUV', 'Premium luxury SUV...', 7000.00),
    ('Volkswagen', 'Passat B8', 'Sedan', 'Comfortable family sedan...', 3600.00),
    ('Mercedes-Benz', 'E-Class W213', 'Sedan', 'Executive luxury sedan...', 9000.00),
    ('Audi', 'Q7', 'SUV', 'Premium family SUV...', 7600.00);



INSERT INTO car (car_model_id, status) VALUES
    (1, 'available'),
    (2, 'rented'),
    (3, 'available'),
    (4, 'maintenance'),
    (5, 'unavailable');



INSERT INTO rental (customer_id, car_id, start_date, end_date, price, status) VALUES
    (1, 1, '2026-01-10 09:00:00', '2026-01-15 09:00:00', 35000.00, 'finished'),
    (2, 2, '2026-10-28 10:00:00', '2026-11-02 10:00:00', 35000.00, 'active'),
    (3, 3, '2026-11-05 12:00:00', '2026-11-10 12:00:00', 18000.00, 'scheduled'),
    (4, 4, '2026-02-01 08:00:00', '2026-02-04 08:00:00', 27000.00, 'cancelled'),
    (1, 1, '2026-03-15 09:00:00', '2026-03-18 09:00:00', 21000.00, 'finished');



INSERT INTO payment (rental_id, amount, payment_date, status) VALUES
    (1, 35000.00, '2026-01-09 14:30:00', 'paid'),
    (2, 17500.00, '2026-10-27 12:00:00', 'paid'),
    (2, 17500.00, '2026-10-28 09:00:00', 'paid'),
    (3, 18000.00, '2026-11-04 15:00:00', 'pending_confirmation'),
    (4, 27000.00, '2026-01-31 16:00:00', 'cancelled'),
    (5, 21000.00, '2026-03-14 11:00:00', 'paid');