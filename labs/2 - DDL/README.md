# Лабораторна робота №2 — Перетворення ER-діаграми на схему PostgreSQL

## Мета

Перетворити ER-модель предметної області **Wishlist Service** на реляційну схему PostgreSQL, визначити типи даних, первинні та зовнішні ключі, обмеження цілісності та заповнити таблиці тестовими даними.

## Предметна область

**Wishlist Service** — сервіс для створення списків бажань, додавання товарів до них та резервування товарів іншими користувачами.

Основні сутності:

* `User` — користувач системи;
* `Wishlist` — список бажань користувача;
* `WishlistItem` — товар у списку бажань;
* `Reservation` — поточне резервування товару іншим користувачем.

## Структура бази даних

### `users`

Зберігає інформацію про користувачів.

| Поле            | Тип          | Обмеження        |
| --------------- | ------------ | ---------------- |
| `user_id`       | UUID         | PRIMARY KEY      |
| `name`          | VARCHAR(100) | NOT NULL         |
| `email`         | VARCHAR(255) | NOT NULL, UNIQUE |
| `password_hash` | TEXT         | NOT NULL         |

### `wishlists`

Зберігає списки бажань користувачів.

| Поле          | Тип          | Обмеження              |
| ------------- | ------------ | ---------------------- |
| `wishlist_id` | UUID         | PRIMARY KEY            |
| `user_id`     | UUID         | NOT NULL, FOREIGN KEY  |
| `name`        | VARCHAR(100) | NOT NULL               |
| `description` | TEXT         | nullable               |
| `is_public`   | BOOLEAN      | NOT NULL, DEFAULT TRUE |

Зовнішній ключ:

`wishlists.user_id → users.user_id`

### `wishlist_items`

Зберігає товари, додані до списків бажань.

| Поле           | Тип           | Обмеження               |
| -------------- | ------------- | ----------------------- |
| `item_id`      | UUID          | PRIMARY KEY             |
| `wishlist_id`  | UUID          | NOT NULL, FOREIGN KEY   |
| `name`         | VARCHAR(150)  | NOT NULL                |
| `description`  | TEXT          | nullable                |
| `price`        | NUMERIC(10,2) | NOT NULL, CHECK >= 0    |
| `product_url`  | TEXT          | nullable                |
| `image_url`    | TEXT          | nullable                |
| `is_completed` | BOOLEAN       | NOT NULL, DEFAULT FALSE |

Зовнішній ключ:

`wishlist_items.wishlist_id → wishlists.wishlist_id`

### `reservations`

Зберігає поточні резервування товарів.

| Поле             | Тип       | Обмеження                           |
| ---------------- | --------- | ----------------------------------- |
| `reservation_id` | UUID      | PRIMARY KEY                         |
| `item_id`        | UUID      | NOT NULL, UNIQUE, FOREIGN KEY       |
| `user_id`        | UUID      | NOT NULL, FOREIGN KEY               |
| `reserved_at`    | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

Зовнішні ключі:

* `reservations.item_id → wishlist_items.item_id`
* `reservations.user_id → users.user_id`

`UNIQUE` для `item_id` гарантує, що один товар може мати не більше одного поточного резервування.

## Основні обмеження

У схемі використано:

* `PRIMARY KEY` для унікальної ідентифікації записів;
* `FOREIGN KEY` для забезпечення зв'язків між таблицями;
* `NOT NULL` для обов'язкових полів;
* `UNIQUE` для унікальності email та поточного резервування товару;
* `CHECK (price >= 0)` для заборони від'ємної ціни;
* `DEFAULT` для автоматичних значень `is_public`, `is_completed` та `reserved_at`.

## Тестові дані

База даних заповнюється тестовими даними:

* 4 користувачі;
* 4 списки бажань;
* 5 товарів;
* 3 резервування.

Дані містяться у файлі `seed.sql`.

## SQL-файли

### `schema.sql`

Містить:

* видалення таблиць у правильному порядку;
* створення таблиць;
* визначення типів даних;
* первинні та зовнішні ключі;
* обмеження `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`.

### `seed.sql`

Містить тестові `INSERT`-запити для заповнення всіх таблиць.

## Запуск

1. Запустити Docker Compose:

```bash
docker compose up -d
```

2. Відкрити pgAdmin:

```text
http://localhost:8080
```

3. Підключитися до PostgreSQL:

```text
Host: postgres
Port: 5432
Database: postgres
Username: postgres
Password: password123
```

4. Виконати `schema.sql`.

5. Виконати `seed.sql`.

6. Перевірити створені таблиці та дані за допомогою `SELECT`-запитів.

## Результат

У результаті створено реляційну схему PostgreSQL для **Wishlist Service**, яка відповідає розробленій ER-моделі, містить необхідні зв'язки та обмеження цілісності і заповнена тестовими даними.
