INSERT INTO users (name, email, password_hash)
VALUES
    ('Maria', 'maria@example.com', 'hash_maria'),
    ('Anna', 'anna@example.com', 'hash_anna'),
    ('Olena', 'olena@example.com', 'hash_olena'),
    ('Sofia', 'sofia@example.com', 'hash_sofia'),
    ('Daria', 'daria@example.com', 'hash_daria');


INSERT INTO wishlists (user_id, name, description, is_public)
VALUES
    ((SELECT user_id FROM users WHERE email = 'maria@example.com'),
     'Birthday Wishlist',
     'Things I would like to receive for my birthday',
     TRUE),

    ((SELECT user_id FROM users WHERE email = 'maria@example.com'),
     'Books',
     'Books I want to read',
     TRUE),

    ((SELECT user_id FROM users WHERE email = 'anna@example.com'),
     'Tech Wishlist',
     'Useful technology and accessories',
     TRUE),

    ((SELECT user_id FROM users WHERE email = 'olena@example.com'),
     'Private Wishlist',
     'Personal items',
     FALSE);


INSERT INTO wishlist_items
    (wishlist_id, name, description, price, product_url, image_url, is_completed)
VALUES
    ((SELECT wishlist_id FROM wishlists WHERE name = 'Birthday Wishlist'),
     'Wireless Headphones',
     'Noise cancelling headphones',
     199.99,
     'https://example.com/headphones',
     NULL,
     FALSE),

    ((SELECT wishlist_id FROM wishlists WHERE name = 'Birthday Wishlist'),
     'Coffee Machine',
     'Automatic coffee machine',
     349.00,
     'https://example.com/coffee-machine',
     NULL,
     FALSE),

    ((SELECT wishlist_id FROM wishlists WHERE name = 'Books'),
     'Clean Code',
     'Book about software craftsmanship',
     45.50,
     'https://example.com/clean-code',
     NULL,
     TRUE),

    ((SELECT wishlist_id FROM wishlists WHERE name = 'Tech Wishlist'),
     'Mechanical Keyboard',
     'Mechanical keyboard for programming',
     120.00,
     'https://example.com/keyboard',
     NULL,
     FALSE),

    ((SELECT wishlist_id FROM wishlists WHERE name = 'Tech Wishlist'),
     'USB-C Hub',
     'Multi-port USB-C adapter',
     59.99,
     'https://example.com/usb-hub',
     NULL,
     FALSE);


INSERT INTO reservations (item_id, user_id)
VALUES
    ((SELECT item_id FROM wishlist_items WHERE name = 'Wireless Headphones'),
     (SELECT user_id FROM users WHERE email = 'anna@example.com')),

    ((SELECT item_id FROM wishlist_items WHERE name = 'Mechanical Keyboard'),
     (SELECT user_id FROM users WHERE email = 'sofia@example.com')),

    ((SELECT item_id FROM wishlist_items WHERE name = 'USB-C Hub'),
     (SELECT user_id FROM users WHERE email = 'olena@example.com'));
