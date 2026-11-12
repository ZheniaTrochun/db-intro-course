select count(orders.order_id) as total_orders
from orders;

select o.shipping_method, count(shipping_method) as count_deliver
from orders o
group by shipping_method
having count(shipping_method) >= 2;

select product_id, sum(quantity) as product_in_all_orders
from order_product
group by product_id;

select extract(MONTH FROM o.order_date) as month, count(order_id) as order_in_month
from orders o
group by extract(MONTH FROM o.order_date);


select c.name, a.city
from address a
right join customer c on a.customer_id = c.customer_id;

select c.name, count(o.order_id) as order_count
from orders o
join customer c on o.customer_id = c.customer_id
group by c.name;

select c.name, count(DISTINCT a.address_id) as address_count, count(DISTINCT pd.payment_data_id) as payment_count
from customer c
left join address a on c.customer_id = a.customer_id
left join payment_data pd on c.customer_id = pd.customer_id
group by c.name;


select name, price
from product
where price = (select max(price) from product);

select name
from customer
where customer_id in (select customer_id from orders);

select name, price
from product
where price > (select avg(price) from product);