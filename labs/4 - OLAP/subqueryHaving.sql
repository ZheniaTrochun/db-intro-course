-- Водії, чия сумарна виручка за поїздками вища за середню виручку на одного активного водія
select d.driver_id,
d.first_name || ' ' || d.last_name as driver_name,
d.status as driver_status,
count(r.ride_id) as rides_count,
sum(r.price) as total_ride_amount
from driver d
join ride r
on d.driver_id = r.driver_id
group by d.driver_id
having sum(r.price) > (
 	select avg(driver_sum) from (
  		select sum(r2.price) as driver_sum
 		from ride r2
 	 	where r2.driver_id is not null
  		group by r2.driver_id
 	)sub_driver_totals
)
order by total_ride_amount desc;