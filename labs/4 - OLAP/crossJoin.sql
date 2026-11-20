-- cross join: всі комбінації машин та класів
select
c.license_plate,
c.make || ' ' || c.model as car_model,
cc.car_class_name
from car c
cross join car_class cc
order by c.car_id, cc.car_class_id;