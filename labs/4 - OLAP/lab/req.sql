select count(*) as total_products
from product;

select round(avg(price), 2) as avg_price
from product;

select min(price) as min_price
from product;

select max(price) as max_price
from product;

select sum(quantity) as total_ordered_quantity
from supply_order;

select category_id, count(*) as products_count
from product
group by category_id;

select location_id, sum(quantity) as total_quantity
from stock
group by location_id
having sum(quantity) > 30;

select p.name as product_name, c.name as category_name, p.price
from product p
inner join category c on p.category_id = c.category_id;

select l.name as location_name, st.product_id, st.quantity
from location l
left join stock st on l.location_id = st.location_id;

select c.name as category_name, p.name as product_name
from product p
right join category c on p.category_id = c.category_id;

select l.name as location_name, sum(st.quantity * p.price) as total_inventory_value
from location l
join stock st on l.location_id = st.location_id
join product p on st.product_id = p.product_id
group by l.location_id;

select name, price
from product
where price > (
    select avg(price)
    from product
);

select name, price, (select round(avg(price), 2) from product) as avg_catalog_price
from product;

select location_id, sum(quantity) as total_quantity
from stock
group by location_id
having sum(quantity) > (
    select avg(quantity)
    from stock
);