# Лабораторна робота №5. Нормалізація бази даних

## Тема: інтернет-магазин.

### Виконали, група ІМ-51:

Брижниченко Злата Володимирівна,
Дмитрієнко Вікторія Андріївна,
Бескровна Олександра Вікторівна.

## Мета й результат

Перевірити схему інтернет-магазину з ЛР №2 і привести її до 3НФ. У початковій таблиці `orders` покупець визначався адресою доставки й водночас зберігався окремо. Після нормалізації покупця отримуємо через `orders.address_id → address.address_id → address.customer_id → customer.customer_id`. Зберігаються всі вісім таблиць і всі початкові тестові дані.

## Початкова схема та функціональні залежності

За основу взято ER-модель ЛР №1 і реалізацію ЛР №2. Залежності визначаємо за ключами, обмеженнями та правилами магазину. Збіг значень у тестових даних сам по собі не є залежністю.

У таблиці наведено кандидатні ключі (перший у кожному рядку є первинним) і мінімальне покриття нетривіальних функціональних залежностей. Запис `X → a, b` означає окремі залежності `X → a` та `X → b`. Стовпці кожної таблиці перелічено у ключах і залежностях.

| Таблиця | Кандидатні ключі | Мінімальне покриття | Найвища з перевірених форм |
|---|---|---|---|
| `customer` | `customer_id`, `email` | `email → customer_id`; `customer_id → first_name, last_name, email, phone, registered_at` | 3НФ |
| `address` | `address_id` | `address_id → customer_id, city, street, building, postal_code` | 3НФ |
| `category` | `category_id`, `name` | `name → category_id`; `category_id → name, description` | 3НФ |
| `product` | `product_id` | `product_id → category_id, name, description, price, stock_qty` | 3НФ |
| `orders` | `order_id` | `order_id → address_id, order_date, status`; `address_id → customer_id` | 2НФ |
| `order_item` | `(order_id, product_id)` | `(order_id, product_id) → quantity, unit_price` | 3НФ |
| `payment` | `payment_id` | `payment_id → order_id, amount, method, paid_at, status` | 3НФ |
| `review` | `review_id`, `(customer_id, product_id)` | `(customer_id, product_id) → review_id`; `review_id → customer_id, product_id, rating, comment, created_at` | 3НФ |

`(address_id, customer_id)` у `address` — надключ, але не кандидатний ключ, бо самого `address_id` достатньо. У `payment` статус визначає, чи має час оплати бути заповненим, але не визначає конкретний час: успішні платежі можуть мати різні `paid_at`.

### Атрибути та ключі на етапах 1НФ і 2НФ

Початкова схема вже відповідає 1НФ і 2НФ. Тому наведений перелік однаковий для обох етапів. PK — первинний ключ, FK — зовнішній ключ, UQ — обмеження унікальності.

| Таблиця | Атрибути | Ключі та посилання |
|---|---|---|
| `customer` | `customer_id, first_name, last_name, email, phone, registered_at` | PK: `customer_id`; UQ: `email` |
| `address` | `address_id, customer_id, city, street, building, postal_code` | PK: `address_id`; FK: `customer_id → customer`; UQ: `(address_id, customer_id)` |
| `category` | `category_id, name, description` | PK: `category_id`; UQ: `name` |
| `product` | `product_id, category_id, name, description, price, stock_qty` | PK: `product_id`; FK: `category_id → category` |
| `orders` | `order_id, customer_id, address_id, order_date, status` | PK: `order_id`; FK: `customer_id → customer`, `(address_id, customer_id) → address` |
| `order_item` | `order_id, product_id, quantity, unit_price` | PK: `(order_id, product_id)`; FK: `order_id → orders`, `product_id → product` |
| `payment` | `payment_id, order_id, amount, method, paid_at, status` | PK: `payment_id`; FK: `order_id → orders` |
| `review` | `review_id, customer_id, product_id, rating, comment, created_at` | PK: `review_id`; FK: `customer_id → customer`, `product_id → product`; UQ: `(customer_id, product_id)` |
