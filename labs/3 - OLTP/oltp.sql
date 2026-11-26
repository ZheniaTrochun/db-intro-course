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