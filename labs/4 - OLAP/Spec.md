# Лабораторна робота №4: Аналітичні SQL-запити (OLAP)

**Дисципліна:** Бази даних (КПІ)  
**Предметна область:** OpenCRM (Система управління взаємовідносинами з клієнтами)  
**Виконали студенти групи ІМ-54:**
- Рубан Олексій (Tech Lead / Admin)
- Гладченко Віталій (Sales Manager)
- Симоненко Поліна (Sales Manager)
- Грищенко Ілля (Sales Manager)

---

## 1. Мета роботи
- Опанування аналітичних SQL-запитів (**OLAP — Online Analytical Processing**) у середовищі PostgreSQL 17+ на основі схеми та даних OpenCRM, сформованих у лабораторних роботах №1–3.
- Застосування агрегатних функцій (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) для обчислення зведеної бізнес-статистики по клієнтах, менеджерах, угодах, товарах та завданнях.
- Використання речення `GROUP BY` для групування рядків за одним або кількома стовпцями та обчислення агрегатів для кожної групи.
- Використання речення `HAVING` для фільтрації вже згрупованих результатів за агрегованими умовами.
- Комбінування даних із кількох таблиць за допомогою різних типів `JOIN` (`INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`) у багатотабличних агрегаційних запитах.
- Застосування підзапитів у реченнях `SELECT`, `WHERE` та `HAVING` для порівняння показників із середніми значеннями та обчислення корельованих метрик.

---

## 2. Контекст схеми та аналітичних даних

На відміну від OLTP-операцій (лабораторна робота №3), які працюють із точковими транзакціями над окремими рядками (`INSERT`, `UPDATE`, `DELETE`), **OLAP-запити** виконують читання (`SELECT`) великих зрізів даних для побудови звітів, підрахунку KPI та пошуку закономірностей.

Запити виконувалися в PostgreSQL (`17.5-alpine`) над актуальним станом таблиць OpenCRM після виконання скриптів лабораторних робіт №2 та №3:
- `clients` (6 записів) — компанії-контрагенти та контактні особи (`id`, `company_name`, `contact_person`, `phone`, `email`, `created_at`).
- `users` (5 записів) — адміністратори та менеджери з продажу (`id`, `full_name`, `email`, `role`, `created_at`).
- `products` (7 записів) — каталог товарів і послуг із базовими цінами (`id`, `name`, `base_price`).
- `deals` (7 записів) — угоди воронки продажів із прив'язкою до клієнта (`client_id` $\rightarrow$ `clients.id`) та менеджера (`manager_id` $\rightarrow$ `users.id`).
- `deal_products` (15 записів) — деталізація позицій в угодах (зв'язок M:N між `deals` і `products` із фіксацією `quantity` та `actual_price`).
- `tasks` (6 записів) — оперативні завдання менеджерів з опціональною прив'язкою до угоди (`deal_id` $\rightarrow$ `deals.id`, допускає `NULL`).

> **Примітка:** У файлі [`olap_queries.sql`](olap_queries.sql) перед деякими аналітичними запитами також містяться допоміжні вибірки `SELECT * FROM ...` для візуального ознайомлення з сирими даними таблиць у клієнті (pgAdmin / `psql`). Нижче наведено всі 22 основні OLAP-запити та результати їхнього виконання.

---

## 3. Детальний опис та виконання аналітичних запитів

### 3.1. Запити Рубана Олексія

#### Запит 1: Сума та кількість угод по кожному клієнту (`INNER JOIN` + `COUNT`, `SUM`, `GROUP BY`)
* **Що робить запит:** Об'єднує таблиці `clients` та `deals` за ключами `c.id = d.client_id`, групує записи за кожним клієнтом (`c.id`, `c.company_name`, `c.contact_person`), підраховує загальну кількість угод (`COUNT(d.id)`) і сумарний обсяг доходу (`SUM(d.total_amount)`), а також сортує клієнтів за спаданням виручки.
* **SQL-запит:**
```sql
SELECT c.company_name, c.contact_person, COUNT(d.id) AS total_deals, SUM(d.total_amount) AS total_revenue
FROM clients c
JOIN deals d ON c.id = d.client_id
GROUP BY c.id, c.company_name, c.contact_person
ORDER BY total_revenue DESC;
```
* **Результат виконання:**
```text
           company_name           |              contact_person               | total_deals | total_revenue 
----------------------------------+-------------------------------------------+-------------+---------------
 ПрАТ «Київстар Дігітал»          | Шевченко Олена Вікторівна                 |           2 |     117000.00
 ТОВ «Нова Пошта Технолоджі»      | Мельник Тарас Григорович                  |           1 |      55000.00
 ТОВ «Розетка Маркетплейс»        | Коваленко Богдан Ігорович (Директор з IT) |           1 |      43000.00
 ТОВ «ДТЕК Енерго Хмарні Рішення» | Коваль Дмитро Олександрович               |           1 |      41500.00
 ПП «Агро-Експорт Груп»           | Бондаренко Ірина Сергіївна                |           1 |      35000.00
 ТОВ «Фармак Інновації»           | Кравченко Максим Юрійович                 |           1 |      25000.00
(6 rows)
```

---

#### Запит 2: Сума та кількість угод по кожному менеджеру (`LEFT JOIN` + `COUNT`, `SUM`, `COALESCE`, `GROUP BY`)
* **Що робить запит:** Формує рейтинг ефективності співробітників компанії: об'єднує всіх користувачів із таблиці `users` з їхніми угодами в `deals`, підраховує кількість закріплених угод (`COUNT(d.id)`) і загальний фінансовий обсяг (`COALESCE(SUM(d.total_amount), 0)`).
* **Чому обрано такий підхід:** `LEFT JOIN` зберігає у звіті співробітників без угод (**Андрій Ковальчук**), `COUNT(d.id)` повертає `0` замість `1`, а `COALESCE(..., 0)` замінює `NULL` від порожньої суми на `0` для читабельності та коректного сортування `DESC`.
* **SQL-запит:**
```sql
SELECT u.full_name, u.role, COALESCE(COUNT(d.id), 0) AS total_deals, COALESCE(SUM(d.total_amount), 0) AS total_revenue
FROM users u
LEFT JOIN deals d ON u.id = d.manager_id
GROUP BY u.id, u.full_name, u.role
ORDER BY total_revenue DESC;
```
* **Результат виконання:**
```text
     full_name     |  role   | total_deals | total_revenue 
-------------------+---------+-------------+---------------
 Віталій Гладченко | manager |           3 |     137500.00
 Симоненко Поліна  | manager |           2 |      89000.00
 Рубан Олексій     | admin   |           1 |      55000.00
 Грищенко Ілля     | manager |           1 |      35000.00
 Андрій Ковальчук  | manager |           0 |             0
(5 rows)
```

---

#### Запит 3: Популярні товари та їх середня фактична вартість (`INNER JOIN` + `COUNT`, `AVG`, `ROUND`, `GROUP BY`, `HAVING`)
* **Що робить запит:** Аналізує продажі по каталогу товарів і послуг: поєднує `products` з `deal_products`, підраховує кількість продажів, обчислює середню фактичну ціну (`ROUND(AVG(dp.actual_price), 2)`) та відфільтровує позиції з кількістю продажів понад 2 через `HAVING`.
* **SQL-запит:**
```sql
SELECT p.name, COUNT(dp.product_id) AS total_sales, ROUND(AVG(dp.actual_price), 2) AS average_price
FROM products p
JOIN deal_products dp ON p.id = dp.product_id
GROUP BY p.id, p.name
HAVING COUNT(dp.product_id) > 2
ORDER BY total_sales DESC;
```
* **Результат виконання:**
```text
                   name                   | total_sales | average_price 
------------------------------------------+-------------+---------------
 Впровадження CRM OpenCRM (базовий пакет) |           6 |      24833.33
 Річна підписка на хмарну інфраструктуру  |           3 |      18000.00
(2 rows)
```

---

#### Запит 4: Кількість завдань по кожній угоді (`FULL OUTER JOIN` + `COUNT`, `GROUP BY`)
* **Що робить запит:** Проводить повне зіставлення `deals` і `tasks` через `FULL OUTER JOIN`, рахуючи кількість завдань (`COUNT(t.id)`) для кожної угоди, а також виводячи позаугодові завдання (`deal_id IS NULL`) окремим рядком.
* **SQL-запит:**
```sql
SELECT d.id AS deal_id, d.status AS deal_status, d.total_amount, COUNT(t.id) AS total_tasks
FROM deals d
FULL OUTER JOIN tasks t ON d.id = t.deal_id
GROUP BY d.id, d.status, d.total_amount
ORDER BY d.id;
```
* **Результат виконання:**
```text
 deal_id | deal_status | total_amount | total_tasks 
---------+-------------+--------------+-------------
       1 | won         |     55000.00 |           0
       2 | contract    |     71000.00 |           1
       3 | negotiation |     43000.00 |           1
       4 | negotiation |     35000.00 |           1
       5 | lost        |     25000.00 |           1
       6 | new         |     41500.00 |           0
      10 | negotiation |     46000.00 |           1
         |             |              |           1
(8 rows)
```

---

### 3.2. Запити Грищенка Іллі

#### Запит 5: Базова агрегація по угодах (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`)
* **Що робить запит:** Обчислює загальні зведені показники по всіх угодах у таблиці `deals`: кількість, загальну суму, середній чек, мінімальну та максимальну суму угоди.
* **SQL-запит:**
```sql
SELECT COUNT(*) AS total_deals, SUM(total_amount) AS total_sum, AVG(total_amount) AS avg_sum, MIN(total_amount) AS min_sum, MAX(total_amount) AS max_sum
FROM deals;
```
* **Результат виконання:**
```text
 total_deals | total_sum |      avg_sum       | min_sum  | max_sum  
-------------+-----------+--------------------+----------+----------
           7 | 316500.00 | 45214.285714285714 | 25000.00 | 71000.00
(1 row)
```

---

#### Запит 6: Групування угод за статусом та фільтрація груп (`GROUP BY` + `HAVING`)
* **Що робить запит:** Підраховує кількість угод у кожному статусі воронки та залишає лише ті статуси, де є більше 1 угоди.
* **SQL-запит:**
```sql
SELECT status, COUNT(*) AS deals_count
FROM deals
GROUP BY status
HAVING COUNT(*) > 1;
```
* **Результат виконання:**
```text
   status    | deals_count 
-------------+-------------
 negotiation |           3
(1 row)
```

---

#### Запит 7: Сума угод по кожному клієнту (`INNER JOIN` + `SUM`, `GROUP BY`)
* **Що робить запит:** Об'єднує `clients` та `deals` за зовнішнім ключем і обчислює загальні витрати кожного контрагента.
* **SQL-запит:**
```sql
SELECT c.company_name, SUM(d.total_amount) AS total_spent
FROM clients c
INNER JOIN deals d ON c.id = d.client_id
GROUP BY c.id, c.company_name;
```
* **Результат виконання:**
```text
           company_name           | total_spent 
----------------------------------+-------------
 ПП «Агро-Експорт Груп»           |    35000.00
 ТОВ «ДТЕК Енерго Хмарні Рішення» |    41500.00
 ТОВ «Розетка Маркетплейс»        |    43000.00
 ТОВ «Нова Пошта Технолоджі»      |    55000.00
 ТОВ «Фармак Інновації»           |    25000.00
 ПрАТ «Київстар Дігітал»          |   117000.00
(6 rows)
```

---

#### Запит 8: Усі менеджери та кількість їхніх угод (`LEFT JOIN` + `COUNT`, `GROUP BY`)
* **Що робить запит:** Виводить усіх користувачів із `users` і кількість закріплених за ними угод у `deals`, включно з тими, хто не має угод (`0`).
* **SQL-запит:**
```sql
SELECT u.full_name, COUNT(d.id) AS deals_count
FROM users u
LEFT JOIN deals d ON u.id = d.manager_id
GROUP BY u.id, u.full_name;
```
* **Результат виконання:**
```text
     full_name     | deals_count 
-------------------+-------------
 Грищенко Ілля     |           1
 Симоненко Поліна  |           2
 Рубан Олексій     |           1
 Андрій Ковальчук  |           0
 Віталій Гладченко |           3
(5 rows)
```

---

#### Запит 9: Усі користувачі та призначені їм завдання (`RIGHT JOIN`)
* **Що робить запит:** Використовує `RIGHT JOIN` між `tasks` і `users`, щоб вивести всі завдання разом із виконавцями, а також користувачів, які наразі не мають жодного завдання.
* **SQL-запит:**
```sql
SELECT u.full_name, t.task_type, t.status
FROM tasks t
RIGHT JOIN users u ON t.assigned_to = u.id;
```
* **Результат виконання:**
```text
     full_name     | task_type |  status   
-------------------+-----------+-----------
 Віталій Гладченко | meeting   | pending
 Грищенко Ілля     | call      | pending
 Віталій Гладченко | email     | completed
 Рубан Олексій     | meeting   | pending
 Симоненко Поліна  | call      | completed
 Симоненко Поліна  | email     | pending
 Андрій Ковальчук  |           | 
(7 rows)
```

---

#### Запит 10: Угоди, більші за середню суму (підзапит у `WHERE`)
* **Що робить запит:** Порівнює суму кожної угоди із середнім чеком по всій таблиці `deals` (обчисленим через скалярний підзапит).
* **SQL-запит:**
```sql
SELECT id, total_amount
FROM deals
WHERE total_amount > (SELECT AVG(total_amount) FROM deals);
```
* **Результат виконання:**
```text
 id | total_amount 
----+--------------
  1 |     55000.00
  2 |     71000.00
 10 |     46000.00
(3 rows)
```

---

#### Запит 11: Менеджери, чия сума угод більша за середній чек (підзапит у `HAVING`)
* **Що робить запит:** Групує угоди за `manager_id` та відбирає менеджерів, у яких сумарний обсяг угод перевищує середню вартість однієї угоди.
* **SQL-запит:**
```sql
SELECT manager_id, SUM(total_amount) AS manager_sum
FROM deals
GROUP BY manager_id
HAVING SUM(total_amount) > (SELECT AVG(total_amount) FROM deals);
```
* **Результат виконання:**
```text
 manager_id | manager_sum 
------------+-------------
          3 |    89000.00
          2 |   137500.00
          1 |    55000.00
(3 rows)
```

---

#### Запит 12: Кількість угод для кожного клієнта (корельований підзапит у `SELECT`)
* **Що робить запит:** Для кожного рядка таблиці `clients` обчислює кількість його угод за допомогою корельованого підзапиту у списку вибірки `SELECT`.
* **SQL-запит:**
```sql
SELECT company_name, (SELECT COUNT(*) FROM deals d WHERE d.client_id = c.id) AS deals_count
FROM clients c;
```
* **Результат виконання:**
```text
           company_name           | deals_count 
----------------------------------+-------------
 ТОВ «Нова Пошта Технолоджі»      |           1
 ПрАТ «Київстар Дігітал»          |           2
 ПП «Агро-Експорт Груп»           |           1
 ТОВ «Фармак Інновації»           |           1
 ТОВ «ДТЕК Енерго Хмарні Рішення» |           1
 ТОВ «Розетка Маркетплейс»        |           1
(6 rows)
```

---

### 3.3. Запити Симоненко Поліни

#### Запит 13: Кількість та сума угод по статусах вище середнього чека (`GROUP BY` + `HAVING` із підзапитом)
* **Що робить запит:** Групує угоди за статусом, рахує їхню кількість та суму й залишає статуси, загальна сума яких перевищує середню суму угоди.
* **SQL-запит:**
```sql
SELECT status, COUNT(id) AS total_deals, SUM(total_amount) AS total_sum
FROM deals
GROUP BY status
HAVING SUM(total_amount) > (SELECT AVG(total_amount) FROM deals)
ORDER BY total_sum DESC;
```
* **Результат виконання:**
```text
   status    | total_deals | total_sum 
-------------+-------------+-----------
 negotiation |           3 | 124000.00
 contract    |           1 |  71000.00
 won         |           1 |  55000.00
(3 rows)
```

---

#### Запит 14: Мінімальна, максимальна та середня фактична ціна товарів (`INNER JOIN` + `MIN`, `MAX`, `AVG`)
* **Що робить запит:** Аналізує діапазон цін реалізації для кожного товару з каталогу на основі фактичних продажів у `deal_products`.
* **SQL-запит:**
```sql
SELECT p.name, MIN(dp.actual_price) AS min_price, MAX(dp.actual_price) AS max_price, ROUND(AVG(dp.actual_price), 2) AS avg_price
FROM products p
JOIN deal_products dp ON p.id = dp.product_id
GROUP BY p.id, p.name
ORDER BY avg_price DESC;
```
* **Результат виконання:**
```text
                         name                          | min_price | max_price | avg_price 
-------------------------------------------------------+-----------+-----------+-----------
 Розробка індивідуального модуля аналітики             |  35000.00 |  35000.00 |  35000.00
 Впровадження CRM OpenCRM (базовий пакет)              |  24000.00 |  25000.00 |  24833.33
 Річна підписка на хмарну інфраструктуру               |  18000.00 |  18000.00 |  18000.00
 Налаштування BI-аналітики та користувацьких дашбордів |  16500.00 |  16500.00 |  16500.00
 Інтеграція з IP-телефонією та месенджерами            |  12000.00 |  12000.00 |  12000.00
 Корпоративний тренінг для персоналу                   |  10000.00 |  10000.00 |  10000.00
(6 rows)
```

---

#### Запит 15: Кількість завдань та угод по кожному менеджеру (`LEFT JOIN` + підзапит у `SELECT`)
* **Що робить запит:** Поєднує `users` і `tasks` через `LEFT JOIN` для підрахунку завдань (`total_tasks`), а паралельно корельованим підзапитом у `SELECT` підраховує кількість угод (`total_deals`), щоб уникнути множення рядків при подвійному `JOIN`.
* **SQL-запит:**
```sql
SELECT u.full_name, COUNT(t.id) AS total_tasks, (SELECT COUNT(*) FROM deals d WHERE d.manager_id = u.id) AS total_deals
FROM users u
LEFT JOIN tasks t ON u.id = t.assigned_to
GROUP BY u.id, u.full_name
ORDER BY total_tasks DESC;
```
* **Результат виконання:**
```text
     full_name     | total_tasks | total_deals 
-------------------+-------------+-------------
 Симоненко Поліна  |           2 |           2
 Віталій Гладченко |           2 |           3
 Грищенко Ілля     |           1 |           1
 Рубан Олексій     |           1 |           1
 Андрій Ковальчук  |           0 |           0
(5 rows)
```

---

#### Запит 16: Угоди дорожчі за середній чек та позаугодові завдання (`FULL OUTER JOIN` + підзапит у `WHERE`)
* **Що робить запит:** Виводить великі угоди (`total_amount > AVG`) та записи без відповідності у `tasks` (`t.deal_id IS NULL`) — як угоди без жодного завдання (№1, №6), так і автономне завдання без прив'язки до угоди (`task_id = 6`).
* **SQL-запит:**
```sql
SELECT d.id AS deal_id, d.status, d.total_amount, t.id AS task_id
FROM deals d
FULL OUTER JOIN tasks t ON d.id = t.deal_id
WHERE d.total_amount > (SELECT AVG(total_amount) FROM deals) OR t.deal_id IS NULL
ORDER BY d.id;
```
* **Результат виконання:**
```text
 deal_id |   status    | total_amount | task_id 
---------+-------------+--------------+---------
       1 | won         |     55000.00 |        
       2 | contract    |     71000.00 |       2
       6 | new         |     41500.00 |        
      10 | negotiation |     46000.00 |       7
         |             |              |       6
(5 rows)
```

---

### 3.4. Запити Гладченка Віталія

#### Запит 17: Статистика по статусах угод (`deals` — `COUNT`, `SUM`, `AVG`, `COALESCE`, `GROUP BY`)
* **Що робить запит:** Групує всі угоди за етапом воронки (`status`), підраховує їхню кількість, загальну суму та округлений середній чек із підстановкою `0` замість `NULL` через `COALESCE`.
* **SQL-запит:**
```sql
SELECT
    status,
    COUNT(*) AS deals_count,
    COALESCE(SUM(total_amount), 0) AS total_sum,
    ROUND(COALESCE(AVG(total_amount), 0), 2) AS avg_amount
FROM deals
GROUP BY status
ORDER BY total_sum DESC;
```
* **Результат виконання:**
```text
   status    | deals_count | total_sum | avg_amount 
-------------+-------------+-----------+------------
 negotiation |           3 | 124000.00 |   41333.33
 contract    |           1 |  71000.00 |   71000.00
 won         |           1 |  55000.00 |   55000.00
 new         |           1 |  41500.00 |   41500.00
 lost        |           1 |  25000.00 |   25000.00
(5 rows)
```

---

#### Запит 18: Продажі по кожному менеджеру (`users` + `deals` — `LEFT JOIN`, `COALESCE`, `GROUP BY`)
* **Що робить запит:** Виводить усіх співробітників, кількість їхніх угод і суму продажів (завдяки `LEFT JOIN` та `COALESCE` у звіті зберігається менеджер **Андрій Ковальчук** із `0` угод).
* **SQL-запит:**
```sql
SELECT
    u.full_name,
    COUNT(d.id) AS deals_count,
    COALESCE(SUM(d.total_amount), 0) AS total_sales
FROM users u
LEFT JOIN deals d ON u.id = d.manager_id
GROUP BY u.id, u.full_name
ORDER BY total_sales DESC;
```
* **Результат виконання:**
```text
     full_name     | deals_count | total_sales 
-------------------+-------------+-------------
 Віталій Гладченко |           3 |   137500.00
 Симоненко Поліна  |           2 |    89000.00
 Рубан Олексій     |           1 |    55000.00
 Грищенко Ілля     |           1 |    35000.00
 Андрій Ковальчук  |           0 |           0
(5 rows)
```

---

#### Запит 19: Клієнти з сумою угод вище порогу (`clients` + `deals` — `INNER JOIN`, `GROUP BY`, `HAVING`)
* **Що робить запит:** Об'єднує клієнтів із їхніми угодами, підсумовує суму по кожній компанії та через `HAVING` залишає лише тих, чия сума перевищує `50000`.
* **SQL-запит:**
```sql
SELECT
    c.company_name,
    COUNT(d.id) AS deals_count,
    SUM(d.total_amount) AS total_sum
FROM clients c
INNER JOIN deals d ON c.id = d.client_id
GROUP BY c.id, c.company_name
HAVING SUM(d.total_amount) > 50000
ORDER BY total_sum DESC;
```
* **Результат виконання:**
```text
        company_name         | deals_count | total_sum 
-----------------------------+-------------+-----------
 ПрАТ «Київстар Дігітал»     |           2 | 117000.00
 ТОВ «Нова Пошта Технолоджі» |           1 |  55000.00
(2 rows)
```

---

#### Запит 20: Угоди і задачі разом (`deals` + `tasks` — `FULL OUTER JOIN`)
* **Що робить запит:** Показує повне зіставлення угод і задач: угоди без задач, угоди з задачами та автономні задачі без прив'язки до угоди (`deal_id IS NULL`).
* **SQL-запит:**
```sql
SELECT
    d.id AS deal_id,
    d.status AS deal_status,
    t.task_type,
    t.status AS task_status
FROM deals d
FULL OUTER JOIN tasks t ON d.id = t.deal_id
ORDER BY d.id NULLS LAST, t.id;
```
* **Результат виконання:**
```text
 deal_id | deal_status | task_type | task_status 
---------+-------------+-----------+-------------
       1 | won         |           | 
       2 | contract    | meeting   | pending
       3 | negotiation | call      | completed
       4 | negotiation | call      | pending
       5 | lost        | email     | completed
       6 | new         |           | 
      10 | negotiation | email     | pending
         |             | meeting   | pending
(8 rows)
```

---

#### Запит 21: Угоди з сумою більшою за середню (`deals` — підзапит у `WHERE`)
* **Що робить запит:** Відбирає угоди, сума яких вища за середній чек по всій таблиці `deals`, із сортуванням за спаданням суми.
* **SQL-запит:**
```sql
SELECT
    id,
    status,
    total_amount
FROM deals
WHERE total_amount > (SELECT AVG(total_amount) FROM deals)
ORDER BY total_amount DESC;
```
* **Результат виконання:**
```text
 id |   status    | total_amount 
----+-------------+--------------
  2 | contract    |     71000.00
  1 | won         |     55000.00
 10 | negotiation |     46000.00
(3 rows)
```

---

#### Запит 22: Менеджери та кількість їхніх угод (`users` — корельований підзапит у `SELECT`)
* **Що робить запит:** Для кожного співробітника з `users` рахує кількість його угод за допомогою вкладеного корельованого підзапиту без використання `GROUP BY`.
* **SQL-запит:**
```sql
SELECT
    u.full_name,
    (SELECT COUNT(*) FROM deals d WHERE d.manager_id = u.id) AS deals_count
FROM users u
ORDER BY deals_count DESC;
```
* **Результат виконання:**
```text
     full_name     | deals_count 
-------------------+-------------
 Віталій Гладченко |           3
 Симоненко Поліна  |           2
 Рубан Олексій     |           1
 Грищенко Ілля     |           1
 Андрій Ковальчук  |           0
(5 rows)
```

---

## 4. Матриця відповідності вимогам завдання

Нижче наведено зведення використаних у [`olap_queries.sql`](olap_queries.sql) SQL-конструкцій відповідно до інструкцій лабораторної роботи №4 (`lab_4.md`):

| Вимога методичних вказівок | Статус у `olap_queries.sql` | Де реалізовано |
|---|---|---|
| Мінімум **4 запити** з агрегатними функціями (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`, `GROUP BY`) | **Виконано** (використано `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING`) | Запити 1–8, 11, 13–15, 17–19 |
| Мінімум **3 запити** з різними типами `JOIN` (`INNER`, `LEFT`, `RIGHT`, `FULL`, `CROSS`) | **Виконано** (використано 4 типи: `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`) | Запити 1, 3, 7, 14, 19 (`INNER`), Запити 2, 8, 15, 18 (`LEFT`), Запит 9 (`RIGHT`), Запити 4, 16, 20 (`FULL OUTER`) |
| Мінімум **3 запити** з підзапитами (у `SELECT`, `WHERE` або `HAVING`) | **Виконано** (8 запитів із підзапитами у `WHERE`, `HAVING` та `SELECT`) | Запити 10, 16, 21 (`WHERE`), Запити 11, 13 (`HAVING`), Запити 12, 15, 22 (`SELECT`) |

---

## 5. Файлова структура роботи

- [`Lab 4/olap_queries.sql`](olap_queries.sql) — повний SQL-скрипт з аналітичними OLAP-запитами для OpenCRM.
- [`Lab 4/Spec.md`](Spec.md) — специфікація та звіт до лабораторної роботи №4 з описом усіх запитів і результатами виконання.

---

## 6. Висновки
У межах лабораторної роботи №4 на базі даних OpenCRM у PostgreSQL 17.5 реалізовано та протестовано 22 аналітичні OLAP-запити від усіх учасників команди, що повністю покривають вимоги методичних вказівок `lab_4.md`:
1. Застосовано повний набір агрегатних функцій (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) разом із `GROUP BY`, `HAVING` та `COALESCE`.
2. Використано 4 різні типи з'єднань таблиць (`INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`) для аналізу клієнтів, менеджерів, каталогу товарів та покриття угод завданнями.
3. Реалізовано 8 запитів із підзапитами у `WHERE`, `HAVING` та `SELECT` (зокрема корельовані підзапити для уникнення дублювання при агрегації).

Усі наведені в цьому звіті запити перевірені в середовищі PostgreSQL `17.5-alpine` без жодної синтаксичної чи логічної помилки, а їхні результати повністю узгоджуються з фактичним станом даних у системі OpenCRM.
