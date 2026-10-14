# Звіт: Реляційна схема бази даних для системи управління студентами та гуртожитками

## 1. users
Зберігає облікові дані користувачів системи (базова таблиця для ролей STUDENT та DORM_ADMIN).
- `user_id` (PK, SERIAL) - унікальний ідентифікатор
- `first_name`, `last_name` - ім'я та прізвище
- `email` (UNIQUE, NOT NULL) - унікальна електронна пошта; `CHECK` з регулярним виразом перевіряє формат `local@domain.tld` (без пробілів, з доменом і TLD від 2 літер)
- `date_of_birth` - дата народження
- `registration_date` - дата реєстрації (за замовчуванням поточна дата)
- `status` (`user_status` ENUM: active / blocked, за замовчуванням `active`) - статус користувача

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

Таблиця не містить посилання на студента: одна кімната може мешкати кількох студентів, тому зв'язок реалізований у зворотний бік - через `students.room_id`.

## 5. students
Основна таблиця студентів.
- `student_id` (PK, SERIAL)
- `enrollment_year` - рік вступу
- `room_id` (FK - rooms.room_id, `ON DELETE RESTRICT`, `NULL` дозволено) - кімната, у якій мешкає студент; `NULL`, доки не призначено. Гуртожиток студента окремо не зберігається - визначається через `rooms.dorm_id`, що усуває можливу розбіжність між гуртожитком студента та гуртожитком його кімнати
- `status` (`student_status` ENUM: enrolled / on_leave / graduated / expelled, NOT NULL, за замовчуванням `enrolled`)
- `user_id` (FK - users.user_id, NOT NULL, `ON DELETE RESTRICT`) - пов'язаний обліковий запис

Кімнату, у якій є студенти, видалити не можна (`ON DELETE RESTRICT`): спершу треба переселити студентів. Обмеження на кількість студентів в одній кімнаті в базі поки не реалізоване.

## 6. dorm_admins
Адміністратори гуртожитків. Особисті дані - лише через `users`, без дублювання.
- `admin_id` (PK, SERIAL)
- `user_id` (FK - users.user_id, NOT NULL, `ON DELETE RESTRICT`) - пов'язаний обліковий запис
- `dorm_id` (FK - dorms.dorm_id, NOT NULL, `ON DELETE RESTRICT`) - гуртожиток, яким керує адміністратор
- `UNIQUE (admin_id, dorm_id)` - потрібне, щоб на пару `(admin_id, dorm_id)` міг посилатися складений ключ у `parking_slots`

## 7. parking_slots
Паркувальні місця.
- `parking_slot_id` (PK, SERIAL)
- `student_id` (FK - students.student_id, `UNIQUE`, `NULL` дозволено) - студент, який використовує місце (один студент - не більше одного місця); `NULL` - місце вільне
- `dorm_id` (FK - dorms.dorm_id, NOT NULL, `ON DELETE RESTRICT`) - гуртожиток, до якого належить місце
- `admin_id` (складений FK `fk_parking_admin_same_dorm` `(admin_id, dorm_id)` - dorm_admins.`(admin_id, dorm_id)`, `NULL` дозволено) - адміністратор, що опрацював місце; `NULL`, якщо ще не призначено. Складений ключ гарантує, що адміністратор відповідає за той самий гуртожиток, до якого належить місце
- `slot_number` (NOT NULL) - номер паркомісця

При видаленні студента чи адміністратора відповідні поля скидаються в `NULL` (`ON DELETE SET NULL`; для складеного ключа - `SET NULL (admin_id)`, щоб не обнулити обов'язковий `dorm_id`) - місце звільняється, а не видаляється.

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
- FK на кімнату зберігається в `students.room_id`, а не в `rooms`, оскільки одна кімната може мешкати кількох студентів (обмеження на максимальну кількість, наприклад 4, нотацією ER/SQL-схемою напряму не виражається і в поточному скрипті не реалізоване).
- Поле `email` у `users` має обмеження `UNIQUE NOT NULL` для запобігання дублюванню користувачів.
- Кожна таблиця заповнена тестовими рядками, включно з прикладами необов'язкових зв'язків: студент без кімнати (п'ятий студент, `user_id` = Дмитро Шевченко) та вільне паркомісце без студента й адміністратора.
- Усі первинні ключі мають тип `SERIAL` (автоінкремент). У тестових даних ідентифікатори не вказуються: вони нумеруються з 1 у порядку вставки, тому зв'язані таблиці посилаються на них числами.
- Для всіх вільних текстових полів додано `CHECK (col = btrim(col) AND col <> '')`: значення не можуть містити пробіли на початку/в кінці та бути порожніми. Це стосується `first_name`, `last_name`, `department_name`, `address`, `room_number`, `slot_number`, `course_title`, `company_name`, `job_name` та `enrollments.grade` (необов'язкове поле - `NULL` дозволено).
- На початку скрипта виконується `DROP TABLE IF EXISTS ... CASCADE` та `DROP TYPE IF EXISTS`, тому скрипт можна безпечно запускати повторно.
- Правило «один обліковий запис не може бути одночасно студентом і адміністратором» у скрипті не перевіряється: `students.user_id` і `dorm_admins.user_id` незалежно посилаються на `users`. Таке обмеження потребувало б тригера або додаткової колонки ролі в `users`.
- Поведінка при видаленні (`ON DELETE`):
  - `RESTRICT` - `rooms.dorm_id`, `dorm_admins.dorm_id`, `parking_slots.dorm_id`, `courses.department_id`, `students.room_id`, `students.user_id`, `dorm_admins.user_id`: батьківський рядок (гуртожиток, кафедру, кімнату, користувача) видалити не можна, поки на нього є посилання;
  - `SET NULL` - `parking_slots.student_id` та `parking_slots.admin_id`: паркомісце лишається, просто стає вільним / без адміністратора;
  - `CASCADE` - `enrollments` і `applications`: запис про зарахування чи заявку не має сенсу без студента, курсу чи вакансії, тому вони видаляються разом із ними.
