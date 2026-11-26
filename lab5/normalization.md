# Лабораторна робота №5. Нормалізація бази даних
## Початкова схема й функціональні залежності

У таблиці нижче наведено всі кандидатні ключі та мінімальне покриття нетривіальних функціональних залежностей. Атрибути праворуч від стрілки згруповано для читабельності: кожен із них задає окрему залежність. Первинний ключ наведено першим. Позначення `A ↔ B` скорочує дві залежності.

| Таблиця | Кандидатні ключі | Мінімальне покриття | Найвища форма за наведеними ФЗ |
| --- | --- | --- | --- |
| `dorms` | `dorm_id`, `dorm_number`, `address` | `dorm_number → dorm_id → address → dorm_number` | НФБК |
| `users` | `user_id`, `email` | `user_id ↔ email`, `user_id → first_name, last_name, date_of_birth, registration_date, status, dorm_id` | НФБК |
| `departments` | `department_id` | `department_id → department_name` | НФБК |
| `rooms` | `room_id`, `(dorm_id, room_number)` | `room_id → dorm_id, room_number, floor`, `(dorm_id, room_number) → room_id` | НФБК |
| `students` | `student_id`, `user_id` | `student_id ↔ user_id`, `student_id → enrollment_year, dorm_id, room_id, status`. Для поселених студентів також `room_id → dorm_id`. | 2НФ серед поселених. Без умови `room_id IS NOT NULL` усі наведені безумовні ФЗ мають суперключ зліва. |
| `dorm_admins` | `admin_id`, `user_id` | `admin_id ↔ user_id`, `user_id → dorm_id` | НФБК |
| `parking_slots` | `parking_slot_id`, `(dorm_id, slot_number)` | `parking_slot_id → dorm_id, slot_number, user_id`, `(dorm_id, slot_number) → parking_slot_id`. Серед зайнятих місць `user_id → parking_slot_id`. | НФБК за безумовними ФЗ. У підмножині зайнятих місць `user_id` є ще одним кандидатним ключем. |
| `courses` | `course_id` | `course_id → department_id, course_title` | НФБК |
| `enrollments` | `enrollment_id`, `(student_id, course_id)` | `enrollment_id → student_id, course_id, enrollment_date, grade`, `(student_id, course_id) → enrollment_id` | НФБК |
| `vacancies` | `vacancy_id` | `vacancy_id → company_name, job_name` | НФБК |
| `applications` | `application_id`, `(student_id, vacancy_id)` | `application_id → student_id, vacancy_id, application_date, status`, `(student_id, vacancy_id) → application_id` | НФБК |

Для підмножини поселених студентів у мінімальному покритті `student_id → dorm_id` замінюється на `room_id → dorm_id`. Для зайнятих місць додається `user_id → parking_slot_id`, з якої випливає `user_id → dorm_id`. Пара `(user_id, dorm_id)` у `users` і пара `(room_id, dorm_id)` у `rooms` — суперключі, які в лабораторній №2 додано для складених зовнішніх ключів. У початковому `parking_slots` ціле відношення допускає кілька вільних місць із `user_id IS NULL`.

Рядки лабораторної №2 підтверджують, що студенти 1 і 2 мають однакові `room_id = 1` і `dorm_id = 1`, а той самий гуртожиток записано в `rooms` та `users`. У кімнаті може бути кілька студентів, отже `room_id` не є ключем `students`. Найвища форма даних про поселених студентів — 2НФ, через цю транзитивну залежність повна модель потребує нормалізації. `NULL` для непоселених студентів має окремий зміст. За суто безумовними ФЗ, без аналізу підмножини поселень, і це відношення має тільки детермінанти-суперключі.

## Перехід до 1НФ, 2НФ та 3НФ

### 1НФ

Кожен стовпець початкових 11 таблиць містить одне значення свого домену. Кожен запис на курс і кожна заява займають окремий рядок. Списків і повторюваних груп немає. На цьому етапі атрибути та ключі збігаються з початковим дизайном у таблиці ФЗ.

### 2НФ

Складені кандидатні ключі мають `rooms(dorm_id, room_number)`, `parking_slots(dorm_id, slot_number)`, `enrollments(student_id, course_id)` і `applications(student_id, vacancy_id)`. Номер кімнати й номер місця унікальні в межах гуртожитку. Дата запису й оцінка залежать від пари «студент, курс», дата та статус заяви — від пари «студент, вакансія». Жодна частина цих ключів сама по собі не визначає неключовий атрибут. Решта кандидатних ключів одноатрибутні. Тому на етапі 2НФ склад таблиць і ключів теж збігається з початковим.

### 3НФ

| Початковий дизайн | Перероблений дизайн | Усунена аномалія |
| --- | --- | --- |
| `students(student_id PK, enrollment_year, dorm_id, room_id, status, user_id UQ)` | `students(student_id PK, enrollment_year, room_id FK → rooms, status, user_id UQ FK → users)` | `room_id → dorm_id` для поселення забезпечує `rooms`. Гуртожиток користувача зберігається в `users`, тому при поселенні або переведенні не треба копіювати його в `students`. |
| `dorm_admins(admin_id PK, user_id UQ, dorm_id)` | `dorm_admins(admin_id PK, user_id UQ FK → users)` | Гуртожиток адміністратора визначається через `users.dorm_id`. Якщо адміністратор не має інших несумісних призначень, його можна перевести зміною одного поля в `users`. |
| `vacancies(vacancy_id PK, company_name, job_name)` | `vacancies(vacancy_id PK, company_id FK → companies, job_name)` і `companies(company_id PK, company_name UQ)` | Компанія може існувати без вакансій. Її назву можна змінити один раз для всіх вакансій, а видалення останньої вакансії зберігає запис компанії. Назву вважаємо унікальною в межах цього навчального каталогу. |
| `rooms(…, UQ(room_id, dorm_id))` | Ті самі стовпці та кандидатні ключі. Складене обмеження вилучено. | `students.room_id` посилається на первинний ключ `rooms.room_id`. |

У `dorm_admins` і `vacancies` початкові безумовні ФЗ вже задовольняли 3НФ. Зміни усувають повторне зберігання факту про гуртожиток адміністратора та виділяють компанію як самостійну сутність.

`parking_slots` уже задовольняє 3НФ. Користувач і паркомісце мають зв’язок 0..1 ↔ 0..1 через `parking_slots.user_id`. Значення `NULL` позначає вільне місце, а `UNIQUE (user_id)` дозволяє кожному користувачу зайняти щонайбільше одне місце. Складений зовнішній ключ `(user_id, dorm_id)` посилається на `users(user_id, dorm_id)` і гарантує збіг гуртожитків. Дія `ON DELETE SET NULL (user_id)` звільняє місце після видалення користувача.

У фінальній схемі мінімальні ФЗ для змінених і нових відношень мають такий вигляд:

| Таблиця | Функціональні залежності |
| --- | --- |
| `students` | `student_id ↔ user_id`, `student_id → enrollment_year, room_id, status` |
| `dorm_admins` | `admin_id ↔ user_id` |
| `companies` | `company_id ↔ company_name` |
| `vacancies` | `vacancy_id → company_id, job_name` |

Для решти таблиць ФЗ лишаються такими, як у початковому переліку.

Вакансії з'єднуються з компаніями через `JOIN`, а вільні паркомісця відбираються через `parking_slots.user_id IS NULL`. Для поселеного студента гуртожиток кімнати доступний через `rooms`, а гуртожиток користувача — через `users`. Лабораторна №2 допускала `students.dorm_id IS NULL` без кімнати незалежно від наявності гуртожитку в `users`. У новій схемі відсутність кімнати позначає `students.room_id IS NULL`, а єдиним джерелом гуртожитку користувача є `users.dorm_id`. У початкових зразках видалені значення відновлюються з цих зв'язків.

## ALTER TABLE для переходу з лабораторної №2

Наведені команди показують перехід із перенесенням даних. Для чистого розгортання в порожній навчальній базі достатньо [lab5.sql](lab5.sql), який створює всі таблиці та завантажує зразки.

```sql
CREATE TABLE companies (
    company_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL UNIQUE
        CHECK (company_name = trim(company_name) AND company_name <> '')
);

INSERT INTO companies (company_name)
SELECT DISTINCT company_name FROM vacancies;

ALTER TABLE vacancies ADD COLUMN company_id INTEGER;
UPDATE vacancies v
SET company_id = c.company_id
FROM companies c
WHERE c.company_name = v.company_name;
ALTER TABLE vacancies
    ALTER COLUMN company_id SET NOT NULL,
    ADD FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE RESTRICT,
    DROP COLUMN company_name;

ALTER TABLE dorm_admins
    DROP CONSTRAINT fk_dorm_admins_user_dorm,
    DROP COLUMN dorm_id,
    ADD FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT;

ALTER TABLE students
    DROP CONSTRAINT fk_students_user_dorm,
    DROP CONSTRAINT fk_students_room_same_dorm,
    DROP COLUMN dorm_id,
    ADD FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE RESTRICT;

ALTER TABLE rooms DROP CONSTRAINT rooms_room_id_dorm_id_key;
```

Зовнішній ключ `students.room_id` перевіряє, що призначена кімната існує. Її гуртожиток може відрізнятися від гуртожитку в профілі користувача. Профіль адміністратора може мати `users.dorm_id = NULL`. Для паркомісць збіг гуртожитків користувача й місця забезпечує складений зовнішній ключ.