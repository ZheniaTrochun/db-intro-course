-- Вартість кожної поїздки у порівнянні із середньою ціною поїздки в сервісі
select 
r.ride_id,
r.status,
r.price,
round (
(select avg(r2.price) from ride r2 ),2

) as  avg_ride_price,
round(
r.price - (select avg(r2.price) from ride r2), 2
) as diff_from_avg
from ride r;