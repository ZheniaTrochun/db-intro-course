-- Find Maria by her email.
SELECT name, email
FROM users
WHERE email = 'maria@example.com';


-- Items that cost more than 100.
SELECT name, price
FROM wishlist_items
WHERE price > 100;


-- Anna's reservations.
SELECT reservation_id, item_id
FROM reservations
WHERE user_id = '22222222-2222-2222-2222-222222222222';


-- Give Daria a Travel list and check it.
INSERT INTO wishlists (wishlist_id, user_id, name, description)
VALUES (
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    '55555555-5555-5555-5555-555555555555',
    'Travel',
    'Things for the next trip'
);

SELECT name, description, is_public
FROM wishlists
WHERE wishlist_id = 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee';


-- Add a Suitcase to that list and check it.
INSERT INTO wishlist_items (
    item_id, wishlist_id, name, description, price, product_url
)
VALUES (
    'ffffffff-6666-6666-6666-ffffffffffff',
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'Suitcase',
    'Medium cabin suitcase',
    89.00,
    'https://example.com/suitcase'
);

SELECT name, price, image_url, is_completed
FROM wishlist_items
WHERE item_id = 'ffffffff-6666-6666-6666-ffffffffffff';


-- Reserve the Coffee Machine for Daria and check it.
INSERT INTO reservations (reservation_id, item_id, user_id)
VALUES (
    '44444444-dddd-dddd-dddd-dddddddddddd',
    'bbbbbbbb-2222-2222-2222-bbbbbbbbbbbb',
    '55555555-5555-5555-5555-555555555555'
);

SELECT reservation_id, item_id, user_id
FROM reservations
WHERE reservation_id = '44444444-dddd-dddd-dddd-dddddddddddd';


-- Check the Books list, change the description.
SELECT name, description
FROM wishlists
WHERE wishlist_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

UPDATE wishlists
SET description = 'Books I plan to read this year'
WHERE wishlist_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';


-- Check the keyboard, mark it as received.
SELECT name, is_completed
FROM wishlist_items
WHERE item_id = 'dddddddd-4444-4444-4444-dddddddddddd';

UPDATE wishlist_items
SET is_completed = TRUE
WHERE item_id = 'dddddddd-4444-4444-4444-dddddddddddd';


-- Check Daria's Coffee Machine reservation, cancel it.
SELECT reservation_id, item_id, user_id
FROM reservations
WHERE reservation_id = '44444444-dddd-dddd-dddd-dddddddddddd';

DELETE FROM reservations
WHERE reservation_id = '44444444-dddd-dddd-dddd-dddddddddddd';


-- Check Clean Code, delete it.
SELECT item_id, name
FROM wishlist_items
WHERE item_id = 'cccccccc-3333-3333-3333-cccccccccccc';

DELETE FROM wishlist_items
WHERE item_id = 'cccccccc-3333-3333-3333-cccccccccccc';
