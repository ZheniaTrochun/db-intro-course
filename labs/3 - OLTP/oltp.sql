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
values (2, 3);
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
----------------------------------------------------------------------------------------------------