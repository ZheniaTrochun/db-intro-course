# Лабораторна робота 5

## 1. Початкова (ненормалізована) схема

Як вихідну схему розглядаємо журнал документів руху — одну таблицю, в яку записують
кожен документ (надходження, переміщення, списання) разом з усіма його товарами, як у паперовій накладній.

**MOVEMENT_JOURNAL** (document_no, type, occurred_at, note,
warehouse_name, warehouse_address,
to_warehouse_name, to_warehouse_address,
supplier_name, supplier_phone, supplier_email,
**{** sku, product_name, category_name, unit, quantity, unit_cost **}** )

Фігурні дужки `{ }` позначають **повторювану групу**: в одному документі кілька товарів.

### Приклад даних

| document_no | type | occurred_at | warehouse_name | warehouse_address | to_warehouse_name | supplier_name | supplier_phone | товари (sku, назва, категорія, од., к-сть, ціна) |
|---|---|---|---|---|---|---|---|---|
| RCV-0001 | receipt | 2026-09-01 | Центральний склад | м. Київ, вул. Промислова, 12 | — | ТОВ "Фірма1" | +380441234567 | MBA-13-M3-8-256, MacBook Air 13, Ноутбуки, шт, 10, 45000; MBP-14-M4-16-512, MacBook Pro 14, Ноутбуки, шт, 6, 75000; AIRPODS-4, AirPods 4, Аксесуари, шт, 50, 6000 |
| RCV-0002 | receipt | 2026-09-02 | Склад Лівий берег | м. Київ, просп. Броварський, 45 | — | ТОВ "Фірма2" | +380672223344 | IPH-16-128, iPhone 16, Смартфони, шт, 20, 36000; AIRPODS-4, AirPods 4, Аксесуари, шт, 30, 5900 |
| RCV-0003 | receipt | 2026-09-05 | Центральний склад | м. Київ, вул. Промислова, 12 | — | ТОВ "Фірма3" | +380503334455 | IPAD-AIR-11, iPad Air 11, Планшети, шт, 15, 27000 |
| TRF-0001 | transfer | 2026-09-08 | Центральний склад | м. Київ, вул. Промислова, 12 | Склад Правий берег | — | — | MBA-13-M3-8-256, MacBook Air 13, Ноутбуки, шт, 3; IPAD-AIR-11, iPad Air 11, Планшети, шт, 5; AIRPODS-4, AirPods 4, Аксесуари, шт, 20 |
| WO-0001 | write_off | 2026-09-12 | Склад Лівий берег | м. Київ, просп. Броварський, 45 | — | — | — | IPH-16-128, iPhone 16, Смартфони, шт, 2; AIRPODS-4, AirPods 4, Аксесуари, шт, 1 |

### Проблеми (аномалії)

- **Надлишковість.** Адреса «м. Київ, вул. Промислова, 12» записана в трьох документах,
назва й категорія AirPods 4 — у п'яти.
- **Аномалія оновлення.** якщо Центральний склад переїде, адресу доведеться змінити в трьох документах (RCV-0001, RCV-0003, TRF-0001);
пропустили один — дані суперечать одне одному.
- **Аномалія вставки.** Не можна додати нового постачальника (ФОП Фоп1) або новий товар,
поки для них немає жодного документа.
- **Аномалія видалення.** Якщо видалити документ RCV-0003, зникне вся інформація
про постачальника ТОВ "Фірма3" (його телефон і email більше ніде не записані).

### Нормальна форма початкової схеми

Таблиця **не відповідає навіть 1NF**: колонка «товари» містить список значень
(повторювану групу), тобто атрибути не атомарні.

## 2. Функціональні залежності початкової схеми

Позначення: `X → Y` означає «значення X однозначно визначає значення Y».

### Припущення

- `document_no` унікальний: один номер — один документ.
- `sku` унікальний: один артикул — один товар.
- Назва складу (`warehouse_name`) і назва постачальника (`supplier_name`) однозначно ідентифікують склад і постачальника.

### Мінімальний набір ФЗ

| № | Функціональна залежність | Пояснення |
|---|---|---|
| ФЗ1 | `document_no → type, occurred_at, note, warehouse_name, to_warehouse_name, supplier_name` | номер документа визначає його тип, дату, примітку, склади і постачальника |
| ФЗ2 | `warehouse_name → warehouse_address` | склад визначає свою адресу |
| ФЗ3 | `to_warehouse_name → to_warehouse_address` | склад призначення визначає свою адресу |
| ФЗ4 | `supplier_name → supplier_phone, supplier_email` | постачальник визначає свої контакти |
| ФЗ5 | `sku → product_name, category_name, unit` | артикул визначає назву, категорію та одиницю товару |
| ФЗ6 | `{document_no, sku} → quantity, unit_cost` | кількість і ціна залежать від пари «документ + товар» |

Набір мінімальний: залежності, які виводяться з інших, не наведені.
Наприклад, `document_no → warehouse_address` випливає з ФЗ1 і ФЗ2 (транзитивно), тому окремо не записується.

### Ключ

Після видалення повторюваної групи (1NF) кожен рядок — одна позиція документа,
і **потенційний ключ** — `{document_no, sku}`: лише ця пара визначає всі атрибути.

## 3. Перехід до 1NF

**Що порушує 1NF:** повторювана група `{ sku, product_name, category_name, unit, quantity, unit_cost }`

**Як виправити:** розгортаємо групу — кожен товар документа стає окремим рядком.
Дані документа (номер, дата, склад) повторюються в кожному рядку цього документа.

**MOVEMENT_1NF** (<u>document_no</u>, <u>sku</u>, type, occurred_at, note,
warehouse_name, warehouse_address, to_warehouse_name, to_warehouse_address,
supplier_name, supplier_phone, supplier_email,
product_name, category_name, unit, quantity, unit_cost)

**Первинний ключ:** `{document_no, sku}`

### Приклад даних (частина колонок)

| document_no | sku | type | warehouse_name | warehouse_address | supplier_name | product_name | category_name | quantity | unit_cost |
|---|---|---|---|---|---|---|---|---|---|
| RCV-0001 | MBA-13-M3-8-256 | receipt | Центральний склад | м. Київ, вул. Промислова, 12 | ТОВ "Фірма1" | MacBook Air 13 | Ноутбуки | 10 | 45000 |
| RCV-0001 | MBP-14-M4-16-512 | receipt | Центральний склад | м. Київ, вул. Промислова, 12 | ТОВ "Фірма1" | MacBook Pro 14 | Ноутбуки | 6 | 75000 |
| RCV-0001 | AIRPODS-4 | receipt | Центральний склад | м. Київ, вул. Промислова, 12 | ТОВ "Фірма1" | AirPods 4 | Аксесуари | 50 | 6000 |
| RCV-0002 | IPH-16-128 | receipt | Склад Лівий берег | м. Київ, просп. Броварський, 45 | ТОВ "Фірма2" | iPhone 16 | Смартфони | 20 | 36000 |
| RCV-0002 | AIRPODS-4 | receipt | Склад Лівий берег | м. Київ, просп. Броварський, 45 | ТОВ "Фірма2" | AirPods 4 | Аксесуари | 30 | 5900 |
| … | … | … | … | … | … | … | … | … | … |

Усього 11 рядків — по одному на кожну позицію документів.

### Результат

- Усі значення атомарні, повторюваних груп немає — **таблиця в 1NF**.
- Надлишковість навіть зросла: дані документа RCV-0001 повторюються в 3 рядках, а назва «AirPods 4» — у 5.

## 4. Перехід до 2NF

**Що порушує 2NF:** часткові залежності від складеного ключа `{document_no, sku}`:

- ФЗ1: `document_no → type, occurred_at, note, warehouse_name, …` — залежить лише від `document_no`;
- ФЗ5: `sku → product_name, category_name, unit` — залежить лише від `sku`.

**Як виправити:** виносимо атрибути, що залежать від частини ключа, в окремі таблиці з цією частиною як первинним ключем. У вихідній таблиці лишаються тільки атрибути, що залежать від **усього** ключа (ФЗ6).

### Нові таблиці

**MOVEMENT_2NF** (<u>document_no</u>, type, occurred_at, note, warehouse_name, warehouse_address, to_warehouse_name, to_warehouse_address, supplier_name, supplier_phone, supplier_email)
— PK: `document_no`

**PRODUCT_2NF** (<u>sku</u>, product_name, category_name, unit)
— PK: `sku`

**MOVEMENT_ITEM_2NF** (<u>document_no</u>, <u>sku</u>, quantity, unit_cost)
— PK: `{document_no, sku}`
— FK: `document_no` → MOVEMENT_2NF, `sku` → PRODUCT_2NF

### Приклад даних

MOVEMENT_2NF (частина колонок):

| document_no | type | warehouse_name | warehouse_address | supplier_name | supplier_phone |
|---|---|---|---|---|---|
| RCV-0001 | receipt | Центральний склад | м. Київ, вул. Промислова, 12 | ТОВ "Фірма1" | +380441234567 |
| RCV-0002 | receipt | Склад Лівий берег | м. Київ, просп. Броварський, 45 | ТОВ "Фірма2" | +380672223344 |
| RCV-0003 | receipt | Центральний склад | м. Київ, вул. Промислова, 12 | ТОВ "Фірма3" | +380503334455 |
| TRF-0001 | transfer | Центральний склад | м. Київ, вул. Промислова, 12 | — | — |
| WO-0001 | write_off | Склад Лівий берег | м. Київ, просп. Броварський, 45 | — | — |

PRODUCT_2NF:

| sku | product_name | category_name | unit |
|---|---|---|---|
| MBA-13-M3-8-256 | MacBook Air 13 M3 8/256GB | Ноутбуки | шт |
| MBP-14-M4-16-512 | MacBook Pro 14 M4 16/512GB | Ноутбуки | шт |
| IPH-16-128 | iPhone 16 128GB | Смартфони | шт |
| IPAD-AIR-11 | iPad Air 11 128GB | Планшети | шт |
| AIRPODS-4 | AirPods 4 | Аксесуари | шт |

MOVEMENT_ITEM_2NF (частина рядків):

| document_no | sku | quantity | unit_cost |
|---|---|---|---|
| RCV-0001 | MBA-13-M3-8-256 | 10 | 45000 |
| RCV-0001 | MBP-14-M4-16-512 | 6 | 75000 |
| RCV-0001 | AIRPODS-4 | 50 | 6000 |
| … | … | … | … |

### Що виправлено

- Дані документа записані **один раз** (а не в кожному рядку товару).
- Назва, категорія й одиниця товару записані **один раз** — «AirPods 4» більше не повторюється 5 разів.
- Новий товар можна додати без документа (аномалія вставки для товарів усунена).

## 5. Перехід до 3NF

**Що порушує 3NF:** транзитивні залежності в MOVEMENT_2NF:

- `document_no → warehouse_name → warehouse_address`
- `document_no → to_warehouse_name → to_warehouse_address`
- `document_no → supplier_name → supplier_phone, supplier_email`

**Як виправити:** виносимо «проміжний» атрибут разом з усім, що від нього залежить, в окрему таблицю. У документі лишається лише посилання (зовнішній ключ).

### 5.1. Нові таблиці

**WAREHOUSE** (<u>warehouse_name</u>, warehouse_address)
— PK: `warehouse_name`

**SUPPLIER** (<u>supplier_name</u>, supplier_phone, supplier_email)
— PK: `supplier_name`

**MOVEMENT_3NF** (<u>document_no</u>, type, occurred_at, note,
warehouse_name, to_warehouse_name, supplier_name)
— PK: `document_no`
— FK: `warehouse_name` → WAREHOUSE, `to_warehouse_name` → WAREHOUSE, `supplier_name` → SUPPLIER

Склад призначення окремої таблиці не потребує: це той самий склад, тому
`to_warehouse_name` посилається на ту саму таблицю WAREHOUSE, а `to_warehouse_address` більше не зберігається (адресу беремо зі складу).

Таблиці PRODUCT_2NF і MOVEMENT_ITEM_2NF лишаються без змін — вони вже в 3NF.

### 5.2. Сурогатні ключі та таблиця-довідник

Для фінальної схеми робимо ще два покращення:

1. **Сурогатні ключі** (`SERIAL`): замість назв і номерів первинним ключем стає число — `warehouse_id`, `supplier_id`, `movement_id`, `product_id`. Назву складу чи артикул можна змінити, не оновлюючи посилання в інших таблицях. Природні ключі (`document_no`, `sku`) лишаються унікальними (`UNIQUE`).
2. **Таблиця-довідник CATEGORY** (`category_id`, `name`): категорія записується один раз, а товар посилається на неї через `category_id`. Це не дає записати одну категорію по-різному («Ноутбуки» / «ноутбуки») і дозволяє створити категорію без товарів.

### 5.3. Фінальна схема (3NF)

| Таблиця | Атрибути | PK | FK |
|---|---|---|---|
| category | category_id, name | category_id | — |
| warehouse | warehouse_id, name, address | warehouse_id | — |
| supplier | supplier_id, name, phone, email | supplier_id | — |
| product | product_id, category_id, sku, name, unit | product_id | category_id → category |
| movement | movement_id, warehouse_id, to_warehouse_id, supplier_id, document_no, occurred_at, type, note | movement_id | warehouse_id, to_warehouse_id → warehouse; supplier_id → supplier |
| movement_item | movement_id, product_id, quantity, unit_cost | (movement_id, product_id) | movement_id → movement; product_id → product |
| stock | warehouse_id, product_id, quantity | (warehouse_id, product_id) | warehouse_id → warehouse; product_id → product |

### Чому це 3NF

У кожній таблиці кожен неключовий атрибут залежить **від ключа, від усього ключа і ні від чого, крім ключа**:

- немає повторюваних груп — 1NF;
- у таблицях зі складеним ключем (`movement_item`, `stock`) кількість і ціна залежать від усієї пари — 2NF;
- немає залежностей «неключове → неключове»: адреса лежить у складі, контакти — у постачальнику, категорія — у довіднику — 3NF.

### Які аномалії усунено

| Аномалія | Було | Стало |
|---|---|---|
| Оновлення | телефон ТОВ "Фірма1" — у кожному її документі | телефон записаний один раз у `supplier` |
| Вставка | не можна додати ФОП Фоп1 без документа | ФОП Фоп1 є в `supplier` без жодного документа |
| Видалення | видалення RCV-0003 стирало дані ТОВ "Фірма3" | постачальник лишається в `supplier`; більше того, `ON DELETE RESTRICT` не дасть видалити постачальника, у якого є документи |
| Надлишковість | адреса складу — у 3 документах | адреса — один раз у `warehouse` |

### Примітка про таблицю stock

Таблиця `stock` сама по собі в 3NF: `(warehouse_id, product_id) → quantity`.
Проте її дані похідні — залишок можна обчислити з документів руху (надходження + вхідні переміщення − вихідні переміщення − списання).
Ми зберігаємо її свідомо, щоб отримувати залишок одним запитом без підсумовування всієї історії документів. Узгодженість `stock` з документами забезпечується транзакціями (лабораторна робота 3).

## 6. Зміни таблиць (ALTER TABLE)

Перехід від 2NF до 3NF записаний як SQL-міграція з командами `ALTER TABLE` у файлі `Lab5_alter.sql`.