-- inner join: поїздки з призначеним водієм, авто та класом авто
select r.ride_id, r.status, 
p.first_name || ' ' || p.last_name as passenger_name, 
d.first_name || ' ' || d.last_name as driver_name,
cc.car_class_name, 
c.make || ' ' || c.model || ' (' || c.license_plate || ')' as car_info,
r.price
from ride r 
join passenger p 
on r.passenger_id = p.passenger_id
join driver d
on r.driver_id = d.driver_id
join car c
on r.car_id = c.car_id
join car_class cc
on r.requested_car_class_id = cc.car_class_id
order by r.ride_id;