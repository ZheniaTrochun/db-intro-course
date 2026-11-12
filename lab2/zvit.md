# Звіт: Реляційна схема бази даних для системи управління студентами та гуртожитками

## 1. users
Зберігає облікові дані користувачів системи (базова таблиця для ролей STUDENT та DORM_ADMIN).
- `user_id` (PK, SERIAL) - унікальний ідентифікатор
- `first_name`, `last_name` - ім'я та прізвище
- `email` (UNIQUE, NOT NULL) - унікальна електронна пошта; `CHECK` з регулярним виразом перевіряє формат `local@domain.tld` (без пробілів, з доменом і TLD від 2 літер)
- `date_of_birth` - дата народження
- `registration_date` - дата реєстрації (за замовчуванням поточна дата)
- `status` (`user_status` ENUM: active / blocked, за замовчуванням `active`) - статус користувача
- `dorm_id` (FK - dorms.dorm_id, `ON DELETE RESTRICT`, `NULL` дозволено) - гуртожиток людини (студента чи адміністратора); `NULL`, доки не прив'язаний
- `UNIQUE (user_id, dorm_id)` - на цю пару посилаються складені ключі в `students`, `dorm_admins` і `parking_slots`

Таблиця `dorms` створюється перед `users`, бо `users.dorm_id` посилається на неї.

## 2. departments
Довідник факультетів/кафедр.
- `department_id` (PK, SERIAL)
- `department_name` (NOT NULL) - назва кафедри

## 3. dorms
Довідник гуртожитків.
- `dorm_id` (PK, SERIAL)
- `dorm_number` (INTEGER, UNIQUE, NOT NULL, `CHECK (dorm_number > 0)`) - номер гуртожитку
- `address` (UNIQUE, NOT NULL) - адреса гуртожитку

## 4. rooms
Кімнати в гуртожитках.
- `room_id` (PK, SERIAL)
- `dorm_id` (FK - dorms.dorm_id, NOT NULL, `ON DELETE RESTRICT`) - гуртожиток, до якого належить кімната
- `room_number` (NOT NULL) - номер кімнати; `UNIQUE (dorm_id, room_number)` - номер унікальний у межах одного гуртожитку (кімната «101» може бути в кожному гуртожитку, але лише одна)
- `floor` - поверх
- `UNIQUE (room_id, dorm_id)` - потрібне для складеного ключа в `students` (кімната студента має належати його гуртожитку)

Таблиця не містить посилання на студента: в одній кімнаті можуть мешкати кілька студентів, тому зв'язок реалізований у зворотний бік - через `students.room_id`. За прийнятим у роботі припущенням, місткість кімнати не перевищує 4 студентів; це правило описане як бізнес-обмеження, але поточний SQL-скрипт його автоматично не перевіряє.

## 5. students
Основна таблиця студентів.
- `student_id` (PK, SERIAL)
- `enrollment_year` - рік вступу
- `dorm_id` (`NULL` дозволено) - гуртожиток студента; `NULL`, доки не призначено. Складений FK `fk_students_user_dorm` `(user_id, dorm_id)` - users.`(user_id, dorm_id)` (`ON DELETE RESTRICT`) гарантує, що він збігається з `users.dorm_id`
- `room_id` (`NULL` дозволено) - кімната, у якій мешкає студент; `NULL`, доки не призначено. Складений FK `fk_students_room_same_dorm` `(room_id, dorm_id)` - rooms.`(room_id, dorm_id)` (`ON DELETE RESTRICT`) гарантує, що кімната належить тому ж гуртожитку, що й студент; `CHECK (room_id IS NULL OR dorm_id IS NOT NULL)` забороняє кімнату без гуртожитку
- `status` (`student_status` ENUM: enrolled / on_leave / graduated / expelled, NOT NULL, за замовчуванням `enrolled`)
- `user_id` (FK - users.user_id, NOT NULL, `UNIQUE`, `ON DELETE RESTRICT`) - пов'язаний обліковий запис; `UNIQUE` означає, що один акаунт може мати не більше одного студента

Кімнату, у якій є студенти, видалити не можна (`ON DELETE RESTRICT`): спершу треба переселити студентів. Припущення предметної області: в одній кімнаті може проживати не більше 4 студентів. У поточному скрипті це обмеження не реалізоване на рівні бази даних.

## 6. dorm_admins
Адміністратори гуртожитків. Особисті дані - лише через `users`, без дублювання.
- `admin_id` (PK, SERIAL)
- `user_id` (NOT NULL, `UNIQUE`) - обліковий запис адміністратора; `UNIQUE` - людина може бути адміністратором лише одного гуртожитку
- `dorm_id` (NOT NULL) - гуртожиток, яким керує адміністратор
- `fk_dorm_admins_user_dorm` - складений FK `(user_id, dorm_id)` - users.`(user_id, dorm_id)` (`ON DELETE RESTRICT`): акаунт існує, а гуртожиток адміністратора збігається з `users.dorm_id`

В одному гуртожитку може бути кілька адміністраторів (`dorm_id` не `UNIQUE`), але кожен адміністратор працює лише в одному гуртожитку.

## 7. parking_slots
Паркувальні місця.
- `parking_slot_id` (PK, SERIAL)
- `dorm_id` (FK - dorms.dorm_id, NOT NULL, `ON DELETE RESTRICT`) - гуртожиток, до якого належить місце
- `user_id` (`UNIQUE`, `NULL` дозволено) - людина (студент чи адміністратор), яка займає місце; `UNIQUE` - одна людина має не більше одного місця; `NULL` - місце вільне
- `slot_number` (NOT NULL) - номер паркомісця; `UNIQUE (dorm_id, slot_number)` - номер унікальний у межах одного гуртожитку
- `fk_parking_user_same_dorm` - складений FK `(user_id, dorm_id)` - users.`(user_id, dorm_id)`: гуртожиток місця збігається з гуртожитком людини

При видаленні користувача поле `user_id` скидається в `NULL` (`ON DELETE SET NULL (user_id)`; список колонок потрібен, щоб не обнулити обов'язковий `dorm_id`) - місце звільняється, а не видаляється.

## 8. courses
Каталог курсів, що читаються на кафедрах.
- `course_id` (PK, SERIAL)
- `department_id` (FK - departments.department_id, NOT NULL, `ON DELETE RESTRICT`) - кафедра, яка веде курс
- `course_title` (NOT NULL) - назва курсу

## 9. enrollments
Асоціативна таблиця "багато-до-багатьох" між `students` і `courses`: один студент може бути записаний на кілька курсів, один курс може мати кількох студентів.
- `enrollment_id` (PK, SERIAL)
- `student_id` (FK - students.student_id, NOT NULL, `ON DELETE CASCADE`)
- `course_id` (FK - courses.course_id, NOT NULL, `ON DELETE CASCADE`)
- `enrollment_date` - дата зарахування (за замовчуванням поточна дата)
- `grade` - оцінка/результат (`NULL`, доки курс не завершено)
- `UNIQUE (student_id, course_id)` - студент не може бути записаний на той самий курс двічі

## 10. vacancies
Каталог вакансій компаній-партнерів університету, доступний багатьом студентам одночасно.
- `vacancy_id` (PK, SERIAL)
- `company_name` (NOT NULL) - назва компанії
- `job_name` (NOT NULL) - назва посади

## 11. applications
Асоціативна таблиця "багато-до-багатьох" між `students` і `vacancies`: студент може подати заявки на кілька вакансій, вакансія може отримати заявки від кількох студентів.
- `application_id` (PK, SERIAL)
- `student_id` (FK - students.student_id, NOT NULL, `ON DELETE CASCADE`)
- `vacancy_id` (FK - vacancies.vacancy_id, NOT NULL, `ON DELETE CASCADE`)
- `application_date` - дата подачі заявки (за замовчуванням поточна дата)
- `status` (`application_status` ENUM: submitted / accepted / rejected, за замовчуванням `submitted`) - стан заявки
- `UNIQUE (student_id, vacancy_id)` - не допускаються дублікати заявок на ту саму вакансію

## Важливі припущення та обмеження

- Таблиця `users` є базовою для `students` та `dorm_admins` - обидві сутності пов'язані з обліковим записом через `user_id`, і жодна з них не дублює особисті дані (ім'я, прізвище, email).
- `courses` і `vacancies` - каталоги (довідники), а не особисті записи студента: зв'язок зі студентами реалізовано через асоціативні таблиці `enrollments` та `applications` відповідно, що коректно реалізує зв'язки "багато-до-багатьох".
- FK на кімнату зберігається в `students.room_id`, а не в `rooms`, оскільки одна кімната може бути пов'язана з кількома студентами. Прийняте припущення: місткість однієї кімнати - не більше 4 студентів. У цьому скрипті обмеження місткості не контролюється; для автоматичної перевірки знадобився б тригер або інший механізм контролю кількості рядків у `students`.
- Поле `email` у `users` має обмеження `UNIQUE NOT NULL` для запобігання дублюванню користувачів.
- Кожна таблиця заповнена тестовими рядками, включно з прикладами необов'язкових зв'язків: студент без кімнати (п'ятий студент, `user_id` = Дмитро Шевченко) та вільне паркомісце без студента й адміністратора.
- Усі первинні ключі мають тип `SERIAL` (автоінкремент). У тестових даних ідентифікатори не вказуються: вони нумеруються з 1 у порядку вставки, тому зв'язані таблиці посилаються на них числами.
- Для текстових полів, обов'язкових для заповнення, задано `CHECK (col = trim(col) AND col <> '')`: значення не можуть містити пробіли на початку/в кінці та бути порожніми. Це стосується `first_name`, `last_name`, `department_name`, `address`, `room_number`, `slot_number`, `course_title`, `company_name` та `job_name`. Для `email` окремо перевіряється формат регулярним виразом; оцінка `enrollments.grade` числова і такого `CHECK` у скрипті не має.
- На початку скрипта одним запитом видаляються всі таблиці (`DROP TABLE IF EXISTS applications, vacancies, ..., users`) та типи `ENUM` (`DROP TYPE IF EXISTS ...`), тому скрипт можна безпечно запускати повторно. `CASCADE` не потрібен: усі залежні таблиці видаляються в тому ж запиті.
- Гуртожиток людини зберігається в `users.dorm_id`, а `students.dorm_id` і `dorm_admins.dorm_id` складеними ключами прив'язані до нього. Тому паркомісце посилається лише на `user_id` і однаково перевіряє гуртожиток і для студента, і для адміністратора. Обмеження: якщо `students.dorm_id` дорівнює `NULL`, складений ключ не перевіряється, тож студент без гуртожитку в `students` може мати `users.dorm_id`.
- Один акаунт може мати не більше одного студентського профілю (`UNIQUE (user_id)` у `students`) і бути адміністратором лише одного гуртожитку (`UNIQUE (user_id)` у `dorm_admins`). Правило «акаунт не може бути одночасно студентом і адміністратором» у скрипті не перевіряється: `students.user_id` і `dorm_admins.user_id` незалежно посилаються на `users`. Таке обмеження потребувало б тригера або колонки ролі в `users`.
- Поведінка при видаленні (`ON DELETE`):
  - `RESTRICT` - `users.dorm_id`, `rooms.dorm_id`, `parking_slots.dorm_id`, `courses.department_id`, `students.user_id`, складені FK `students(user_id, dorm_id)`, `students(room_id, dorm_id)`, `dorm_admins(user_id, dorm_id)`: батьківський рядок (гуртожиток, кафедру, кімнату, користувача) видалити не можна, поки на нього є посилання;
  - `SET NULL` - складений FK `parking_slots(user_id, dorm_id)` (лише `user_id`, `dorm_id` лишається): паркомісце лишається, просто стає вільним;
  - `CASCADE` - `enrollments` і `applications`: запис про зарахування чи заявку не має сенсу без студента, курсу чи вакансії, тому вони видаляються разом із ними.
