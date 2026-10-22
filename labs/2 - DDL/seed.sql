INSERT INTO users (user_id, name, email, password_hash)
VALUES
    ('11111111-1111-1111-1111-111111111111',
     'Maria',
     'maria@example.com',
     'hash_maria'),

    ('22222222-2222-2222-2222-222222222222',
     'Anna',
     'anna@example.com',
     'hash_anna'),

    ('33333333-3333-3333-3333-333333333333',
     'Olena',
     'olena@example.com',
     'hash_olena'),

    ('44444444-4444-4444-4444-444444444444',
     'Sofia',
     'sofia@example.com',
     'hash_sofia');


INSERT INTO wishlists
    (wishlist_id, user_id, name, description, is_public)
VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
     '11111111-1111-1111-1111-111111111111',
     'Birthday Wishlist',
     'Things I would like to receive for my birthday',
     TRUE),

    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
     '11111111-1111-1111-1111-111111111111',
     'Books',
     'Books I want to read',
     TRUE),

    ('cccccccc-cccc-cccc-cccc-cccccccccccc',
     '22222222-2222-2222-2222-222222222222',
     'Tech Wishlist',
     'Useful technology and accessories',
     TRUE),

    ('dddddddd-dddd-dddd-dddd-dddddddddddd',
     '33333333-3333-3333-3333-333333333333',
     'Private Wishlist',
     'Personal items',
     FALSE);


INSERT INTO wishlist_items
    (item_id, wishlist_id, name, description, price,
     product_url, image_url, is_completed)
VALUES
    ('aaaaaaaa-1111-1111-1111-aaaaaaaaaaaa',
     'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
     'Wireless Headphones',
     'Noise cancelling headphones',
     199.99,
     'https://example.com/headphones',
     NULL,
     FALSE),

    ('bbbbbbbb-2222-2222-2222-bbbbbbbbbbbb',
     'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
     'Coffee Machine',
     'Automatic coffee machine',
     349.00,
     'https://example.com/coffee-machine',
     NULL,
     FALSE),

    ('cccccccc-3333-3333-3333-cccccccccccc',
     'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
     'Clean Code',
     'Book about software craftsmanship',
     45.50,
     'https://example.com/clean-code',
     NULL,
     TRUE),

    ('dddddddd-4444-4444-4444-dddddddddddd',
     'cccccccc-cccc-cccc-cccc-cccccccccccc',
     'Mechanical Keyboard',
     'Mechanical keyboard for programming',
     120.00,
     'https://example.com/keyboard',
     NULL,
     FALSE),

    ('eeeeeeee-5555-5555-5555-eeeeeeeeeeee',
     'cccccccc-cccc-cccc-cccc-cccccccccccc',
     'USB-C Hub',
     'Multi-port USB-C adapter',
     59.99,
     'https://example.com/usb-hub',
     NULL,
     FALSE);


INSERT INTO reservations
    (reservation_id, item_id, user_id)
VALUES
    ('11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
     'aaaaaaaa-1111-1111-1111-aaaaaaaaaaaa',
     '22222222-2222-2222-2222-222222222222'),

    ('22222222-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
     'dddddddd-4444-4444-4444-dddddddddddd',
     '44444444-4444-4444-4444-444444444444'),

    ('33333333-cccc-cccc-cccc-cccccccccccc',
     'eeeeeeee-5555-5555-5555-eeeeeeeeeeee',
     '33333333-3333-3333-3333-333333333333');