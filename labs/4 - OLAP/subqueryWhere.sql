select 
p.passenger_id,
p.first_name || ' ' || p.last_name as passenger_name,
p.phone_number,
p.rating
from passenger p
where p.passenger_id in (
select r.passenger_id 
from ride r
where r.status = 'COMPLETED'
);
