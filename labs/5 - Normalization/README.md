# Лабораторна робота №5. Нормалізація бази даних

## Мета

Перевірити реляційну схему Wishlist Service на відповідність 1НФ, 2НФ і 3НФ. Формалізувати функціональні залежності, перевірити відсутність аномалій вставки, оновлення та видалення і показати, що часткових і транзитивних залежностей немає, тож декомпозиція схеми не потрібна.

## Завдання

- Формалізувати та задокументувати повний набір функціональних залежностей для всіх сутностей схеми.
- Проаналізувати вихідні таблиці на аномалії вставки (Insert), оновлення (Update) та видалення (Delete).
- Продемонструвати поетапну перевірку нормальних форм (1НФ – 2НФ – 3НФ) і на кожному етапі зафіксувати таблиці з атрибутами та ключами.
- Зафіксувати фінальну схему в 3НФ скриптом `CREATE TABLE`. Команди `ALTER TABLE` не потрібні, бо склад таблиць не змінюється.
- Підтвердити, що ER-діаграма лабораторної роботи 2 залишається чинною: нових таблиць і зв'язків немає.
- Перевірити коректність структури в pgAdmin.

## 1. Функціональні залежності (ФЗ) початкової схеми

### 1.1. Таблиця `users`

**Атрибути:**

- `user_id` - первинний ключ (PK);
- `name` - ім'я користувача;
- `email` - електронна пошта (UNIQUE);
- `password_hash` - хеш пароля.

**Функціональні залежності:**

```text
user_id → name, email, password_hash
```

Оскільки `email` має обмеження UNIQUE та NOT NULL, він також однозначно визначає інші атрибути:

```text
email → user_id, name, password_hash
```

**Кандидатні ключі:**

- `user_id` (PK);
- `email` (альтернативний кандидатний ключ).

### 1.2. Таблиця `wishlists`

**Атрибути:**

- `wishlist_id` - первинний ключ (PK);
- `user_id` - ідентифікатор власника списку (FK);
- `name` - назва списку;
- `description` - опис списку;
- `is_public` - статус публічності.

**Функціональна залежність:**

```text
wishlist_id → user_id, name, description, is_public
```

**Кандидатний ключ:**

- `wishlist_id` (PK).

`user_id` не є кандидатним ключем, оскільки він може повторюватися в різних рядках таблиці `wishlists`. Один користувач може мати декілька списків бажань, тому за значенням `user_id` неможливо однозначно визначити конкретний рядок таблиці.

### 1.3. Таблиця `wishlist_items`

**Атрибути:**

- `item_id` — первинний ключ (PK);
- `wishlist_id` — ідентифікатор списку (FK);
- `name` — назва товару;
- `description` — опис товару;
- `price` — ціна товару;
- `product_url` — посилання на товар;
- `image_url` — посилання на зображення;
- `is_completed` — статус виконання бажання.

**Функціональна залежність:**

```text
item_id → wishlist_id, name, description, price, product_url, image_url, is_completed
```

**Кандидатний ключ:**

- `item_id` (PK).

`wishlist_id` не є кандидатним ключем, оскільки він може повторюватися в різних рядках таблиці `wishlist_items`. Один список може містити декілька товарів, тому за значенням `wishlist_id` неможливо однозначно визначити конкретний рядок таблиці.

`product_url` також не є детермінантом. Обмеження UNIQUE на ньому немає, тому одне й те саме посилання може траплятися в різних списках із власною ціною та описом. Назва, ціна і посилання є атрибутами конкретного бажання, а не спільного каталогу товарів. Залежності `product_url → price` у схемі немає.

### 1.4. Таблиця `reservations`

**Атрибути:**

- `reservation_id` — первинний ключ (PK);
- `item_id` — ідентифікатор зарезервованого товару (FK, UNIQUE);
- `user_id` — ідентифікатор користувача, який зарезервував товар (FK);
- `reserved_at` — дата та час резервування.

**Функціональні залежності:**

```text
reservation_id → item_id, user_id, reserved_at
```

Оскільки `item_id` має обмеження UNIQUE та NOT NULL, він також однозначно визначає решту атрибутів:

```text
item_id → reservation_id, user_id, reserved_at
```

**Кандидатні ключі:**

- `reservation_id` (PK);
- `item_id` (альтернативний кандидатний ключ).

`is_completed` у `wishlist_items` і рядок у `reservations` описують різні факти: бажання позначене виконаним і товар зарезервований конкретним користувачем. Між ними немає функціональної залежності. Резерв не визначає прапорець виконання, а прапорець не визначає, хто і коли зарезервував товар.

## 2. Аналіз надлишковості та аномалій у початковій схемі

Надлишковості в початковій схемі немає. Кожен факт зберігається в одній таблиці:

- `users` зберігає ім'я, email і хеш пароля. Ці атрибути не повторюються у `wishlists`, `wishlist_items` і `reservations`.
- `wishlists` зберігає назву, опис і статус публічності списку. Зв'язок із власником тримає `user_id`.
- `wishlist_items` зберігає назву, опис, ціну та посилання позиції. Зв'язок зі списком тримає `wishlist_id`.
- `reservations` зберігає факт резервування. Зв'язки з товаром і користувачем тримають `item_id` та `user_id`.

### 2.1. Аномалія вставки

Аномалія вставки відсутня. Користувача можна додати в `users`, навіть якщо в нього ще немає списку бажань. Список можна додати в `wishlists` без жодної позиції. Позицію можна додати в `wishlist_items` без резервування. Жоден факт не доводиться записувати «про запас» в іншу таблицю, бо атрибути різних сутностей не змішані в одному відношенні.

### 2.2. Аномалія оновлення

Аномалія оновлення відсутня. Зміна email або імені — це один рядок `users`; списки і резерви цього користувача чіпати не потрібно, бо там лежить лише `user_id`. Зміна назви списку — один рядок `wishlists`. Зміна ціни позиції — один рядок `wishlist_items`; у `reservations` ціна не дублюється.

### 2.3. Аномалія видалення

Аномалія видалення відсутня. Видалення останнього списку користувача не знищує його ім'я та email: вони залишаються в `users`. Видалення резервування не знищує позицію списку: вона залишається в `wishlist_items`. Видалення позиції не знищує опис списку.

## 3. Покроковий процес нормалізації (1НФ → 2НФ → 3НФ)

Найвища нормальна форма початкової схеми — 3НФ. Нижче це показано поетапно. На кожному етапі склад атрибутів і ключів той самий.

### 3.1. Перехід до першої нормальної форми (1НФ)

**Вимоги 1НФ:**

- кожен атрибут повинен містити одне атомарне значення;
- відсутні повторювані групи атрибутів;
- кожен запис повинен однозначно ідентифікуватися первинним ключем.

Перевіримо кожну таблицю.

| Таблиця | Аналіз | Результат |
| --- | --- | --- |
| `users` | Ім'я, email та хеш пароля зберігаються окремими атомарними значеннями | 1НФ |
| `wishlists` | Назва, опис та статус публічності зберігаються окремо | 1НФ |
| `wishlist_items` | Назва, опис, ціна та посилання на товар зберігаються окремими атрибутами | 1НФ |
| `reservations` | Ідентифікатори користувача й товару та дата резервування зберігаються окремо | 1НФ |

**Результат переходу до 1НФ:**

Усі чотири таблиці початкової схеми відповідають вимогам першої нормальної форми. Кожна комірка містить одне значення, повторювані групи атрибутів відсутні, а кожен рядок має первинний ключ. Декомпозиція для переходу до 1НФ не потрібна.

**Схема після переходу до 1НФ** (збігається з початковою):

```text
users(user_id, name, email, password_hash)
  PK: user_id
  кандидатний ключ: email

wishlists(wishlist_id, user_id, name, description, is_public)
  PK: wishlist_id
  FK: user_id → users(user_id)

wishlist_items(item_id, wishlist_id, name, description, price, product_url, image_url, is_completed)
  PK: item_id
  FK: wishlist_id → wishlists(wishlist_id)

reservations(reservation_id, item_id, user_id, reserved_at)
  PK: reservation_id
  кандидатний ключ: item_id
  FK: item_id → wishlist_items(item_id)
  FK: user_id → users(user_id)
```

### 3.2. Перехід до другої нормальної форми (2НФ)

**Вимоги 2НФ:**

- таблиця повинна відповідати 1НФ;
- кожен неключовий атрибут повинен повністю залежати від усього кандидатного ключа;
- не повинно бути часткових функціональних залежностей.

Перевіримо наші таблиці:

| Таблиця | Кандидатний ключ | Складений ключ | Часткові залежності |
| --- | --- | --- | --- |
| `users` | `user_id`, `email` | Ні | Немає |
| `wishlists` | `wishlist_id` | Ні | Немає |
| `wishlist_items` | `item_id` | Ні | Немає |
| `reservations` | `reservation_id`, `item_id` | Ні | Немає |

**Результат переходу до 2НФ:**

Усі чотири таблиці відповідають вимогам другої нормальної форми. Кожна таблиця має прості кандидатні ключі, які складаються з одного атрибута. Часткові функціональні залежності неможливі, а всі неключові атрибути повністю залежать від відповідних кандидатних ключів. Декомпозиція для переходу до 2НФ не потрібна. Атрибути і ключі залишаються такими, як після 1НФ.

**Схема після переходу до 2НФ:**

```text
users(user_id, name, email, password_hash)
  PK: user_id
  кандидатний ключ: email

wishlists(wishlist_id, user_id, name, description, is_public)
  PK: wishlist_id
  FK: user_id → users(user_id)

wishlist_items(item_id, wishlist_id, name, description, price, product_url, image_url, is_completed)
  PK: item_id
  FK: wishlist_id → wishlists(wishlist_id)

reservations(reservation_id, item_id, user_id, reserved_at)
  PK: reservation_id
  кандидатний ключ: item_id
  FK: item_id → wishlist_items(item_id)
  FK: user_id → users(user_id)
```

### 3.3. Перехід до третьої нормальної форми (3НФ)

**Вимоги 3НФ:**

- таблиця повинна відповідати 2НФ;
- не повинно бути транзитивних залежностей неключових атрибутів від кандидатного ключа.

#### Таблиця `users`

**Функціональні залежності:**

```text
user_id → name, email, password_hash
email → user_id, name, password_hash
```

Ім'я та хеш пароля залежать від кандидатних ключів. Інших залежностей між неключовими атрибутами не визначено.

#### Таблиця `wishlists`

**Функціональна залежність:**

```text
wishlist_id → user_id, name, description, is_public
```

Атрибути `name`, `description` та `is_public` визначаються ідентифікатором списку. `user_id` їх не визначає: один користувач має кілька списків. Ім'я та email власника зберігаються в `users`, а не в `wishlists`, тому ланцюжка `wishlist_id → user_id → email` у цій таблиці немає.

#### Таблиця `wishlist_items`

**Функціональна залежність:**

```text
item_id → wishlist_id, name, description, price, product_url, image_url, is_completed
```

Усі неключові атрибути залежать від `item_id`. `wishlist_id` не визначає назву чи ціну позиції. `product_url` не є ключем і не визначає ціну, тож транзитивної залежності `item_id → product_url → price` немає.

#### Таблиця `reservations`

**Функціональні залежності:**

```text
reservation_id → item_id, user_id, reserved_at
item_id → reservation_id, user_id, reserved_at
```

Обидва кандидатні ключі однозначно визначають усі інші атрибути запису. `user_id` не визначає `reserved_at`: один користувач може мати кілька резервів. Інформація про користувача та товар зберігається в окремих таблицях, а в `reservations` використовуються зовнішні ключі.

**Результат переходу до 3НФ:**

Усі чотири таблиці відповідають вимогам третьої нормальної форми. Транзитивних залежностей, які вимагали б декомпозиції, немає. Схема після 3НФ збігається зі схемою після 2НФ.

**Схема після переходу до 3НФ:**

```text
users(user_id, name, email, password_hash)
  PK: user_id
  кандидатний ключ: email

wishlists(wishlist_id, user_id, name, description, is_public)
  PK: wishlist_id
  FK: user_id → users(user_id)

wishlist_items(item_id, wishlist_id, name, description, price, product_url, image_url, is_completed)
  PK: item_id
  FK: wishlist_id → wishlists(wishlist_id)

reservations(reservation_id, item_id, user_id, reserved_at)
  PK: reservation_id
  кандидатний ключ: item_id
  FK: item_id → wishlist_items(item_id)
  FK: user_id → users(user_id)
```

## Підсумкова схема бази даних

Команди `ALTER TABLE` не застосовуються: жоден стовпець не виносився в нову таблицю і жоден зв'язок не змінювався. Фінальний DDL збігається з початковим і записаний у `schema.sql`.

ER-діаграма лабораторної роботи 2 залишається актуальною. Нових таблиць і зв'язків після перевірки 3НФ не з'явилося, тому окрема перебудована діаграма не потрібна.

```sql
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL
);

CREATE TABLE wishlists (
    wishlist_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_public BOOLEAN NOT NULL DEFAULT TRUE,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE wishlist_items (
    item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wishlist_id UUID NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    product_url TEXT,
    image_url TEXT,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,

    FOREIGN KEY (wishlist_id)
        REFERENCES wishlists(wishlist_id)
        ON DELETE CASCADE
);

CREATE TABLE reservations (
    reservation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    item_id UUID NOT NULL UNIQUE,
    user_id UUID NOT NULL,
    reserved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (item_id)
        REFERENCES wishlist_items(item_id)
        ON DELETE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);
```

## Висновок

Початкова схема Wishlist Service уже відповідає третій нормальній формі. Це найвища нормальна форма, якої вимагає лабораторна робота.

- На етапі 1НФ підтверджено атомарність усіх атрибутів.
- На етапі 2НФ часткових функціональних залежностей немає: усі кандидатні ключі прості.
- На етапі 3НФ транзитивних функціональних залежностей немає.
- Аномалії вставки, оновлення і видалення відсутні, бо кожен факт зберігається в одній таблиці.

Декомпозиція не потрібна. Початкова структура з чотирьох таблиць залишається без змін.
