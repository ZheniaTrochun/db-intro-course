# Внесок учасників

Проєкт bookly виконується командою з 4 осіб. Нижче — розподіл
відповідальності за сутностями бази даних, включно з інтерв'юванням
стейкхолдера для своєї частини (Лаб 1) та подальшою реалізацією (Лаб 2+).

## Команда

| Учасник | Сутності | Основні питання інтерв'ю |
|---|---|---|
| Варенко Катерина | Customer, Address | Які дані про клієнта потрібні? Чи може клієнт мати кілька адрес? |
| Поліщук Анна | Category, Book | Як організований каталог книг? Чи може книга бути в кількох категоріях? |
| Лобода Аліна | Author, Orders | Чи потрібна інформація про авторів? Який у замовлення статус і які переходи можливі? |
| Сітковська Аліна | Order_item, Payment | Як формується ціна в замовленні? Які способи оплати та статуси платежу? |

## Сутності та зв'язки за учасниками

### Варенко Катерина — Customer, Address
- Customer (id PK, first_name, last_name, email, phone)
- Address (id PK, customer_id FK, country, city, street, postal_code)
- Зв'язки: Customer–Address (1:N), Customer–Orders (1:N — зв'язок описано з боку Customer, саму Orders не займає)

### Поліщук Анна — Category, Book
- Category (id PK, name)
- Book (id PK, author_id FK, title, published_year, price)
- Зв'язки: Category–Book (N:N), Author–Book (1:N — зв'язок описано з боку Book)

### Лобода Аліна — Author, Orders
- Author (id PK, first_name, last_name)
- Orders (id PK, customer_id FK, address_id FK, date, status)
- Зв'язки: Author–Book (1:N — з боку Author), Address–Orders (1:N), Customer–Orders (1:N — з боку Orders)

### Сітковська Аліна — Order_item, Payment
- Order_item (order_id PK/FK, book_id PK/FK, quantity, unit_price)
- Payment (id PK, order_id FK, amount, date, method, status)
- Зв'язки: Orders–Order_item (1:N), Book–Order_item (1:N), Orders–Payment (1:1)