# Лабораторна робота №3 — Маніпулювання даними SQL (OLTP)

**Тема:** Інтернет-магазин.

**Виконали, група ІМ-51:**

- Брижниченко Злата Володимирівна;
- Дмитрієнко Вікторія Андріївна;
- Бескровна Олександра Вікторівна.

## Мета

Виконати операції SELECT, INSERT, UPDATE та DELETE у PostgreSQL.
Перевірити результати змін за допомогою SELECT і використовувати
WHERE для вибору записів, що оновлюються або видаляються.

## Структура бази даних

Використовується схема інтернет-магазину з лабораторної роботи №2.

| Таблиця | Стовпці | Ключі |
|---|---|---|
| customer | customer_id, first_name, last_name, email, phone, registered_at | PK: customer_id; UNIQUE: email |
| address | address_id, customer_id, city, street, building, postal_code | PK: address_id; FK: customer_id → customer; UNIQUE: (address_id, customer_id) |
| category | category_id, name, description | PK: category_id; UNIQUE: name |
| product | product_id, category_id, name, description, price, stock_qty | PK: product_id; FK: category_id → category |
| orders | order_id, customer_id, address_id, order_date, status | PK: order_id; FK: customer_id → customer; FK: (address_id, customer_id) → address |
| order_item | order_id, product_id, quantity, unit_price | PK: (order_id, product_id); FK: order_id → orders; FK: product_id → product |
| payment | payment_id, order_id, amount, method, paid_at, status | PK: payment_id; FK: order_id → orders |
| review | review_id, customer_id, product_id, rating, comment, created_at | PK: review_id; FK: customer_id → customer; FK: product_id → product; UNIQUE: (customer_id, product_id) |

Обов’язкові текстові поля непорожні. Ціни й суми платежів додатні,
залишок товару невід’ємний, кількість у позиції не менша за 1,
оцінка відгуку — від 1 до 5.

Адреса замовлення має належати його клієнту. Для успішного платежу
paid_at обов’язкове; для pending і failed воно має бути NULL.

## Початкові дані

5 клієнтів, 6 адрес, 5 категорій, 7 товарів,
5 замовлень, 8 позицій замовлень, 8 платежів і 5 відгуків.

## Сценарії

| № | Операції | Очікуваний результат |
|---|---|---|
| 1 | Перегляд клієнтів, INSERT клієнта, UPDATE телефону, DELETE клієнта | Запис з’являється, телефон змінюється, потім запис видаляється |
| 2 | Перегляд категорій, INSERT категорії, UPDATE опису, DELETE категорії | Категорія з’являється, опис змінюється, потім категорія видаляється |
| 3 | Фільтрація товарів за ціною, INSERT товару, UPDATE ціни й залишку, DELETE товару | Товар з’являється; ціна стає 750.00, залишок — 15; потім товар видаляється |

Після кожного INSERT, UPDATE та DELETE виконується SELECT.
Перед UPDATE та DELETE переглядається запис із тим самим WHERE.

Кожен сценарій починається з BEGIN і завершується COMMIT.
Видаляються тільки записи, додані в цьому сценарії.
Початкові записи лабораторної №2 залишаються.

## Порядок виконання в pgAdmin

1. Створити нову порожню базу та відкрити її Query Tool.
2. Виконати schema.sql з лабораторної №2.
3. Виконати seed.sql з лабораторної №2.
4. Відкрити dml.sql. Виконувати команди послідовно,
   виділяючи по одному оператору від початку до крапки з комою.
5. Після SELECT переглядати Data Output, після команд зміни —
   Messages. Перевіряти результат перед наступною командою.
6. Після кожного сценарію виконати його COMMIT.

Якщо всередині транзакції виникла помилка, окремо виконати
ROLLBACK, усунути причину та почати цей сценарій з BEGIN.

Після завершення всіх сценаріїв переглянути таблиці:

```sql
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM category;
SELECT * FROM product;
SELECT * FROM orders;
SELECT * FROM order_item;
SELECT * FROM payment;
SELECT * FROM review;
```

Кількість рядків має відповідати початковим даним.
Значення згенерованих ідентифікаторів можуть мати пропуски
після додавання та видалення тестових записів.