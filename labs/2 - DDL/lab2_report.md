# Лабораторна 2

### Юнцов Олександр ІМ-о51

Схему створено за ER-діаграмою з лабораторної 1 (застосунок, що відстежує повітряні цілі над Україною й сповіщає користувачів, коли ціль наближається до обраного міста). Кожна сутність стала таблицею, кожен зв'язок 1:N реалізовано зовнішнім ключем на стороні "багато". Зв'язок "користувач - місто" (M:N) реалізовано через таблицю `subscription`, яка має власні атрибути (радіус, мінімальний рівень загрози). Для первинних ключів використано `SERIAL`.

## Таблиці

### oblast

| Стовпець | Тип | Обмеження |
|---|---|---|
| oblast_id | SERIAL | PRIMARY KEY |
| name | VARCHAR(100) | NOT NULL, UNIQUE |

### city

| Стовпець | Тип | Обмеження |
|---|---|---|
| city_id | SERIAL | PRIMARY KEY |
| oblast_id | INTEGER | NOT NULL, FOREIGN KEY `oblast(oblast_id)` |
| name | VARCHAR(100) | NOT NULL |
| latitude | NUMERIC(9,6) | NOT NULL, CHECK від -90 до 90 |
| longitude | NUMERIC(9,6) | NOT NULL, CHECK від -180 до 180 |
| population | INTEGER | CHECK (population >= 0) |

Додатково: `UNIQUE (name, oblast_id)`, тобто в одній області не може бути двох міст з однаковою назвою.

### user_account

| Стовпець | Тип | Обмеження |
|---|---|---|
| user_id | SERIAL | PRIMARY KEY |
| full_name | VARCHAR(150) | NOT NULL |
| email | VARCHAR(255) | NOT NULL, UNIQUE |
| telegram_chat_id | VARCHAR(50) | може бути NULL (канал сповіщень необов'язковий) |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

### data_source

| Стовпець | Тип | Обмеження |
|---|---|---|
| source_id | SERIAL | PRIMARY KEY |
| name | VARCHAR(150) | NOT NULL |
| source_kind | VARCHAR(30) | NOT NULL, CHECK: `radar`, `official_channel` або `monitoring_channel` |
| reliability | INTEGER | NOT NULL, DEFAULT 3, CHECK від 1 до 5 |

### air_target

| Стовпець | Тип | Обмеження |
|---|---|---|
| target_id | SERIAL | PRIMARY KEY |
| source_id | INTEGER | NOT NULL, FOREIGN KEY `data_source(source_id)` |
| target_type | VARCHAR(50) | NOT NULL |
| status | VARCHAR(20) | NOT NULL, DEFAULT `active`, CHECK: `active`, `neutralized`, `left_territory`, `lost` |
| latitude | NUMERIC(9,6) | NOT NULL, CHECK від -90 до 90 |
| longitude | NUMERIC(9,6) | NOT NULL, CHECK від -180 до 180 |
| speed_kmh | INTEGER | CHECK (speed_kmh >= 0) |
| last_seen_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

### subscription

| Стовпець | Тип | Обмеження |
|---|---|---|
| subscription_id | SERIAL | PRIMARY KEY |
| user_id | INTEGER | NOT NULL, FOREIGN KEY `user_account(user_id)`, ON DELETE CASCADE |
| city_id | INTEGER | NOT NULL, FOREIGN KEY `city(city_id)` |
| radius_km | INTEGER | NOT NULL, CHECK від 10 до 300 |
| min_threat_level | INTEGER | NOT NULL, DEFAULT 1, CHECK від 1 до 5 |
| is_active | BOOLEAN | NOT NULL, DEFAULT TRUE |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

Додатково: `UNIQUE (user_id, city_id)`, тобто пара "користувач + місто" не повторюється.

### alert

| Стовпець | Тип | Обмеження |
|---|---|---|
| alert_id | SERIAL | PRIMARY KEY |
| subscription_id | INTEGER | NOT NULL, FOREIGN KEY `subscription(subscription_id)`, ON DELETE CASCADE |
| target_id | INTEGER | NOT NULL, FOREIGN KEY `air_target(target_id)` |
| distance_km | NUMERIC(6,2) | NOT NULL, CHECK від 0 до 300 |
| threat_level | INTEGER | NOT NULL, CHECK від 1 до 5 |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| delivery_status | VARCHAR(20) | NOT NULL, DEFAULT `pending`, CHECK: `pending`, `sent`, `failed` |

## Важливі обмеження та припущення

- Бізнес-правила з лабораторної 1 реалізовано обмеженнями `CHECK`: радіус підписки 10-300 км, рівень загрози 1-5, допустимі значення статусу цілі, типу джерела та статусу доставки.
- Унікальність підписки 'користувач + місто' гарантується обмеженням `UNIQUE (user_id, city_id)`.
- У `alert.distance_km` діапазон розширено до 0-300 км (у ERD було 10-300), бо ціль може бути ближче ніж 10 км до міста.
- `ON DELETE CASCADE` встановлено для `subscription.user_id` та `alert.subscription_id`: після видалення користувача зникають його підписки та пов'язані сповіщення.
- Правило 'для однієї пари підписка + ціль повторні сповіщення не надсилаються частіше, ніж раз на задану кількість хвилин' та умова 'відстань менша за радіус, рівень загрози більший за мінімальний' залежать від значень у різних таблицях і реалізуються логікою застосунку, а не обмеженнями схеми. Тестові дані при цьому їм відповідають.
