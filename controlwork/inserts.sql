INSERT INTO "user" (username, hashed_password, email, name) VALUES
('kolya534', 'asefqdfqfs', 'kolya@gmail.com', 'Kolya'),
('egor713', 'sfrergwqsds', 'egor@gmail.com', 'Egor'),
('illya119', 'dfwq1qv2', 'illya@gmail.com', 'Illya'),
('misha745', 'vew4v4vq', 'misha@gmail.com', 'Misha');

INSERT INTO lot (name, user_id, start_price, currency) VALUES
('book', (SELECT id FROM "user" WHERE username = 'kolya534'), 100, 'UAH'),
('phone', (SELECT id FROM "user" WHERE username = 'egor713'), 500, 'USD'),
('cup', (SELECT id FROM "user" WHERE username = 'illya119'), 10, 'EUR'),
('bag',(SELECT id FROM "user" WHERE username = 'illya119'), 5, 'EUR'),
('jacket', (SELECT id FROM "user" WHERE username = 'kolya534'), 800, 'UAH');


INSERT INTO bet (user_id, lot_id, amount, status) VALUES
((SELECT id FROM "user" WHERE username = 'egor713'), 1, 120, 'ended'),
((SELECT id FROM "user" WHERE username = 'illya119'), 1, 150, 'won'),
((SELECT id FROM "user" WHERE username = 'kolya534'), 2, 550, 'won'),
((SELECT id FROM "user" WHERE username = 'kolya534'), 3, 170, 'won'),
((SELECT id FROM "user" WHERE username = 'egor713'), 5, 900, 'won' );


INSERT INTO transaction (buyer_id, seller_id, lot_id, bet_id, amount, currency, status) VALUES
((SELECT id FROM "user" WHERE username = 'illya119'), (SELECT id FROM "user" WHERE username = 'kolya534'), 1, 2, 150, 'UAH', 'completed'),
((SELECT id FROM "user" WHERE username = 'kolya534'), (SELECT id FROM "user" WHERE username = 'egor713'), 2, 3, 550, 'USD', 'completed'),
((SELECT id FROM "user" WHERE username = 'kolya534'), (SELECT id FROM "user" WHERE username = 'illya119'), 3, 4, 200, 'EUR', 'completed'),
((SELECT id FROM "user" WHERE username = 'egor713'),(SELECT id FROM "user" WHERE username = 'kolya534'), 5, 5, 900, 'UAH', 'completed' );

INSERT INTO category (name) VALUES
('Books'),
('Electronics'),
('Home'),
('Sport');


INSERT INTO lot_category (lot_id, category_id) VALUES
(1, (SELECT id FROM category WHERE name = 'Books')),
(2, (SELECT id FROM category WHERE name = 'Electronics')),
(2, (SELECT id FROM category WHERE name = 'Home')),
(3, (SELECT id FROM category WHERE name = 'Home'));