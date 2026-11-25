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

## Етапи нормалізації

1. **Перевірка 1НФ.** Кожне поле містить одне значення, без списків і повторюваних груп. Адреси клієнта, позиції замовлення та платежі вже представлені окремими рядками. На етапі 1НФ таблиці, атрибути та ключі залишаються такими, як у початковій схемі.
2. **Перевірка 2НФ.** Часткових залежностей немає. В `order_item` кількість і ціна продажу залежать від усієї пари `(order_id, product_id)`: ціна продажу може відрізнятися між замовленнями. У `review` потрібна вся пара `(customer_id, product_id)` або `review_id`. Решта таблиць має лише прості кандидатні ключі. На етапі 2НФ таблиці, атрибути та ключі не змінюються.
3. **Перехід до 3НФ.** Початкова схема в цілому перебуває у 2НФ: в `orders` є транзитивна залежність `order_id → address_id → customer_id`. Кожна адреса має одного власника, а складений зовнішній ключ гарантує збіг власника з покупцем. Адреса може використовуватися в кількох замовленнях, тож `address_id` не є надключем `orders`. Усуваємо дублювання, залишаючи `customer_id` у `address`.

| Таблиця | До нормалізації (1НФ і 2НФ) | Після нормалізації (3НФ) |
|---|---|---|
| `orders` | `order_id` (PK), `customer_id` (FK → `customer`), `address_id`, `order_date`, `status`; складений FK `(address_id, customer_id)` → `address` | `order_id` (PK), `address_id` (FK → `address`), `order_date`, `status` |
| `address` | `address_id` (PK), `customer_id` (FK → `customer`), `city`, `street`, `building`, `postal_code`; `UNIQUE (address_id, customer_id)` | Ті самі атрибути, PK і FK. Складене `UNIQUE` прибрано, бо новий FK посилається лише на `address_id`. |

**Аномалія вставки й оновлення.** У початковій схемі під час вставки замовлення треба було повторно ввести покупця, хоча його визначає адреса. При зміні адреси на адресу іншого клієнта два значення довелося б оновити разом: інакше складений FK відхилив би запис. У новій схемі власника отримуємо через адресу. Окремої аномалії видалення в цьому випадку немає: видалення замовлення не видаляє адресу.

Старе поле `orders.customer_id` відновлюється з’єднанням з `address` за `address_id` без втрати даних. У `orders` залишається `order_id → address_id, order_date, status`. Решта шести таблиць не змінюється; усі таблиці відповідають 3НФ за визначеними залежностями.

За правилами ЛР №1 використану адресу не перезаписуємо: зміна оформлюється новим записом. Це стосується і її власника, оскільки після нормалізації зміна власника використаної адреси змінила б покупця всіх пов’язаних замовлень. Зовнішні ключі перевіряють існування записів, але цього правила про незмінність не забезпечують.

## Перехід зі схеми ЛР №2

```sql
BEGIN;

ALTER TABLE orders
    DROP CONSTRAINT fk_orders_address_customer,
    DROP CONSTRAINT fk_orders_customer,
    DROP COLUMN customer_id,
    ADD CONSTRAINT fk_orders_address
        FOREIGN KEY (address_id) REFERENCES address (address_id);

ALTER TABLE address
    DROP CONSTRAINT uq_address_customer;

COMMIT;
```

## Фінальна схема та ER-діаграма

[ER-діаграма](./er-diagram.png) показує фізичну схему після нормалізації. У `orders` є один FK для адреси: `orders.address_id → address.address_id`. Власника знаходимо через `address.customer_id → customer.customer_id`. Прямого зв’язку `orders → customer` більше немає. Решта атрибутів і ключів відповідають списку для 1НФ і 2НФ, крім двох змін, описаних у таблиці «До / після».

У [schema.sql](./schema.sql) є повні команди `CREATE TABLE` з типами, PK, FK, `UNIQUE` і `CHECK`. У [seed.sql](./seed.sql) вставки для `orders` містять лише `address_id, order_date, status`; `order_id` генерує PostgreSQL. На діаграмі позначка UQ¹ у `review` означає унікальність пари `(customer_id, product_id)`. Дві позначки PK у `order_item` разом утворюють один складений ключ.