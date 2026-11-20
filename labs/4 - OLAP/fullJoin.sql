-- full join: повна звірка поїздок і платежів
select r.ride_id,
r.status as ride_status,
r.price as ride_price,
pay.payment_id,
pay.payment_method,
pay.status as payment_status,
pay.amount as paid_amount
from ride r
full join payment pay
on r.ride_id = pay.ride_id
order by r.ride_id nulls last, pay.payment_id nulls last;