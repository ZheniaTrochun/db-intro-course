
select
    requested_car_class_id,
    count(*) as rides_count,
    round(avg(price), 2) as avg_price
from ride
group by requested_car_class_id
having avg(price) > 150;

select
    author_type,
    count(*) as reviews_count,
    round(avg(rating), 2) as avg_rating
from review
group by author_type
having count(*) >= 1 and avg(rating) >= 4.5;