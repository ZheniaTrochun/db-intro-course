
select
    status,
    count(*) as rides_count
from ride
group by status
order by rides_count desc;

select
    payment_method,
    status,
    count(*) as payments_count,
    sum(amount) as total_amount
from payment
group by payment_method, status
order by payment_method, status;