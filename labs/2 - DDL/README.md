## 1. Порядок запуску файлів

Для розгортання бази даних та перевірки її роботи SQL-скрипти необхідно виконувати суворо у такій послідовності:
1. `01_schema.sql` - створення таблиць (`customers`, `categories`, `products`, `orders`, `order_items`), первинних ключів, зовнішніх ключів та обмежень цілісності.
2. `02_seed_data.sql` - заповнення всіх 5 таблиць тестовими даними (по 5-6 записів у кожній таблиці) із дотриманням ієрархії посилань та виконання контрольних запитів `SELECT *`.



## 2. Опис реляційної схеми бази даних

Під час перетворення концептуальної ER-діаграми у фізичну схему PostgreSQL назви таблиць і стовпців приведено до формату `snake_case`, а сутність `Order` перейменовано на `orders`, оскільки `ORDER` є зарезервованим ключовим словом SQL.



### 2.1. Таблиця `customers` (Клієнти)

* `customer_id` (`SERIAL`, PK) - унікальний ідентифікатор клієнта.
* `first_name` (`VARCHAR(50)`, `NOT NULL`) - ім'я клієнта.
* `last_name` (`VARCHAR(50)`, `NOT NULL`) - прізвище клієнта.
* `email` (`VARCHAR(100)`, `NOT NULL`, `UNIQUE`) - електронна пошта клієнта (унікальна для кожного облікового запису згідно з бізнес-правилом реєстрації).
* `phone_number` (`VARCHAR(20)`, `NOT NULL`) - контактний номер телефону.



### 2.2. Таблиця `categories` (Категорії товарів)

* `category_id` (`SERIAL`, PK) - унікальний ідентифікатор категорії.
* `category_name` (`VARCHAR(100)`, `NOT NULL`, `UNIQUE`) - унікальна назва категорії товарів.



### 2.3. Таблиця `products` (Товари)

* `product_id` (`SERIAL`, PK) - унікальний ідентифікатор товару.
* `name` (`VARCHAR(150)`, `NOT NULL`) - назва товару.
* `price` (`NUMERIC(10, 2)`, `NOT NULL`, `CHECK (price > 0)`) - ціна товару (має бути строго більшою за нуль).
* `stock_quantity` (`INTEGER`, `NOT NULL`, `DEFAULT 0`, `CHECK (stock_quantity >= 0)`) - кількість одиниць на складі (не може бути від'ємною).
* `category_id` (`INTEGER`, `NOT NULL`, FK) - зовнішній ключ, що посилається на `categories(category_id)` (`ON DELETE RESTRICT`, `ON UPDATE CASCADE`). Реалізує зв'язок `1:N` між категоріями та товарами.



### 2.4. Таблиця `orders` (Замовлення)

* `order_id` (`SERIAL`, PK) - унікальний ідентифікатор замовлення.
* `order_date` (`TIMESTAMP`, `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP`) - дата та час створення замовлення.
* `status` (`VARCHAR(30)`, `NOT NULL`, `DEFAULT 'Нове'`, `CHECK (...)`) - поточний статус замовлення (обмежений переліком допустимих станів: `'Нове'`, `'В обробці'`, `'Відправлено'`, `'Доставлено'`, `'Скасовано'`).
* `customer_id` (`INTEGER`, `NOT NULL`, FK) - зовнішній ключ, що посилається на `customers(customer_id)` (`ON DELETE RESTRICT`, `ON UPDATE CASCADE`). Реалізує зв'язок `1:N` між клієнтами та замовленнями.



### 2.5. Таблиця `order_items` (Деталі замовлення)

Асоціативна таблиця, що реалізує зв'язок `M:N` між `orders` та `products` через два зв'язки `1:N`.
* `order_item_id` (`SERIAL`, PK) - унікальний ідентифікатор позиції в замовленні.
* `order_id` (`INTEGER`, `NOT NULL`, FK) - зовнішній ключ на `orders(order_id)` (`ON DELETE CASCADE`, `ON UPDATE CASCADE`).
* `product_id` (`INTEGER`, `NOT NULL`, FK) - зовнішній ключ на `products(product_id)` (`ON DELETE RESTRICT`, `ON UPDATE CASCADE`).
* `quantity` (`INTEGER`, `NOT NULL`, `CHECK (quantity > 0)`) - кількість одиниць товару в позиції.
* `unit_price` (`NUMERIC(10, 2)`, `NOT NULL`, `CHECK (unit_price > 0)`) - зафіксована ціна одиниці товару на момент оформлення замовлення.
* `UNIQUE (order_id, product_id)` - складене обмеження, яке запобігає дублюванню одного й того самого товару різними рядками в межах одного замовлення.



## 3. Перевірка працездатності

Скрипти `01_schema.sql` та `02_seed_data.sql` успішно виконані в середовищі pgAdmin без помилок обмежень. Усі 5 таблиць створені та заповнені тестовими даними.

