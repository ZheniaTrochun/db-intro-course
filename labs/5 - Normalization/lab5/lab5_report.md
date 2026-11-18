# Лабораторна робота 5: Нормалізація бази даних

**База:** `logistics` (схема лабораторної 2, `docs/adr/schema.sql`)
**Скрипти:** `docs/lab5/lab5_normalization.sql` (перевірка функціональних залежностей), `docs/lab5/migration_batch_to_order.sql` (міграція зі схеми лаби 2), `docs/lab5/lab5_schema_3nf.sql` (фінальна схема: DROP і CREATE)
**Діаграма:** `docs/lab5/diagram_3nf.mmd` (код), `docs/lab5/diagram_3nf.png` (зображення)
**Попередні роботи:** `docs/lab2_report.docx`, `docs/adr/spec.md`, `docs/lab3/lab3_report.md`

## 1. Мета

Проаналізувати схему `logistics` з лабораторної 2 на надлишковість і аномалії, записати функціональні залежності (ФЗ) кожної таблиці, визначити нормальну форму, усунути порушення і показати фінальну схему в 3НФ.

## 2. Вихідна схема (лабораторна 2)

Таблиці: `supplier`, `product`, `warehouse_location`, `supply_order`, `supply_item`, `inventory_stock`, `inventory_movement`. Ключі і обмеження описані в `docs/adr/schema.sql`.

### 2.1 Функціональні залежності та ключі

| Таблиця | Кандидатні ключі | Функціональні залежності | Найвища НФ |
|---|---|---|---|
| `supplier` | `supplier_id`, `email` | `supplier_id → усі атрибути`; `email → усі атрибути` | BCNF |
| `product` | `product_id`, `sku_code` | `product_id → усі`; `sku_code → усі` | BCNF |
| `warehouse_location` | `location_id`, `location_code`, `(zone, shelf_number)` | `location_id → усі`; `location_code → усі`; `(zone, shelf_number) → location_id, location_code, max_capacity` | BCNF |
| `supply_order` | `order_id`, `order_number` | `order_id → усі`; `order_number → усі`; `order_id → total_cost` (похідний, див. розд. 3.2) | BCNF |
| `supply_item` | `(order_id, product_id)` | `(order_id, product_id) → location_id, quantity, unit_price, batch_number, expiry_date`; `order_id → batch_number` (часткова, за правилом партій) | 1НФ (2НФ порушено) |
| `inventory_stock` | `(product_id, location_id)` | `(product_id, location_id) → quantity` | BCNF |
| `inventory_movement` | `movement_id` | `movement_id → усі` | BCNF |

Після виправлення (розд. 5) `supply_item` буде в 3НФ, `supply_order` - у BCNF з `batch_number`.

Транзитивну залежність `batch_number → expiry_date` ми перевірили: вона не виконується. Партія `P-2026-0101` містить товари з різними термінами (NULL для SKU-UTP-5E і 2027-12-31 для SKU-RJ45-100), тому `expiry_date` належить парі «партія-товар», а не самій партії.

### 2.2 Перевірка нормальних форм початкової схеми

| Таблиця | 1НФ | 2НФ | 3НФ |
|---|---|---|---|
| `supplier`, `product`, `warehouse_location`, `inventory_stock`, `inventory_movement` | так | так | так |
| `supply_order` | так | так | так |
| `supply_item` | так | **ні** | так |

Найвища нормальна форма початкової схеми - **1НФ**: через порушення 2НФ у `supply_item` схема не досягає 2НФ.

## 3. Аналіз порушень

### 3.1 Порушення 2НФ: `supply_item.batch_number`

Ключ `supply_item` складений: `(order_id, product_id)`. Ми бачимо, що `batch_number` визначається лише `order_id`, тобто частиною ключа. Це часткова залежність.

Умова: партія постачання однакова для всієї накладної (одна поставка - один номер партії). Це правило ми обрали для лабораторної. За ним у кожній з 5 накладних усі позиції мають однакову партію: `lab5_normalization.sql`, блок 5, повертає 0 рядків.

Аномалії, які з цього випливають:
- **Оновлення:** якщо номер партії накладної змінився, його треба оновити в кожній позиції; пропуск одного рядка дає суперечливі дані.
- **Вставка:** неможливо зареєструвати партію накладної без позицій, бо `batch_number` існує лише в позиції.
- **Надмірність:** один номер партії повторюється в кожній позиції накладної.

### 3.2 Не порушення: `supply_order.total_cost`

`total_cost` дорівнює сумі `quantity * unit_price` позицій. Це похідна колонка, а не порушення нормальної форми: ФЗ між неключовими атрибутами однієї таблиці немає. Це денормалізація, зафіксована в `spec.md` (розд. 4, пункт 3). Коректність перевіряє блок 4 `lab5_normalization.sql` (0 рядків).

### 3.3 Не порушення: інші таблиці

Для кожної іншої таблиці всі детермінанти є надключами, тому порушень 2НФ, 3НФ і НФБК немає.

## 4. Нормалізація

### 4.1 Крок 1: 1НФ

Вихідна схема вже в 1НФ: усі атрибути атомарні, повторюваних груп немає (кожна позиція накладної - окремий рядок). Таблиці на цьому етапі з ключами:
- `supply_order(order_id PK, order_number UK, supplier_id FK, supply_date, total_cost, status)`
- `supply_item(order_id, product_id PK складений, location_id FK, quantity, unit_price, batch_number, expiry_date)`
- решта таблиць (`supplier`, `product`, `warehouse_location`, `inventory_stock`, `inventory_movement`) з ключами за розд. 2.1

Змін на цьому кроці не потрібно.

### 4.2 Крок 2: 2НФ - винесення `batch_number` у накладну

Порушення: `order_id → batch_number` (частина ключа `supply_item`).

Рішення: перенести `batch_number` з `supply_item` у `supply_order`, де він визначається повним ключем `order_id`.

Було:
- `supply_order(order_id PK, order_number UK, supplier_id FK, supply_date, total_cost, status)`
- `supply_item(order_id, product_id PK, location_id, quantity, unit_price, batch_number, expiry_date)`

Стало:
- `supply_order(order_id PK, order_number UK, supplier_id FK, supply_date, total_cost, status, batch_number NOT NULL)`
- `supply_item(order_id, product_id PK, location_id, quantity, unit_price, expiry_date)`

`expiry_date` лишається в `supply_item`: він залежить від пари «партія-товар», тобто від рядка позиції.

Зміни в таблицях (`ALTER TABLE`):
```sql
ALTER TABLE supply_order ADD COLUMN batch_number VARCHAR(50);
UPDATE supply_order o
SET batch_number = (
    SELECT DISTINCT i.batch_number FROM supply_item i WHERE i.order_id = o.order_id
);
ALTER TABLE supply_order ALTER COLUMN batch_number SET NOT NULL;
ALTER TABLE supply_item DROP COLUMN batch_number;
```

Значення для `UPDATE` беремо з позицій накладних скалярним підзапитом (він повертає одне значення, бо в кожній накладній одна партія). Перед запуском ми перевіряємо, що запит `SELECT order_id FROM supply_item GROUP BY order_id HAVING COUNT(DISTINCT batch_number) > 1` повертає 0 рядків, тобто в кожній накладній одна партія. Усю міграцію ми виконуємо в одній транзакції (`BEGIN` / `COMMIT`), скрипт `docs/lab5/migration_batch_to_order.sql`.

### 4.3 Крок 3: 3НФ

Після кроку 2 транзитивних залежностей немає: жоден неключовий атрибут не визначає інший неключовий атрибут. Додаткової декомпозиції не потрібно.

### 4.4 Перевірка НФБК

Усі детермінанти в усіх таблицях є надключами. Отже, фінальна схема також у НФБК.

## 5. Фінальна схема

Змінені таблиці (повний скрипт з DROP, CREATE і даними: `docs/lab5/lab5_schema_3nf.sql`):

```sql
CREATE TABLE supply_order (
    order_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_number VARCHAR(50)   NOT NULL UNIQUE,
    supplier_id  INTEGER       NOT NULL REFERENCES supplier (supplier_id),
    supply_date  TIMESTAMP     NOT NULL DEFAULT now(),
    total_cost   NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (total_cost >= 0),
    status       order_status  NOT NULL DEFAULT 'draft',
    batch_number VARCHAR(50)   NOT NULL
);

CREATE TABLE supply_item (
    order_id     INTEGER       NOT NULL REFERENCES supply_order (order_id),
    product_id   INTEGER       NOT NULL REFERENCES product (product_id),
    location_id  INTEGER       NOT NULL REFERENCES warehouse_location (location_id),
    quantity     INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    expiry_date  DATE,
    PRIMARY KEY (order_id, product_id)
);
```

Інші таблиці фінальної схеми (`supplier`, `product`, `warehouse_location`, `inventory_stock`, `inventory_movement`) без змін, їх `CREATE TABLE` є в `lab5_schema_3nf.sql`.

Діаграма фінальної схеми: `docs/lab5/diagram_3nf.png`.

## 6. Перевірка виконання

- [x] Визначено ФЗ для всіх 7 таблиць схеми лабораторної 2 (розд. 2.1).
- [x] Визначено найвищу НФ початкової схеми (1НФ) і причину (порушення 2НФ у `supply_item`).
- [x] Показано покроковий перехід 1НФ → 2НФ → 3НФ → НФБК (розд. 4).
- [x] Наведено `ALTER TABLE` для змінених таблиць і фінальні `CREATE TABLE` (розд. 4.2, 5).
- [x] Скрипти виконано на PostgreSQL-сумісному движку PGlite (WebAssembly), без помилок: `schema.sql` → `lab5_normalization.sql` → `migration_batch_to_order.sql`; окремо `lab5_schema_3nf.sql`.
- [x] Результати перевірок ФЗ на даних: блоки 1-5, 7-9 повернули 0 рядків; блок 6 повернув 2 партії (`P-2026-0101`, `P-2026-0202`), де термін залежить від товару.
- [x] Після міграції у кожній з 5 накладних є партія, у `supply_item` колонки `batch_number` немає, порожніх значень немає.
- [x] Діаграму `diagram_3nf.mmd` експортовано в `diagram_3nf.png`.
- [ ] Повторно перевірити скрипти в pgAdmin (psql у системі немає; PGlite не є повним PostgreSQL).

## 7. Внесок учасників

### Бенедюк Ярослав - аналіз, знаходження порушень, виправлення

- Проаналізував схему лабораторної 2 і знайшов, що `supply_item` має складений ключ `(order_id, product_id)`, а `batch_number` визначається лише `order_id` - часткова залежність, порушення 2НФ.
- Знайшов, що `total_cost` у `supply_order` є похідною колонкою (денормалізація), а не порушенням нормальної форми.
- Знайшов, що `batch_number → expiry_date` не виконується: партія `P-2026-0101` має термін NULL для одного товару і 2027-12-31 для іншого.
- Виправив порушення 2НФ: переніс `batch_number` з `supply_item` у `supply_order` (ALTER TABLE: ADD COLUMN, SET NOT NULL, DROP COLUMN).
- Написав міграцію `migration_batch_to_order.sql` у транзакції (BEGIN / COMMIT).
- Написав фінальну схему `lab5_schema_3nf.sql` з DROP і CREATE для всіх таблиць.
- Написав кроки нормалізації (1НФ, 2НФ, 3НФ, НФБК) з проміжними таблицями і ключами (розд. 4).

### Прасол Максим - перевірка, діаграма, верифікація

- Визначив функціональні залежності і кандидатні ключі для всіх 7 таблиць схеми лабораторної 2 (розд. 2.1).
- Встановив, що найвища НФ початкової схеми - 1НФ (через порушення 2НФ у `supply_item`).
- Написав `lab5_normalization.sql` - 9 блоків перевірок ФЗ на даних.
- Запустив скрипти в PGlite, зафіксував результати: блоки 1-5, 7-9 повертають 0 рядків, блок 6 повертає 2 партії.
- Перевірив, що після міграції кожна з 5 накладних має свою партію, а в `supply_item` колонки `batch_number` немає.
- Створив діаграму `diagram_3nf.mmd` і експортував у `diagram_3nf.png`.

### Спільна робота

- Узгодили правило: партія на накладну, а не на рядок. Це ключове рішення, від якого залежить усе виправлення.
- Перевірили, що фінальна схема відповідає 3НФ і НФБК.
- Узгодили звіт з результатами перевірок (посилання на розділи, очікувані результати).

## 8. Висновки

- Схема лабораторної 2 має одне порушення 2НФ: `batch_number` у `supply_item` залежить лише від `order_id` (за правилом партій «одна партія на накладну»).
- Порушення усунено винесенням `batch_number` у `supply_order`. Після цього схема в 3НФ і НФБК.
- `total_cost` залишено як свідому денормалізацію, зафіксовану і перевірену запитом.
- `expiry_date` лишається в `supply_item`, бо залежить від пари «партія-товар», а не від самої партії.
- Правило «одна партія на накладну» ми обрали для цієї лабораторної. Якщо в реальному складі партія може бути різною для товарів однієї накладної, порушення немає, і схема вже в 3НФ.
