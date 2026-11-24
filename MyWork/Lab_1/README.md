# Lab 1 — Концептуальна модель БД (ER-діаграма)

## 🇺🇦 Українською

Проєктування концептуальної моделі бази даних **VideoHub** — відеохостинг-платформи (аналог YouTube). Побудовано ER-діаграму з **5 сутностей** (`User`, `Video`, `Comment`, `Like`, `Subscription`) та **7 зв'язків**, включно із самореференсним зв'язком «підписка» (User ↔ User).

### Сутності та зв'язки

- **User** — користувач платформи: id (UUID), email/username (природні кандидатні ключі), password або google_id (два способи входу), профіль каналу.
- **Video** — відео з лічильником переглядів; належить автору (`author_id`).
- **Comment** — коментар: прив'язаний і до автора, і до відео.
- **Like** — лайк = пара (юзер, відео); реалізує M:N «лайки» між користувачами і відео.
- **Subscription** — підписка юзера на канал: самореференсний зв'язок User↔User (дві ролі: subscriber і channel).

### Ключові рішення моделі

- Усі зв'язки 1:N; єдиний M:N (підписки) розгорнуто через junction-таблицю Subscription.
- Унікальності бізнес-правил — у моделі як обмеження: один лайк на відео від юзера, підписка не дублюється і не на себе.
- Кожен запис має `created_at`; пароль nullable (OAuth-користувачі).

### Файли

- `er_diagram.mmd` — ER-діаграма у форматі Mermaid
- `er_diagram.puml` — та сама діаграма у форматі PlantUML
- `tasks.md` — завдання лабораторної
- `report_lab1.md` / `report_lab1.pdf` — звіт
- `screenshots/` — скріншоти діаграми

---

## 🇬🇧 English

Conceptual database design for **VideoHub** — a video-hosting platform (YouTube analog). The ER diagram contains **5 entities** (`User`, `Video`, `Comment`, `Like`, `Subscription`) and **7 relationships**, including a self-referencing "subscription" relation (User ↔ User).

### Key model decisions

- All relationships are 1:N; the only M:N (subscriptions) is resolved via the `Subscription` junction table.
- Business rules modelled as uniqueness constraints: one like per user per video, subscriptions can't repeat or self-target.
- Every record carries `created_at`; `password` is nullable for OAuth users.

### Files

- `er_diagram.mmd` — ER diagram in Mermaid format
- `er_diagram.puml` — same diagram in PlantUML format
- `tasks.md` — lab assignment
- `report_lab1.md` / `report_lab1.pdf` — report
- `screenshots/` — diagram screenshots
