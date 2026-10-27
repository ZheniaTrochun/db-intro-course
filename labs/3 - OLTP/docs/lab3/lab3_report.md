# Лабораторна робота 3: Маніпулювання даними SQL (OLTP)

**База:** `logistics` (система складського обліку WMS, схема з лабораторної 2)
**Скрипт:** `docs/lab3/lab3_oltp.sql`
**Скрипт:** містить CREATE і початкові дані (схема лабораторної 2 без змін). Специфікація: `docs/adr/spec.md`

## 1. Мета

Перевірити схему та початкові дані лабораторної 2 через ручні OLTP-запити:
вибірку (`SELECT` з `WHERE`), додавання (`INSERT`), зміну (`UPDATE ... SET ... WHERE`)
і видалення (`DELETE ... WHERE`) рядків, а також транзакції для пов'язаних змін.

## 2. Схема (підсумок)

| Таблиця | Стовпці | Ключі | Ключові обмеження |
|---|---|---|---|
| `supplier` | supplier_id, company_name, contact_person, phone, email, address | PK `supplier_id` | `email` UNIQUE; `phone` починається з `+` |
| `product` | product_id, sku_code, name, description, unit, min_stock_level | PK `product_id` | `sku_code` UNIQUE; `unit` - enum; `min_stock_level >= 0` |
| `warehouse_location` | location_id, location_code, zone, shelf_number, max_capacity | PK `location_id` | `location_code` UNIQUE; `(zone, shelf_number)` UNIQUE; `max_capacity > 0` |
| `supply_order` | order_id, order_number, supplier_id, supply_date, total_cost, status | PK `order_id`; FK `supplier_id` | `order_number` UNIQUE; `status` - enum, за замовчуванням `draft` |
| `supply_item` | order_id, product_id, location_id, quantity, unit_price, batch_number, expiry_date | PK `(order_id, product_id)`; FK всі три | `quantity > 0`; `unit_price >= 0` |
| `inventory_stock` | product_id, location_id, quantity | PK `(product_id, location_id)`; FK обидва | `quantity >= 0` |
| `inventory_movement` | movement_id, movement_type, product_id, from_location_id, to_location_id, quantity, reason, movement_date, created_by | PK `movement_id`; FK три | `quantity > 0`; `from <> to`; для `transfer` є отримувач, для `write_off` - ні |

**Припущення і обмеження** (див. `spec.md`, розд. 4):

- Схема не має тригерів. Залишки (`inventory_stock`), `total_cost` накладної та статуси накладних оновлюються **вручну**, у скрипті - відповідними запитами в транзакціях.
- `status` накладної БД не перевіряє переходи (наприклад, `received -> draft`). Тому в `UPDATE` додано умову `AND status = 'draft'` як захист на рівні запиту.
- `created_by` - довільний рядок, користувачів немає.
- Ідентифікатори генерує `GENERATED ALWAYS AS IDENTITY`; у скрипті вони не задаються вручну. Зв'язки зчитуються підзапитами за природними ключами (`sku_code`, `location_code`, `email`, `order_number`).

## 3. Опис запитів

Початкові дані (вставляються розділом 0 скрипта): 5 постачальників, 5 товарів, 5 комірок, 5 накладних, 7 позицій, 9 залишків, 5 переміщень/списань.

### 3.1 SELECT (розділ 1 скрипту)

| № | Мета | Умова / особливість | Очікуваний результат |
|---|---|---|---|
| 1.1 | Список постачальників з вибраними стовпцями | без `*` | 5 рядків |
| 1.2 | Товари в одиницях `box` | `WHERE unit = 'box'` | 2 рядки (SKU-UTP-5E, SKU-RJ45-100) |
| 1.3 | Пошук товарів за назвою без урахування регістру | `ILIKE '%кабель%'` | 1 рядок |
| 1.4 | Накладні з сумою > 20000 | `ORDER BY total_cost DESC` | 3 рядки: 105000, 42000, 34000 |
| 1.5 | Накладні-чернетки та скасовані | `IN ('draft','cancelled')` | 2 рядки (ORD-2026-04, ORD-2026-05) |
| 1.6 | Позиції без терміну придатності | `IS NULL` | 5 рядків |
| 1.7 | Демонстрація пастки `= NULL` | `= NULL` | 0 рядків (навіть якщо є NULL-значення) |
| 1.8 | Позиції з ціною 300-1000 | `BETWEEN` | 3 рядки |
| 1.9 | Топ-3 комірки за місткістю | `ORDER BY ... LIMIT 3` | LOC-B-1 (2000), потім LOC-A-1, LOC-A-2 (500) |
| 1.10 | Підсумки по накладних | агрегати + `FILTER` | 5 накладних, 3 отримані, сума 165500.00 |
| 1.11 | Загальний залишок SKU-PATCH-1M | скалярний підзапит | 495 |
| 1.12 | Унікальні автори переміщень | `DISTINCT` | 2 значення |
| 1.13 | Списання | `IS NULL` для `to_location_id` | 1 рядок |
| 1.14 | Історія переміщень | `ORDER BY movement_date, movement_id` | 5 рядків |

### 3.2 INSERT (розділ 2)

| № | Що додаємо | Очікуваний результат |
|---|---|---|
| 2.1 | Постачальник ТОВ СвітлоМережа | 1 рядок, повертається `supplier_id` через `RETURNING` |
| 2.2 | Товари SKU-SFP-10G, SKU-PDU-8, SKU-TEST-DEL | 3 рядки (multi-row `VALUES`) |
| 2.3 | Комірка LOC-E-1 | 1 рядок |
| 2.4 | Накладна ORD-2026-06 (чернетка) | 1 рядок, статус `draft` (за замовчуванням) |
| 2.5 | Дві позиції накладної ORD-2026-06 | 2 рядки: 20 x 1450 та 30 x 320 |
| 2.6 | Перерахунок `total_cost` | 38600.00 = 20*1450 + 30*320 |
| 2.7 | `INSERT ... ON CONFLICT (email) DO NOTHING` для існуючого постачальника | 0 рядків вставлено, помилки немає |

### 3.3 UPDATE (розділ 3)

| № | Що змінюємо | Умова | Очікуваний результат |
|---|---|---|---|
| 3.1 | Перевірка перед змінами | `sku_code = 'SKU-ROUTER-AC'` | 1 рядок |
| 3.2 | `min_stock_level` і `description` товару | `sku_code` | 1 рядок: мінімум 5 -> 6 |
| 3.3 | Адреса постачальника | `email = 'sales@logplus.com'` | 1 рядок |
| 3.4 | ORD-2026-04: `draft -> cancelled` | `status = 'draft'` в умові | 1 рядок |
| 3.5 | Оприбуткування ORD-2026-06 (транзакція) | статус `received` + `INSERT ... ON CONFLICT` у `inventory_stock` | 1 рядок статусу; 2 нових рядки залишків (SFP і PDU у LOC-E-1: 20 і 30) |
| 3.6 | Переміщення 5 шт. SFP з LOC-E-1 в LOC-A-1 і списання 2 шт. PDU (транзакція) | журнал + залишки | SFP: LOC-E-1 = 15, LOC-A-1 = 5; PDU: LOC-E-1 = 28 |
| 3.7 | Перевірка залишків | `SELECT` | 12 рядків залишків (9 початкових + 2 з 3.5 + 1 з 3.6) |
| 3.8 | Демо: UPDATE без потрібного WHERE + `ROLLBACK` | всі 6 комірок | зміна видима в межах транзакції, після `ROLLBACK` - без змін |

### 3.4 DELETE (розділ 4)

| № | Що видаляємо | Умова / порядок | Очікуваний результат |
|---|---|---|---|
| 4.1 | Тестовий товар SKU-TEST-DEL | `WHERE sku_code = ...`; на товар немає посилань | 1 рядок |
| 4.2 | Скасована накладна ORD-2026-04 | спочатку `supply_item`, потім `supply_order` (порядок через FK) | 1 позиція, 1 накладна |
| 4.3 | Демо: DELETE за автором + `ROLLBACK` | `created_by = 'Петренко А.'` | 4 рядки видаляються в транзакції, після `ROLLBACK` - залишаються |

### 3.5 Очікувана помилка (окремо)

`DELETE FROM supplier WHERE email = 'info@electro.ua';` - видалення постачальника, який має накладні. FK блокує операцію: `update or delete on table "supplier" violates foreign key constraint`. Це підтверджує, що R-10 (цілісність посилань) працює.

## 4. Перевірка виконання

- [ ] Скрипт `lab3_oltp.sql` виконано з порожньої бази без помилок (розділи 0-5)
- [ ] Блок 4.5 (очікувана помилка) виконано окремо, помилка відповідає очікуваній
- [ ] Результати запитів відповідають таблиці вище
- [ ] Скріншоти pgAdmin з `SELECT * FROM ...` (розділ 5 скрипту) додано до звіту

## 5. Висновки

- `WHERE` в `UPDATE` і `DELETE` обмежує зміни; демо 3.8 і 4.3 показують, що без правильного `WHERE` зміниться вся таблиця, а `ROLLBACK` у транзакції це відкочує.
- Пов'язані зміни (оприбуткування, переміщення, списання) виконані в транзакціях `BEGIN ... COMMIT`, щоб статус, журнал і залишки не розходилися.
- Схема не забезпечує автоматичного узгодження залишків, сум і статусів; ці правила виконуються прикладними запитами, як описано в `spec.md`.
