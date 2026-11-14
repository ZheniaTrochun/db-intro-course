# Лабораторна робота 5

## Аналіз початкової схеми

Початкова схема бази даних знаходиться у Другій нормальній формі (2NF). 
Тому, що:
1. Всі таблиці відповідають критеріям 1NF (всі атрибути є атомарними, немає масивів або вкладених структур).
2. Всі таблиці мають прості первинні ключі. Оскільки складених первинних ключів немає, часткові залежності неможливі, отже вимоги 2NF виконуються автоматично.

Однак схема не досягає 3NF через наявність транзитивних залежностей у таблиці `SONG`.

---

## Функціональні залежності (для початкової схеми)
в
-   **CHURCH**
    -   `id` -> (`name`, `location`)
    -   (`name`, `location`) -> `id`
    - потенційний ключ (`name`, `location`)
-   **SONG_LANGUAGE**
    -   `id` -> `language`
    -   `language` -> `id`
    - потенційний ключ `language`
-   **SONG**
    -   `id` -> (`name`, `author`, `has_author`, `translator`, `is_translated`, `lyrics`, `is_ai`, `language_id`)
    -   `author` -> `has_author` (Транзитивна залежність)
    -   `translator` -> `is_translated` (Транзитивна залежність)
-   **NOTE**
    -   `id` -> (`song_id`, `note`)
-   **WORSHIP_TYPES**
    -   `id` -> `type`
    -   `type` -> `id`
    - потенційний ключ `type`
-   **WORSHIP**
    -   `id` -> (`church_id`, `date`, `type_id`, `views`, `subscribers`, `link`)
-   **SINGING**
    -   `id` -> (`worship_id`, `song_id`, `performer`, `note`)

---

## Покрокова нормалізація таблиці SONG

### Крок 1: Перевірка 1NF
Таблиця `SONG` вже знаходиться у 1NF. Жодне поле не містить списків або множинних значень.

### Крок 2: Перевірка 2NF
Таблиця `SONG` знаходиться у 2NF. Первинний ключ `id` складається лише з одного атрибута. Оскільки ключ не є складеним, жоден неключовий атрибут не може залежати від частини ключа. Часткових залежностей немає.

### Крок 3: Перехід до 3NF

**Проблема:** Таблиця порушує 3NF через наявність полів `has_author` та `is_translated`. 
У поточній структурі існує транзитивна залежність: наявність імені в полі `author` жорстко визначає значення `has_author = true`. 

**Вирішення:** Для усунення транзитивної залежності ми видаляємо булеві поля `has_author` та `is_translated`. Замість них ми вводимо  `ENUM`, які не залежать безпосередньо від тексту в полі `author` чи `translator`:
-   `author_type` ('KNOWN', 'UNKNOWN', 'FOLK')
-   `translation_type` ('ORIGINAL', 'KNOWN_TRANSLATOR', 'UNKNOWN_TRANSLATOR')

Для підтримки цілісності даних ми додаємо обмеження `CHECK`, які гарантують, що текстове поле заповнюється лише тоді, коли тип вказує на відому особу.

### Команди для зміни існуючої таблиці:

```sql
CREATE TYPE author_type AS ENUM ('KNOWN', 'UNKNOWN', 'FOLK');
CREATE TYPE translation_type AS ENUM ('ORIGINAL', 'KNOWN_TRANSLATOR', 'UNKNOWN_TRANSLATOR');

ALTER TABLE SONG 
    DROP COLUMN has_author,
    DROP COLUMN is_translated,
    ADD COLUMN author_type author_type NOT NULL DEFAULT 'KNOWN',
    ADD COLUMN translation_type translation_type NOT NULL DEFAULT 'ORIGINAL',
    ADD CONSTRAINT ck_song_author_type CHECK (
        (author_type = 'KNOWN' AND author IS NOT NULL) OR 
        (author_type != 'KNOWN' AND author IS NULL)
    ),
    ADD CONSTRAINT ck_song_translation_type CHECK (
        (translation_type = 'KNOWN_TRANSLATOR' AND translator IS NOT NULL) OR 
        (translation_type != 'KNOWN_TRANSLATOR' AND translator IS NULL)
    );
```

### Оригінальний дизайн таблиці:

```sql
CREATE TABLE SONG (
    id uuid default gen_random_uuid() primary key,
    name varchar(128) not null,
    author varchar(256),
    has_author bool not null,
    translator varchar(256),
    is_translated bool not null,
    lyrics varchar(1024) not null,
    is_ai bool not null,
    language_id uuid not null references SONG_LANGUAGE(id),
    check ((has_author = true and author is not null) or (has_author = false and author is null)),
    check ((is_translated = true and translator is not null) or (is_translated = false and translator is null))
);
```

### Оновлений дизайн таблиці:
```sql
CREATE TABLE SONG (
    id uuid default gen_random_uuid() primary key,
    name varchar(128) not null,
    author varchar(256),
    author_type author_type not null default 'KNOWN',
    translator varchar(256),
    translation_type translation_type not null default 'ORIGINAL',
    lyrics varchar(1024) not null,
    is_ai bool not null,
    language_id uuid not null references SONG_LANGUAGE(id),
    CONSTRAINT ck_song_author_type CHECK (
        (author_type = 'KNOWN' AND author IS NOT NULL) OR 
        (author_type != 'KNOWN' AND author IS NULL)
    ),
    CONSTRAINT ck_song_translation_type CHECK (
        (translation_type = 'KNOWN_TRANSLATOR' AND translator IS NOT NULL) OR 
        (translation_type != 'KNOWN_TRANSLATOR' AND translator IS NULL)
    )
);
```
