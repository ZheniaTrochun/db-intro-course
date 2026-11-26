# Звіт до лабораторної роботи №3

База даних shop_db (PostgreSQL, pgAdmin 4), скрипт dml_lab3.sql.

Заповнив таблиці categories, products, customers, orders, order_items та payments через INSERT INTO і підтягнув лічильники SERIAL через setval, щоб не збивалися ключі. При повторному запуску вставки з'являється помилка 23505 (дубль ключа), що підтверджує захист PRIMARY KEY.

Перевірив вибірку через SELECT і фільтрацію по WHERE (ціни більше 20000, адреса з Києвом, сума замовлення більше 25000).

Оновив статус замовлення order_id = 502 на 'paid' і статус його оплати на 'completed' через UPDATE з умовою WHERE, перевіривши записи до і після зміни через SELECT.

Видалив платіж payment_id = 904 через DELETE FROM payments WHERE payment_id = 904 і переконався через SELECT, що рядків залишилось 0.

Скріншот виконання запитів у pgAdmin збережено у файлі тест лаба 3.jpg.

Висновок: відпрацював INSERT, SELECT, UPDATE та DELETE у PostgreSQL, умова WHERE і перевірка через SELECT дозволяють безпечно змінювати та видаляти потрібні записи.
