## Функціональні залежності  початкової схеми у форматі X -> Y:
*   brand.brand_id -> brand.brand_title
*   category.category_id -> category.category_title
*   customer.customer_id -> customer.customer_first_name, customer.customer_last_name, customer.customer_birth_date, customer.customer_email, customer.customer_phone_number
*   orders.orders_id -> orders.customer_id, orders.orders_date, orders.orders_status, orders.orders_delivery_address, orders.orders_price
*   product.product_id -> product.brand_id, product.category_id, product.product_title, product.product_price, product.product_pao_months, product.product_expiration_date, product.product_application_method, product.product_volume
*   order_item.id -> order_item.product_id, order_item.order_id, order_item.quantity, order_item.price

## Найвища нормальна форма початкової схеми та її порушення
*   **Найвища нормальна форма початкової ER-діаграми:** 1NF (Перша нормальна форма).
*   **Обґрунтування:** Усі атрибути на початковій діаграмі є атомарними, в комірках немає списків чи масивів значень через кому.
    1.  **Порушення 2NF в елементах замовлення (Часткова залежність):** Початкова таблиця Order Item використовувала простий ключ id. Проте неключові атрибути quantity(кількість) та price(ціна) логічно залежать не від id, а від комбінації замовлення order_id та товару product_id разом. Наявність простого ключа маскувала цю залежність і створювала ризик появи дубльованих рядків для одного й того самого товару в межах одного чека.
    2.  **Порушення 3NF в товарах (Транзитивна залежність):** Пряме включення поля `category_id` у таблицю `Product` створювало жорсткий зв'язок «один-до-багатьох». Це робило неможливою ситуацію, коли один товар належить одночасно до кількох категорій без дублювання всього рядка товару та супутніх описів.

## Покроковий процес декомпозиції та переходу до 3NF

### 1. Перехід до 1NF 
Схема з самого початку задовольняє критеріям 1NF. 

### 2. Перехід до 2NF (Усунення часткових залежностей)
*   **Модифікація:** У фінальному SQL-коді та оновленій ER-діаграмі з таблиці order_item було повністю видалено простий ключ id. Замість нього я створила складений первинний ключ PRIMARY KEY (orders_id, product_id).
*   **Логічне обґрунтування:** Після заміни неключові атрибути кількості quantity та зафіксованої ціни price повно функціонально залежать від усього складеного ключа разом, який утворений від `product_id` та `orders_id`. Часткові залежності відсутні, таблиця повністю відповідає критеріям 2NF.

### 3. Перехід до 3NF (Усунення транзитивних залежностей)
*   **Модифікація:** З таблиці product я видалила стовпець category_id. Замість нього я створила нову таблицю product_category, первинний ключ якої є складеним і побудований з полів product_id та category_id.
*   **Логічне обґрунтування:** Це дозволило реалізувати зв'язок багато-до-багатьох між товарами та категоріями через два зв'язки один-до-багатьох. Усі неключові атрибути товарів тепер залежать виключно від свого первинного ключа product_id. Транзитивні аномалії та дублювання описів ліквідовано, схема повністю перебуває в 3NF.

## Інші зміни впроваджені під час виконання лабораторних робіт
### Модернізація ідентифікаторів (Перехід від SERIAL до IDENTITY)
```sql
ALTER TABLE brand ALTER COLUMN brand_id DROP DEFAULT, 
ALTER COLUMN brand_id ADD GENERATED ALWAYS AS IDENTITY;

ALTER TABLE category ALTER COLUMN category_id DROP DEFAULT, 
ALTER COLUMN category_id ADD GENERATED ALWAYS AS IDENTITY;

ALTER TABLE customer ALTER COLUMN customer_id DROP DEFAULT, 
ALTER COLUMN customer_id ADD GENERATED ALWAYS AS IDENTITY;

ALTER TABLE product ALTER COLUMN product_id DROP DEFAULT, 
ALTER COLUMN product_id ADD GENERATED ALWAYS AS IDENTITY;

ALTER TABLE orders ALTER COLUMN orders_id DROP DEFAULT, 
ALTER COLUMN orders_id ADD GENERATED ALWAYS AS IDENTITY;
```
### Зміна типу статусів замовлень 
```sql
ALTER TABLE orders ALTER COLUMN orders_status TYPE VARCHAR(50);
DROP TYPE IF EXISTS order_status_type;
CREATE TYPE order_status_type AS ENUM ('New', 'In Progress', 'Shipped', 'Delivered', 'Cancelled');
ALTER TABLE orders ALTER COLUMN orders_status TYPE order_status_type USING orders_status::order_status_type;
```
