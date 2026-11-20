-- right join: усі автомобілі з парку та кількість поїздок на кожному
select c.car_id,
c.license_plate,
c.make || ' ' || c.model as car_model,
cc.car_class_name,
count(r.ride_id) as rides_count,
coalesce(sum(r.price), 0) as total_revenue
from ride r
right join car c
on r.car_id = c.car_id
join car_class cc
on c.car_class_id = cc.car_class_id
group by c.car_id, cc.car_class_name
order by rides_count desc, c.car_id;