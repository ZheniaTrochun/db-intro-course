# Специфікація бази даних WMS (спрощена версія для лабораторної роботи 2)

Джерело вимог: `README.md` (розділ "Бізнес-правила"). Схема: `docs/adr/schema.sql`. Тести обмежень: `docs/adr/tests.sql`. Діаграма: `docs/adr/diagram.mmd`.

Схема використовує лише конструкції з лекцій 1-3: таблиці, enum-типи, `GENERATED ALWAYS AS IDENTITY`, `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`. Тригерів, функцій, представлень і індексів немає.

## 1. Вимоги та трасованість

| ID | Вимога | Реалізація | Перевірка (tests.sql) |
|---|---|---|---|
| R-01 | Товари: унікальний артикул, одиниця виміру зі списку, мінімальний залишок >= 0 | `product`; `UNIQUE (sku_code)`, enum `unit_type`, `CHECK (min_stock_level >= 0)` | 1, 4 |
| R-02 | Постачальники: унікальний email, телефон починається з `+` | `supplier`; `UNIQUE (email)`, `CHECK (phone LIKE '+%')` | 2 |
| R-03 | Комірки: унікальний код, пара (zone, shelf_number) унікальна, місткість > 0 | `warehouse_location`; `UNIQUE`, `CONSTRAINT uk_zone_shelf`, `CHECK (max_capacity > 0)` | - |
| R-04 | Накладна: статус з набору draft, received, cancelled, за замовчуванням draft | `supply_order`; enum `order_status`, `DEFAULT 'draft'` | - |
| R-05 | Позиції накладної: кількість > 0, ціна >= 0, складений PK | `supply_item`; `PRIMARY KEY (order_id, product_id)`, `CHECK` | 8 |
| R-06 | Залишки в комірках не від'ємні | `inventory_stock`; `CHECK (quantity >= 0)` | 5 |
| R-07 | Переміщення між різними комірками | `inventory_movement`; `CHECK (from_location_id <> to_location_id)` | 6 |
| R-08 | Списання без комірки-отримувача, переміщення з отримувачем | `inventory_movement`; `CHECK chk_movement_target` | 7 |
| R-09 | Кожна операція переміщення має автора, час і причину | `created_by NOT NULL`, `movement_date DEFAULT now()`, `reason` | 9 |
| R-10 | Цілісність посилань: не можна посилатися на неіснуючі записи | `FOREIGN KEY` без `ON DELETE` | 3 |

## 2. Сутності та атрибути

- **Постачальник (supplier)**: `supplier_id` (PK, IDENTITY), `company_name`, `contact_person`, `phone` (NOT NULL, CHECK починається з `+`), `email` (NOT NULL, UNIQUE), `address` (NOT NULL).
- **Товар (product)**: `product_id` (PK, IDENTITY), `sku_code` (NOT NULL, UNIQUE), `name` (NOT NULL), `description` (необов'язковий), `unit` (enum `unit_type`, NOT NULL, DEFAULT 'piece'), `min_stock_level` (NOT NULL, DEFAULT 0, CHECK >= 0).
- **Комірка складу (warehouse_location)**: `location_id` (PK, IDENTITY), `location_code` (NOT NULL, UNIQUE), `zone`, `shelf_number` (UNIQUE разом), `max_capacity` (NOT NULL, CHECK > 0).
- **Накладна (supply_order)**: `order_id` (PK, IDENTITY), `order_number` (NOT NULL, UNIQUE), `supplier_id` (NOT NULL, FK), `supply_date` (TIMESTAMP, NOT NULL, DEFAULT now()), `total_cost` (NUMERIC(10,2), NOT NULL, DEFAULT 0, CHECK >= 0), `status` (enum `order_status`, NOT NULL, DEFAULT 'draft').
- **Позиція накладної (supply_item)**: `order_id` і `product_id` (складений PK, обидва FK), `location_id` (NOT NULL, FK, комірка приймання), `quantity` (NOT NULL, CHECK > 0), `unit_price` (NOT NULL, CHECK >= 0), `batch_number` (NOT NULL), `expiry_date` (DATE, необов'язкова).
- **Залишок (inventory_stock)**: `product_id` і `location_id` (складений PK, обидва FK), `quantity` (NOT NULL, CHECK >= 0).
- **Переміщення (inventory_movement)**: `movement_id` (PK, IDENTITY), `movement_type` (enum `movement_kind`: transfer, write_off; NOT NULL), `product_id` (NOT NULL, FK), `from_location_id` (NOT NULL, FK), `to_location_id` (FK; NOT NULL для transfer, NULL для write_off), `quantity` (NOT NULL, CHECK > 0), `reason` (необов'язкова), `movement_date` (TIMESTAMP, NOT NULL, DEFAULT now()), `created_by` (NOT NULL).

## 3. Ключі

- Сутності supplier, product, warehouse_location, supply_order, inventory_movement мають сурогатний PK `INTEGER GENERATED ALWAYS AS IDENTITY` (ADR 0001).
- Таблиці сполучення supply_item і inventory_stock мають складений PK з двох FK (ADR 0001).

## 4. Обмеження, які БД не перевіряє

Схема не містить тригерів, тому наведені нижче правила БД не контролює. Дані в `schema.sql` вказані вручну так, щоб їх дотримувалися. Застосунок або адміністратор має дотримуватися їх сам.

1. **Залишки не оновлюються автоматично.** Після оприбуткування накладної або переміщення `inventory_stock` треба змінити вручну.
2. **Статуси накладної не контролюються.** Можливий будь-який перехід між значеннями enum. Правило "draft -> received або cancelled" і "отримана накладна без позицій неможлива" не перевіряються.
3. **Сума накладної не перераховується.** `total_cost` має дорівнювати сумі `quantity * unit_price` позицій.
4. **Місткість комірки не перевіряється.** Сума залишків у комірці може перевищити `max_capacity`.
5. **Журнал переміщень не захищений від змін.** Записи можна змінити або видалити.
6. **Видалення накладних і позицій не обмежене статусом.** Немає `ON DELETE` правил, тому видалення батьківського запису з дочірніми блокується FK.
7. **Email і артикул перевіряються без урахування регістру.** `UNIQUE` чутливий до регістру, `sku_code` не має CHECK на формат.

## 5. Процеси (як дані записуються і читаються)

- **Створення накладної:** INSERT у `supply_order` (статус draft), потім INSERT позицій у `supply_item`.
- **Оприбуткування:** UPDATE статусу накладної на received, потім оновлення `inventory_stock` для кожної позиції.
- **Скасування:** UPDATE статусу на cancelled.
- **Переміщення:** INSERT у `inventory_movement` (transfer), потім оновлення `inventory_stock` у відправника і отримувача.
- **Списання:** INSERT у `inventory_movement` (write_off), потім зменшення `inventory_stock`.
- **Залишки по товару:** `SELECT product_id, SUM(quantity) FROM inventory_stock GROUP BY product_id`.
- **Товари нижче мінімуму:** порівняння суми залишків з `min_stock_level` у запиті.
- **Історія переміщень:** `SELECT * FROM inventory_movement ORDER BY movement_date`.

## 6. Обмеження (свідомо поза межами)

1. Залишки ведуться без розбивки за партією. `batch_number` записується в позицію, FEFO не реалізовано.
2. Немає користувачів і ролей. `created_by` - довільний рядок.
3. Немає інвентаризації.
4. Одиниці виміру не конвертуються.
5. Місткість комірки в абстрактних одиницях.
6. Валюта одна, без зазначення.
7. Часові пояси не враховуються: дати зберігаються як TIMESTAMP без пояса.
