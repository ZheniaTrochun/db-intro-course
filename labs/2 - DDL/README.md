# Лабораторна робота №2: Перетворення ER-діаграми на реляційну схему PostgreSQL

**Тема:** Фізична реалізація реляційної схеми OpenCRM (DDL)  
**Виконали студенти групи ІМ-54:**
- Рубан Олексій
- Гладченко Віталій
- Симоненко Поліна
- Грищенко Ілля

---

## 1. Мета роботи
Перетворити концептуальну ER-модель OpenCRM на фізичну реляційну схему в СУБД PostgreSQL: створити типи даних ENUM, таблиці з первинними та зовнішніми ключами, обмеженнями цілісності (NOT NULL, UNIQUE, CHECK, DEFAULT), індексами, заповнити тестовими даними (по 5+ записів на таблицю) та перевірити коректність зв'язків.

## 2. Файли роботи
- [schema.sql](./schema.sql) — DDL-скрипт створення схеми, типів, таблиць та індексів.
- [data.sql](./data.sql) — DML-скрипт наповнення бази валідними тестовими даними.
- [setup.sql](./setup.sql) — повний скрипт розгортання бази (схема + дані).
- [erDiagram.png](./erDiagram.png) — діаграма реляційної моделі.

## 3. Структура бази даних

| Таблиця | Призначення | Ключі та обмеження |
|---|---|---|
| `users` | Співробітники (адміни, менеджери) | PK: `id`; UNIQUE: `email`; CHECK: формат email |
| `clients` | Контрагенти / клієнтська база | PK: `id`; CHECK: формат email |
| `products` | Каталог товарів та сервісів | PK: `id`; UNIQUE: `name`; CHECK: `base_price >= 0` |
| `deals` | Угоди воронки продажів | PK: `id`; FK: `client_id` (RESTRICT), `manager_id` (RESTRICT); CHECK: `total_amount >= 0` |
| `deal_products` | Позиції угод (зв'язок M:N) | PK: `id`; FK: `deal_id` (CASCADE), `product_id` (RESTRICT); UNIQUE: `(deal_id, product_id)`; CHECK: `quantity > 0`, `actual_price >= 0` |
| `tasks` | Завдання менеджерів | PK: `id`; FK: `deal_id` (SET NULL), `assigned_to` (RESTRICT) |
| `audit_logs` | Журнал аудиту дій | PK: `id`; FK: `changed_by` (RESTRICT); поля `old_data`, `new_data` у форматі JSONB |

## 4. Користувацькі перелічувані типи (ENUM)
- `user_role`: `'admin'`, `'manager'` — ролі доступу співробітників.
- `deal_status`: `'new'`, `'negotiation'`, `'contract'`, `'won'`, `'lost'` — етапи воронки угод.
- `task_type`: `'call'`, `'meeting'`, `'email'` — види активностей.
- `task_status`: `'pending'`, `'completed'` — стан виконання завдання.

## 5. Політики посилальної цілісності (Foreign Keys)
- `ON DELETE RESTRICT` для користувачів і клієнтів в угодах — захист фінансових даних від випадкового видалення відповідального або контрагента.
- `ON DELETE CASCADE` для позицій `deal_products` від `deals` — видалення угоди автоматично видаляє її товарний склад.
- `ON DELETE SET NULL` для `tasks.deal_id` — при видаленні угоди історія завдань менеджерів зберігається у системі без прив'язки.

## 6. Як запустити та перевірити
Виконати скрипт у pgAdmin або через консоль `psql`:
```bash
psql -U postgres -d postgres -f setup.sql
```
