INSERT INTO stations (station_name, city) VALUES
    ('Київ-Пасажирський', 'Київ'),
    ('Львів', 'Львів'),
    ('Вінниця', 'Вінниця'),
    ('Одеса-Головна', 'Одеса'),
    ('Дніпро-Головний', 'Дніпро')
ON CONFLICT (station_name, city) DO NOTHING;

INSERT INTO users (user_name, hashed_password, email, user_role) VALUES
    ('vlad_kov', '$argon2id$v=19$m=65536,t=3,p=4$hash1', 'vlad@example.com', 'PASSENGER'),
    ('olena_k', '$argon2id$v=19$m=65536,t=3,p=4$hash2', 'olena@example.com', 'PASSENGER'),
    ('admin_uz', '$argon2id$v=19$m=65536,t=3,p=4$hash3', 'admin@easyrail.com', 'ADMIN'),
    ('conductor_petro', '$argon2id$v=19$m=65536,t=3,p=4$hash4', 'petro.cond@easyrail.com', 'CONDUCTOR')
ON CONFLICT (email) DO NOTHING;

INSERT INTO passengers (user_id, passenger_lastname, passenger_name) VALUES
    ((SELECT user_id FROM users WHERE email = 'vlad@example.com'), 'Коваленко', 'Владислав'),
    ((SELECT user_id FROM users WHERE email = 'vlad@example.com'), 'Коваленко', 'Марія'),
    ((SELECT user_id FROM users WHERE email = 'olena@example.com'), 'Коваленко', 'Олена'),
    ((SELECT user_id FROM users WHERE email = 'olena@example.com'), 'Коваленко', 'Тарас');

INSERT INTO carriage_type_list (carriage_type, carriage_type_price_multiplier, number_of_seats) VALUES
    ('COUPE', 150, 36),
    ('PLATZKART', 100, 54),
    ('LUX', 250, 18),
    ('SEAT', 120, 68)
ON CONFLICT (carriage_type) DO NOTHING;

INSERT INTO routes (route_name, base_segment_price, route_number, route_status, schedule_rule, train_type) VALUES
    ('Київ — Львів', 12000, '705К', 'ACTIVE', 'DAILY', 'INTERCITY'),
    ('Київ — Одеса', 15000, '105О', 'ACTIVE', 'DAILY', 'FAST'),
    ('Київ — Дніпро', 13500, '734П', 'ACTIVE', 'WEEKDAYS', 'INTERCITY')
ON CONFLICT (route_number) DO NOTHING;

INSERT INTO carriages (carriage_type_id, route_id, carriage_number) VALUES
    (
        (SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'SEAT'),
        (SELECT route_id FROM routes WHERE route_number = '705К'),
        1
    ),
    (
        (SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'SEAT'),
        (SELECT route_id FROM routes WHERE route_number = '705К'),
        2
    ),
    (
        (SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'COUPE'),
        (SELECT route_id FROM routes WHERE route_number = '105О'),
        1
    ),
    (
        (SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'PLATZKART'),
        (SELECT route_id FROM routes WHERE route_number = '105О'),
        2
    );

INSERT INTO seat_templates_list (carriage_type_id, seat_number, is_side, tier_type) VALUES
    ((SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'SEAT'), 1, false, 'SEAT'),
    ((SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'SEAT'), 2, false, 'SEAT'),
    ((SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'COUPE'), 1, false, 'DOWN'),
    ((SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'COUPE'), 2, false, 'TOP'),
    ((SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'PLATZKART'), 37, true, 'DOWN');

-- 8. РЕЙСИ (TRIPS) (підв'язка до маршруту)
INSERT INTO trips (route_id, departure_time, trip_status, delay_minutes) VALUES
    ((SELECT route_id FROM routes WHERE route_number = '705К'), '2026-11-01 06:00:00+02', 'SCHEDULED', 0),
    ((SELECT route_id FROM routes WHERE route_number = '705К'), '2026-11-02 06:00:00+02', 'SCHEDULED', 15),
    ((SELECT route_id FROM routes WHERE route_number = '105О'), '2026-11-01 21:15:00+02', 'SCHEDULED', 0);

-- 9. ЗУПИНКИ (STOPS) (підв'язка до маршруту та станції)
INSERT INTO stops (route_id, station_id, arrival_offset_minutes, departure_offset_minutes, stop_order) VALUES
    -- Рейс 705К
    (
        (SELECT route_id FROM routes WHERE route_number = '705К'),
        (SELECT station_id FROM stations WHERE station_name = 'Київ-Пасажирський'),
        0, 0, 1
    ),
    (
        (SELECT route_id FROM routes WHERE route_number = '705К'),
        (SELECT station_id FROM stations WHERE station_name = 'Вінниця'),
        140, 145, 2
    ),
    (
        (SELECT route_id FROM routes WHERE route_number = '705К'),
        (SELECT station_id FROM stations WHERE station_name = 'Львів'),
        360, 360, 3
    ),
    -- Рейс 105О
    (
        (SELECT route_id FROM routes WHERE route_number = '105О'),
        (SELECT station_id FROM stations WHERE station_name = 'Київ-Пасажирський'),
        0, 0, 1
    ),
    (
        (SELECT route_id FROM routes WHERE route_number = '105О'),
        (SELECT station_id FROM stations WHERE station_name = 'Вінниця'),
        180, 185, 2
    ),
    (
        (SELECT route_id FROM routes WHERE route_number = '105О'),
        (SELECT station_id FROM stations WHERE station_name = 'Одеса-Головна'),
        540, 540, 3
    );

-- 10. КВИТКИ (TICKET_SEGMENT)
INSERT INTO ticket_segment (
    user_id, passenger_id, trip_id, seat_id, carriage_id,
    from_station_id, to_station_id, from_stop_order, to_stop_order,
    ticket_status, created_at, hold_expires_at, paid_at, cancelled_at,
    price, payment_transaction_id, pdf_url,
    passenger_lastname, passenger_name, from_station_name, to_station_name,
    departure_time, arrival_time, boarded_at
) VALUES
    -- Квиток 1
    (
        (SELECT user_id FROM users WHERE email = 'vlad@example.com'),
        (SELECT passenger_id FROM passengers WHERE passenger_name = 'Владислав' AND passenger_lastname = 'Коваленко' LIMIT 1),
        (SELECT trip_id FROM trips WHERE route_id = (SELECT route_id FROM routes WHERE route_number = '705К') AND departure_time = '2026-11-01 06:00:00+02'),
        (SELECT seat_id FROM seat_templates_list WHERE seat_number = 1 AND carriage_type_id = (SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'SEAT')),
        (SELECT carriage_id FROM carriages WHERE carriage_number = 1 AND route_id = (SELECT route_id FROM routes WHERE route_number = '705К')),
        (SELECT station_id FROM stations WHERE station_name = 'Київ-Пасажирський'),
        (SELECT station_id FROM stations WHERE station_name = 'Львів'),
        1, 3,
        'PAID',
        NOW() - INTERVAL '1 hour',
        NOW() - INTERVAL '50 minutes',
        NOW() - INTERVAL '52 minutes',
        NULL,
        (
            SELECT (3 - 1) * r.base_segment_price * ctl.carriage_type_price_multiplier / 100
            FROM routes r, carriage_type_list ctl
            WHERE r.route_number = '705К' AND ctl.carriage_type = 'SEAT'
        ),
        'txn_liqpay_982347102',
        'https://s3.easyrail.ua/tickets/40000000-1.pdf',
        'Коваленко', 'Владислав', 'Київ-Пасажирський', 'Львів',
        '2026-11-01 06:00:00+02', '2026-11-01 12:00:00+02',
        NULL
    ),
    -- Квиток 2
    (
        (SELECT user_id FROM users WHERE email = 'vlad@example.com'),
        (SELECT passenger_id FROM passengers WHERE passenger_name = 'Марія' AND passenger_lastname = 'Коваленко' LIMIT 1),
        (SELECT trip_id FROM trips WHERE route_id = (SELECT route_id FROM routes WHERE route_number = '705К') AND departure_time = '2026-11-01 06:00:00+02'),
        (SELECT seat_id FROM seat_templates_list WHERE seat_number = 2 AND carriage_type_id = (SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'SEAT')),
        (SELECT carriage_id FROM carriages WHERE carriage_number = 1 AND route_id = (SELECT route_id FROM routes WHERE route_number = '705К')),
        (SELECT station_id FROM stations WHERE station_name = 'Київ-Пасажирський'),
        (SELECT station_id FROM stations WHERE station_name = 'Вінниця'),
        1, 2,
        'HELD',
        NOW() - INTERVAL '2 minutes',
        NOW() + INTERVAL '8 minutes',
        NULL,
        NULL,
        (
            SELECT (2 - 1) * r.base_segment_price * ctl.carriage_type_price_multiplier / 100
            FROM routes r, carriage_type_list ctl
            WHERE r.route_number = '705К' AND ctl.carriage_type = 'SEAT'
        ),
        NULL,
        NULL,
        'Коваленко', 'Марія', 'Київ-Пасажирський', 'Вінниця',
        '2026-11-01 06:00:00+02', '2026-11-01 08:25:00+02',
        NULL
    ),
    -- Квиток 3
    (
        (SELECT user_id FROM users WHERE email = 'olena@example.com'),
        (SELECT passenger_id FROM passengers WHERE passenger_name = 'Олена' AND passenger_lastname = 'Коваленко' LIMIT 1),
        (SELECT trip_id FROM trips WHERE route_id = (SELECT route_id FROM routes WHERE route_number = '105О') AND departure_time = '2026-11-01 21:15:00+02'),
        (SELECT seat_id FROM seat_templates_list WHERE seat_number = 1 AND carriage_type_id = (SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'COUPE')),
        (SELECT carriage_id FROM carriages WHERE carriage_number = 1 AND route_id = (SELECT route_id FROM routes WHERE route_number = '105О')),
        (SELECT station_id FROM stations WHERE station_name = 'Київ-Пасажирський'),
        (SELECT station_id FROM stations WHERE station_name = 'Одеса-Головна'),
        1, 3,
        'PAID',
        NOW() - INTERVAL '3 hours',
        NOW() - INTERVAL '2 hours 50 minutes',
        NOW() - INTERVAL '2 hours 55 minutes',
        NULL,
        (
            SELECT (3 - 1) * r.base_segment_price * ctl.carriage_type_price_multiplier / 100
            FROM routes r, carriage_type_list ctl
            WHERE r.route_number = '105О' AND ctl.carriage_type = 'COUPE'
        ),
        'txn_mono_483726190',
        'https://s3.easyrail.ua/tickets/40000000-3.pdf',
        'Коваленко', 'Олена', 'Київ-Пасажирський', 'Одеса-Головна',
        '2026-11-01 21:15:00+02', '2026-11-02 06:15:00+02',
        '2026-11-01 20:55:00+02'
    ),
    -- Квиток 4
    (
        (SELECT user_id FROM users WHERE email = 'olena@example.com'),
        (SELECT passenger_id FROM passengers WHERE passenger_name = 'Тарас' AND passenger_lastname = 'Коваленко' LIMIT 1),
        (SELECT trip_id FROM trips WHERE route_id = (SELECT route_id FROM routes WHERE route_number = '105О') AND departure_time = '2026-11-01 21:15:00+02'),
        (SELECT seat_id FROM seat_templates_list WHERE seat_number = 2 AND carriage_type_id = (SELECT carriage_type_id FROM carriage_type_list WHERE carriage_type = 'COUPE')),
        (SELECT carriage_id FROM carriages WHERE carriage_number = 1 AND route_id = (SELECT route_id FROM routes WHERE route_number = '105О')),
        (SELECT station_id FROM stations WHERE station_name = 'Київ-Пасажирський'),
        (SELECT station_id FROM stations WHERE station_name = 'Одеса-Головна'),
        1, 3,
        'RETURNED',
        NOW() - INTERVAL '1 day',
        NOW() - INTERVAL '23 hours 50 minutes',
        NOW() - INTERVAL '23 hours 55 minutes',
        NOW() - INTERVAL '5 hours',
        (
            SELECT (3 - 1) * r.base_segment_price * ctl.carriage_type_price_multiplier / 100
            FROM routes r, carriage_type_list ctl
            WHERE r.route_number = '105О' AND ctl.carriage_type = 'COUPE'
        ),
        'txn_mono_112233445',
        'https://s3.easyrail.ua/tickets/40000000-4.pdf',
        'Коваленко', 'Тарас', 'Київ-Пасажирський', 'Одеса-Головна',
        '2026-11-01 21:15:00+02', '2026-11-02 06:15:00+02',
        NULL
    );