-- SELECT ----------------------------------------------------------------------------------------------------
-- Venue page: one VENUE by id with CITY name (only needed columns)
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
----------------------------------------------------------------------------------------------------
-- INSERT ------------------------------------------------------------------------------------------
-- New USERS row (watch the email UNIQUE and role/status enum defaults)
insert into users (
    email,
    pass_hash,
    display_name
)
values (
    'bimbimbambam@gmail.com',
    'verycoolpasshash',
    'Dima'
);
-- New VENUE (defaults to pending)
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
-- New REVIEW (rating 1-10)
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
-- New REVIEW_COMMENT with is_official = TRUE from venue staff
insert into review_comment (
    review_id,
    text,
    is_official
)
values (
    1,
    'Дякуємо за відгук! Раді, що все сподобалося, чекаємо вас знову.',
    true
);
-- New FAVORITE row
insert into favorite (
    user_id,
    venue_id
)
values (
    2,
    3
);