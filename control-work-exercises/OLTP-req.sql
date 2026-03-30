TRUNCATE TABLE users, category, lots, bids RESTART IDENTITY CASCADE;
-- INSERT запити
INSERT INTO users (username, email) 
VALUES 
    ('Watto_Toydarian', 'watto@mosespa.tatooine'),
    ('Anakin_Skywalker', 'skywalker1@padavan.jedaiorden'),
    ('Obi_Wan_Kenobi', 'obiwankenobi@jedi.jedaiorden'),
    ('Jar_Jar_Binks', 'myneemailajarjar@jarjar.ya'),
    ('Dart_Maul', 'newsyth@syth.gov'),
    ('Quai_Gon', 'quai_gon@jedi.jedaiorden'),
    ('Jawa_Traders', 'scraps@tatooine.sand'),
    ('Boba_Fett', 'bounty@mandalore.merc'),
    ('Jabba_the_Hutt', 'boss@palace.tatooine');

INSERT INTO category (name) 
VALUES ('Ship Parts'),
        ('Droids'),
        ('Strange things');

INSERT INTO lots (title, description, start_price, end_time, seller_id, category_id) 
VALUES ('T-14 Hyperdrive Generator', 'Used condition. I dont take Republic credits, I need something more real.', 20000.00, '2026-03-15 14:00:00', 1, 1),
       ('Naboo Royal Cruiser Engine', 'Shiny. Have some scratches.', 50000.00, '2026-12-31 00:00:00', 1, 1),
       ('R2 Astromech Droid', 'Blue and white. Laggy but loyal.', 1000.00, '2026-12-31 23:59:59', 6, 2), 
       ('Han Solo in Carbonite', 'Perfect decoration for your palace.', 100000.00, '1983-05-25 00:00:00', 7, 3);;

INSERT INTO bids (amount, bid_time, lot_id, buyer_id) 
VALUES 
    (21000.00, '2001-05-10 10:00:00', 1, 6), 
    (25000.00, '2001-05-12 11:00:00', 1, 6), 
    (1100.00, '2025-10-01 09:00:00', 3, 2), 
    (1500.00, '2025-10-05 12:00:00', 3, 6), 
    (150000.00, '1983-05-20 15:00:00', 4, 8);

INSERT INTO sales (final_price, lot_id, buyer_id) 
VALUES 
    (25000.00, 1, 6),
    (150000.00, 4, 9);

-- UPDATE запити

UPDATE users 
SET email = 'ben_kenobi_anonymous@tatooine.com', username = 'Strange_Ben_Kenobi'
WHERE username = 'Obi_Wan_Kenobi';

UPDATE users
SET username = 'Dart_Vaider', email = 'dartvaider@emprire.gov'
WHERE username = 'Anakin_Skywalker';

UPDATE lots 
SET description = 'I sold it to a strange jedi', status = 'closed' 
WHERE lot_id = 1;

-- DELETE запити
DELETE FROM users
WHERE username = 'Dart_Maul';

DELETE FROM users
WHERE username = 'Jar_Jar_Binks';

-- SELECT запити
SELECT * FROM lots 
WHERE category_id = 1 AND end_time > NOW();

SELECT * FROM bids 
WHERE lot_id = 1;