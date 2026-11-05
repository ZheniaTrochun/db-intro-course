INSERT INTO customer (name, email, password_hash, phone, deleted_at) VALUES
    ('Tetiana Pet',  'tetiana@example.com',  '$2b$12$hash_tetiana',  '+3809533455', NULL);

SELECT * FROM customer;

INSERT INTO product (name, description, price, stock_quantity, deleted_at) VALUES
    ('Фен Dreame Pocket','1300 Вт, 0.3 кг', 3999, 20, NULL);

SELECT * FROM product;

select customer_id, status
from orders
where status = 'Delivered';

select name, deleted_at
from customer
where deleted_at IS NULL;

update orders
set shipping_method = 'Самовивіз'
where order_id = 1;
select shipping_address_id, shipping_method
from orders;

update product
set price = 999
where product_id = 1;
select product_id, name, price
from product;

delete from address
where address_id = 2;
select address_id, customer_id, city
from address;

delete from order_product
where order_id = 2 AND product_id = 4;
select order_id, product_id
from order_product;