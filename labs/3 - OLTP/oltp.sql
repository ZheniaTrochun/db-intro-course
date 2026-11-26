-- SELECT ----------------------------------------------------------------------------------------------------
-- Venue page: one VENUE by id with CITY name
select name,
    address
from venue
where venue_id = 1;
-- Venues with a given FEATURE
select name,
    address
from venue
where venue_id in (
        select venue_id
        from venue_feature
        where feature_id in (
                select feature_id
                from feature
                where name = 'Працює допізна'
            )
    );
-- Available MENU_ITEMs of a venue under a price
select name,
    description,
    price
from menu_item
where venue_id = 2
    and price < 200;
-- Latest visible REVIEWs of a venue, ORDER BY created_at DESC LIMIT n
select *
from review
where venue_id = 1
    and status = 'visible'
order by created_at desc
limit 5;
-- A user's FAVORITE venues
select name,
    address
from venue
where venue_id in (
        select venue_id
        from favorite
        where user_id = 1
    );
-- INSERT ------------------------------------------------------------------------------------------
-- New USERS row
insert into users (email, pass_hash, display_name)
values (
        'bimbimbambam@gmail.com',
        'verycoolpasshash',
        'Dima'
    );
-- New VENUE
insert into venue (
        city_id,
        name,
        description,
        address,
        latitude,
        longitude,
        phone_number,
        website
    )
values (
        1,
        'Кавярня Світло',
        'Затишна кавярня у центрі міста зі свіжою випічкою та спешелті кавою.',
        'вул. Хрещатик, 24',
        50.4475,
        30.5225,
        '+380501234567',
        'https://svitlo-coffee.example.com'
    );
-- New REVIEW
insert into review (
        venue_id,
        user_id,
        rating,
        text,
        visited_on
    )
values (
        1,
        1,
        10,
        'Дуже приємний заклад у центрі міста. Смачна кава, свіжа випічка та ввічливий персонал. Обов язково завітаю сюди ще раз.',
        now()
    );
-- New REVIEW_COMMENT
insert into review_comment (review_id, text, is_official)
values (
        1,
        'Дякуємо за відгук! Раді, що все сподобалося, чекаємо вас знову.',
        true
    );
-- New FAVORITE row
insert into favorite (user_id, venue_id)
values (2, 3), (3, 3);
-- New VENUE_STAFF row
INSERT INTO VENUE_STAFF (
    venue_id,
    user_id,
    role,
    added_by
)
VALUES (
    2,
    3,
    'manager',
    1
);

-- New REVIEW row (rating 1-10)
INSERT INTO REVIEW (
    venue_id,
    user_id,
    rating,
    text,
    visited_on
)
VALUES (
    2,
    3,
    9,
    'Класна шаурмечна поруч із метро. Велика порція, соковите мясо і свіжі овочі. Готують швидко, однозначно прийду ще.',
    '2026-11-25'
);
-- New REVIEW row
INSERT INTO REVIEW (
    venue_id,
    user_id,
    rating,
    text,
    visited_on
)
VALUES (
    2,
    2,
    5,
    'Лаваш був холодний, а соусу майже не було. Сподіваюся, наступного разу буде краще.',
    '2026-11-20'
);
-- Official comment from venue staff
INSERT INTO REVIEW_COMMENT (
    review_id,
    user_id,
    text,
    is_official
)
VALUES (
    CURRVAL(pg_get_serial_sequence('review', 'review_id')),
    8,
    'Перепрошуємо за незручності! Ми вже поговорили з кухнею, чекаємо вас знову.',
    TRUE
);
-- Reply to the official comment
INSERT INTO REVIEW_COMMENT (
    review_id,
    user_id,
    parent_comment_id,
    text
)
VALUES (
    CURRVAL(pg_get_serial_sequence('review', 'review_id')),
    2,
    CURRVAL(pg_get_serial_sequence('review_comment', 'review_comment_id')),
    'Дякую за відповідь, обов’язково дам закладу ще один шанс.'
);
-- Top-level comment from another user
INSERT INTO REVIEW_COMMENT (
    review_id,
    user_id,
    text
)
VALUES (
    CURRVAL(pg_get_serial_sequence('review', 'review_id')),
    1,
    'У мене минулого тижня був схожий досвід.'
);
-- Photos attached to the review
INSERT INTO PHOTO (
    review_id,
    uploaded_by,
    url
)
VALUES (
    CURRVAL(pg_get_serial_sequence('review', 'review_id')),
    2,
    'https://images.example.com/review-cold-lavash-1.jpg'
),
(
    CURRVAL(pg_get_serial_sequence('review', 'review_id')),
    2,
    'https://images.example.com/review-cold-lavash-2.jpg'
);
-- New USERS row (for testing ON DELETE SET NULL)
INSERT INTO USERS (
    email,
    pass_hash,
    display_name
)
VALUES (
    'roman@example.com',
    'totallyrealhash1234',
    'Роман'
);
-- Reviews by the new user
INSERT INTO REVIEW (
    venue_id,
    user_id,
    rating,
    text,
    visited_on
)
VALUES (
    1,
    (
        SELECT user_id
        FROM USERS
        WHERE email = 'roman@example.com'
    ),
    8,
    'Шаурма соковита, порція велика. Трохи довго чекав на замовлення.',
    '2026-11-15'
),
(
    3,
    (
        SELECT user_id
        FROM USERS
        WHERE email = 'roman@example.com'
    ),
    6,
    'Непогана шаурма біля моря, але ціни трохи завищені.',
    '2026-11-22'
);
-- UPDATE ------------------------------------------------------------------------------------------
-- Moderator approves a venue
update venue
set status = 'approved'
where venue_id = 3;
update moderation_action
set moderator_id = 1,
    action = 'approve',
    note = 'norm venue ya tam iv smachno',
    created_at = now()
where venue_id = 2;
-- Edit a review
update review
set rating = 2,
    text = 'Продавець увімкнув фонк на всю вулицю і розкрутив вертел так що обляпав всіх біля закладу. Не рекомендую.',
    updated_at = now(),
    visited_on = '2026-11-21'
where review_id = 1;
-- Hide a review
update review
set status = 'hidden'
where review_id = 2;
-- Soft-delete a user
update users
set status = 'deleted',
    deleted_at = now()
where user_id = 1;
-- End a PROMOTION manually
update promotion
set status = 'ended',
    ends_at = now(),
    review_note = 'Закінчилась акція, бо заклад закрився'
where promotion_id = 1;
-- DELETE ---------------------------------------------------------------------
-- Remove a FAVORITE
DELETE FROM FAVORITE
WHERE user_id = 3
    AND venue_id = 3;
-- Remove a VENUE_STAFF row
DELETE FROM VENUE_STAFF
WHERE venue_id = 2
    AND user_id = 3;
-- Delete a review (ON DELETE CASCADE on comments and photos)
DELETE FROM REVIEW
WHERE review_id = 8;
-- Delete a user (ON DELETE SET NULL on reviews)
DELETE FROM USERS
WHERE user_id = 10;
-- Delete a review
DELETE FROM REVIEW
WHERE review_id = 7;