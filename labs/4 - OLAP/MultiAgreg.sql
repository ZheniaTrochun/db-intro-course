
select
    d.driver_id,
    d.first_name || ' ' || d.last_name as driver_name,
    count(r.ride_id) as rides_count,
    coalesce(sum(r.price), 0) as total_revenue,
    coalesce(round(avg(r.price), 2), 0) as avg_ride_price
from driver d
left join ride r on d.driver_id = r.driver_id
group by d.driver_id, d.first_name, d.last_name
order by total_revenue desc, d.driver_id;

select
    cc.car_class_name,
    count(r.ride_id) as rides_count,
    coalesce(sum(r.price), 0) as total_revenue,
    coalesce(round(avg(r.price), 2), 0) as avg_price
from car_class cc
left join ride r on cc.car_class_id = r.requested_car_class_id
group by cc.car_class_id, cc.car_class_name
order by total_revenue desc;