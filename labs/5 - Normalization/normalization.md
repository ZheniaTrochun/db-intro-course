# Лабораторна робота 5: Нормалізація бази даних

## 1. Аналіз вихідної схеми

Схема з лабораторної 2 складається з таблиць `student`, `security_employee`, `incident_type`, `incident_status`, `participant_role`, `visit`, `incident`, `incident_participant`. Проблемною є лише таблиця `student`, яка зберігала і групу, і факультет студента.

### Вихідна таблиця student

```sql
CREATE TABLE student (
    student_id  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id    INTEGER      NOT NULL,
    faculty_id  INTEGER      NOT NULL,
    full_name   VARCHAR(150) NOT NULL
);
```

Зовнішніх ключів на `group_id` і `faculty_id` немає, окремих таблиць груп і факультетів у вихідній схемі не було.

Приклад даних:

| student_id | group_id | faculty_id | full_name |
|-----------|----------|-----------|-----------|
| 1 | 10 | 1 | Іваненко І. |
| 2 | 10 | 1 | Петренко П. |
| 3 | 10 | 1 | Сидоренко С. |
| 4 | 20 | 2 | Коваль К. |

Пара `(group_id=10, faculty_id=1)` повторюється в кожному рядку студента цієї групи.

### Виявлені аномалії

- **Аномалія оновлення:** якщо група 10 переходить на інший факультет, треба змінити `faculty_id` в усіх рядках її студентів. Пропуск одного рядка дає суперечливі дані.
- **Аномалія вставки:** не можна додати нову групу з факультетом, поки в ній немає жодного студента.
- **Аномалія видалення:** при видаленні останнього студента групи втрачається інформація, до якого факультету належала група.

## 2. Функціональні залежності вихідної схеми

| Таблиця | Ключ | Функціональні залежності |
|---------|------|--------------------------|
| **student** | student_id | `student_id → full_name, group_id`; **`group_id → faculty_id`** (залежність `student_id → faculty_id` випливає з них транзитивно, тому в мінімальний набір не входить) |
| security_employee | employee_id | `employee_id → full_name, position, phone`; `phone → employee_id` (UNIQUE) |
| incident_type | type_id | `type_id → name`; `name → type_id` |
| incident_status | status_id | `status_id → name`; `name → status_id` |
| participant_role | role_id | `role_id → name`; `name → role_id` |
| visit | visit_id | `visit_id → student_id, category, started_at, ended_at` |
| incident | incident_id | `incident_id → visit_id, type_id, employee_id, status_id, description, occurred_at, severity` |
| incident_participant | (incident_id, visit_id) | `(incident_id, visit_id) → role_id` |

Решта таблиць у вихідній схемі такі ж, як у фінальній (змінюється лише `student`).

## 3. Нормальна форма вихідної схеми

**Найвища нормальна форма вихідної схеми: 2НФ.**

- **1НФ виконується:** усі атрибути атомарні, повторюваних груп немає.
- **2НФ виконується:** первинний ключ `student_id` простий (не складений), тому часткових залежностей бути не може.
- **3НФ порушена в `student`:** є транзитивна залежність `student_id → group_id → faculty_id`. Неключовий атрибут `faculty_id` залежить від іншого неключового атрибута `group_id`.

Решта таблиць у 3НФ: у кожній неключові атрибути залежать лише від ключа, залежностей між неключовими атрибутами немає. Атрибути `visit.category`, `incident.severity`, `security_employee.position` не визначають один одного і інших атрибутів. `incident_participant` має складений ключ, але єдиний неключовий атрибут `role_id` залежить від ключа повністю.

## 4. Покроковий процес нормалізації

### Крок 1: перехід до 1НФ

Таблиця `student` вже в 1НФ, змін не потрібно.

```
student(student_id PK, group_id, faculty_id, full_name)
```

### Крок 2: перехід до 2НФ

Ключ простий, часткових залежностей немає, таблиця вже в 2НФ. Змін не потрібно.

```
student(student_id PK, group_id, faculty_id, full_name)
```

### Крок 3: перехід до 3НФ

Транзитивну залежність `group_id → faculty_id` виносимо в окрему таблицю. Створюємо `student_group` (група і її факультет) та `faculty` (довідник факультетів), з `student` видаляємо `faculty_id`.

```
faculty(faculty_id PK, name UNIQUE)
student_group(group_id PK, faculty_id FK → faculty, name UNIQUE)
student(student_id PK, group_id FK → student_group, full_name)
```

Перевірка залежностей після декомпозиції:

- `student`: `student_id → group_id, full_name`
- `student_group`: `group_id → faculty_id, name`
- `faculty`: `faculty_id → name`

Усі неключові атрибути залежать лише від ключа, тож таблиці в 3НФ.

**Чому це усуває аномалії:**

- **Оновлення:** факультет групи зберігається в одному рядку `student_group`, змінюється одним `UPDATE`.
- **Вставка:** групу можна створити без студентів.
- **Видалення:** видалення студентів не зачіпає зв'язок «група → факультет».

## 5. Оригінальний та перероблений дизайн (ALTER TABLE)

Змінена лише таблиця `student`:

```sql
-- було: student(student_id, group_id, faculty_id, full_name)

ALTER TABLE student
    ADD CONSTRAINT fk_student_group
    FOREIGN KEY (group_id) REFERENCES student_group (group_id);

ALTER TABLE student DROP COLUMN faculty_id;

-- стало: student(student_id, group_id FK, full_name)
```

Нові таблиці `faculty` і `student_group` створюються `CREATE TABLE` (див. `5-001-migration-3nf.sql`).

**Міграція даних без видалення таблиць:** `5-001-migration-3nf.sql` створює нові таблиці, переносить з `student` унікальні пари `(group_id, faculty_id)` зі збереженням наявних id (`OVERRIDING SYSTEM VALUE`), вирівнює лічильники identity, додає зовнішній ключ і лише після перевірки збігу даних видаляє `student.faculty_id`. Назв факультетів і груп у вихідних даних не було, тому факультету 1 присвоєно назву «ФІОТ» (усі студенти з нього), а назви груп створено як заглушки (`Група N`).

## 6. Фінальна схема в 3НФ

Повні `CREATE TABLE` для всіх таблиць: `5-002-final-schema-3nf.sql`. Діаграма: `er-diagram-3nf.mmd` (експортована в `er-diagram-3nf.png`/`.pdf`).

```
faculty(faculty_id PK, name UK)
student_group(group_id PK, faculty_id FK, name UK)
student(student_id PK, group_id FK, full_name)
security_employee(employee_id PK, full_name, position, phone UK)
incident_type(type_id PK, name UK)
incident_status(status_id PK, name UK)
participant_role(role_id PK, name UK)
visit(visit_id PK, student_id FK, category, started_at, ended_at)
incident(incident_id PK, visit_id FK, type_id FK, employee_id FK, status_id FK, description, occurred_at, severity)
incident_participant(incident_id PK/FK, visit_id PK/FK, role_id FK)
```

## 7. Перевірка

Після міграції запит повертає стільки ж рядків, скільки було студентів, а зовнішні ключі не дозволяють вставити студента з неіснуючою групою:

```sql
SELECT s.student_id, s.full_name, g.name AS grp, f.name AS faculty
FROM student s
JOIN student_group g ON g.group_id = s.group_id
JOIN faculty f ON f.faculty_id = g.faculty_id;
```