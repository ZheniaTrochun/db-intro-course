-- left join + inner join: Усі поїздки + інформація про водія та оплату
select r.ride_id, r.status,
p.first_name || ' ' || p.last_name as passenger_name,
coalesce (d.first_name || ' ' || d.last_name, 'невідомо') as driver_name,
r.price as ride_price,
coalesce (pay.status::text, 'немає') as payment_status
from ride r
join passenger p
using(passenger_id)
left join driver d
using(driver_id)
left join payment pay
on r.ride_id = pay.ride_id
order by ride_price;