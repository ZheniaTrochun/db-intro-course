select count(*) as total_products
from product;

-- Тут все зрозуміло, рахується кількість записів продуктів у таблиці, замість * можна було рахувати по id бо він тоже унікальний і не null

select round(avg(price), 2) as avg_price
from product;

-- Теж нічого цікавого середня ціна, з округленням до 2 знаків, далі такі запити пояснювати не буду
select min(price) as min_price
from product;

select max(price) as max_price
from product;

select sum(quantity) as total_ordered_quantity
from supply_order;

select category_id, count(*) as products_count
from product
group by category_id;

-- Тут продукти групуються по категоріям і далі рахується кількість продуктів в кожній групі(категорії)

select location_id, sum(quantity) as total_quantity
from stock
group by location_id
having sum(quantity) > 30;

-- оскільки where використовується до group by, то через having обираємо групи з сумою > 30

select p.name as product_name, c.name as category_name, p.price
from product p
inner join category c on p.category_id = c.category_id;

-- тут через inner join залишатсья тільки продукти які мають категорію, ну і виведуться якісь поля

select l.name as location_name, st.product_id, st.quantity
from location l
left join stock st on l.location_id = st.location_id;

-- тут всі локації залишаться, а якщо на якійсь локації немає запасів то у відповідних поялх продукт і кілкьість будуть null

select c.name as category_name, p.name as product_name
from product p
right join category c on p.category_id = c.category_id;

-- тут зліва product, а справа category, відповідно всі категорії залишаться а якщо у них немає продуктів то в колонці продукт буде null

select l.name as location_name, sum(st.quantity * p.price) as total_inventory_value
from location l
join stock st on l.location_id = st.location_id
join product p on st.product_id = p.product_id
group by l.location_id;

-- тут join-ться 2 таблиці, групується по локаціям і тоді через join stock в кожній групі у нас є запаси продуктів на цій локації
-- а через join з product у нас є доступ до самих продуктів в запасах і відповідно до цін, що дозволяє порахувати ціню всіх продуктів на локації 


select name, price
from product
where price > (
    select avg(price)
    from product
);

-- Тут в where потрібен окремий select, оскільки в where не можна напряму писати агрегатні функції 

select name, price, (select round(avg(price), 2) from product) as avg_catalog_price
from product;

-- Тут потрібен окремий select оскільки select name, price дасть нам багато рядків а агрегатна функція 1, оскільки нормально склеїти 1 і багато рядків не можливо
-- потрібен select щоб це значення дублювалося в кожному рядку (внутрішній select обчислиться раньше за where і перетвориться на звичайне знач)

select location_id, sum(quantity) as total_quantity
from stock
group by location_id
having sum(quantity) > (
    select avg(location_quantity)
    from (
        select sum(quantity) as location_quantity
        from stock
        group by location_id
    ) as ls
);

-- тут потрібен окремий select бо group by поділить все на групи по локаціям але мене тут цікавило вивести ті локації де запаси
-- більші за середні по всім локаціям а якщо залишити вираз в having як sum(quantity) > avg(quantity) то це avg(quantity) також буде рахуватися
-- для кожної групи а не по всій таблиці і відповідно така умова завжди буде виконана (ну або майже завжди)

-- доречі коли писав пояснення зрозумів, що я порівнював не кількість товарів на локації з середньою кільк. по локаціям а з середньою кільк.
-- кожного продукту в межах одного запасу(ну може трохи складно написав), тому хоч фактично він і працював але не так як хотілося тому я це виправив
-- додавши замість select avg(qunatity), select який спочатку групує все по локаціям? рахує кількість товарів для кожної локації
-- потім вже знаходить середнє для всіх локацій а не всіх запасів і потім відповідно порівнює середнє з кожною локацією окремо 