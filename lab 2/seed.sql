insert into client (first_name, last_name, phone, email)
values
    ('Максим', 'Швець', '+380674928104', 'mkdsfs@gmail.com'),
    ('Артем', 'Пономаренко', '+380508371920', 'okvcv@gmail.com'),
    ('Роман', 'Лисенко', null, 'lysdvc@gmail.com'),
    ('Яна', 'Мельник', '+380972049183', null),
    ('Олег', 'Назаренко', '+380663847291', 'inz@gmail.com');

insert into court (court_name, surface_type, is_indoor, hourly_rate)
values
    ('Корт 1', 'clay', false, 600.00),
    ('Корт 2', 'hard', true, 800.00),
    ('Корт 3', 'clay', false, 500.00),
    ('Корт 4', 'hard', true, 750.00),
    ('Корт 5', 'hard', false, 550.00);

insert into coach (first_name, last_name, phone, hourly_rate)
values
    ('Денис', 'Орлов', '+380684192034', 400.00),
    ('Артур', 'Мороз', '+380638492011', 500.00),
    ('Олена', 'Романенко', '+380951928374', 350.00),
    ('Дмитро', 'Кравчук', '+380673910482', 600.00),
    ('Євгеній', 'Трочун', '+380509283741', 450.00);

insert into equipment (item_name, category, rental_price)
values
    ('Ракетка Head', 'racket', 150.00),
    ('Ракетка Wilson', 'racket', 200.00),
    ('Набір м''ячів Dunlop', 'balls', 100.00),
    ('Кошик м''ячів Head', 'balls', 150.00),
    ('Ракетка Babolat', 'racket', 150.00);

insert into booking (client_id, court_id, coach_id, booking_date, start_time, end_time, total_price, status)
values
    (1, 1, 1, '2026-11-10', '09:00', '10:00', 1400.00, 'completed'),
    (2, 2, null, '2026-11-10', '11:00', '12:00', 1000.00, 'completed'),
    (3, 3, 2, '2026-11-11', '10:00', '12:00', 2150.00, 'confirmed'),
    (1, 3, null, '2026-11-14', '12:00', '13:00', 650.00, 'new'),
    (5, 4, 3, '2026-11-14', '14:00', '15:00', 1100.00, 'cancelled');

insert into booking_equipment (booking_id, equipment_id, quantity)
values
    (1, 1, 2),
    (1, 3, 1),
    (2, 2, 1),
    (3, 4, 1),
    (4, 5, 1);

insert into payment (booking_id, payment_date, amount, payment_method, status)
values
    (1, '2026-11-10 08:35:00', 1400.00, 'card', 'failed'),
    (1, '2026-11-11 08:40:00', 1400.00, 'card', 'success'),
    (2, '2026-11-11 10:40:00', 1000.00, 'cash', 'success'),
    (3, '2026-11-12 18:00:00', 2150.00, 'card', 'success'),
    (4, '2026-11-12 18:15:00', 650.00, 'card', 'pending');