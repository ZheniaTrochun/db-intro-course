
select
    count(*) as total_rides,
    sum(price) as total_price,
    round(avg(price), 2) as avg_price,
    min(price) as min_price,
    max(price) as max_price
from ride;

select
    count(*) as total_rows,
    count(rating) as rated_passengers,
    round(avg(rating), 2) as avg_rating
from passenger;