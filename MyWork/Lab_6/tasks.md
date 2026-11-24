# Lab 6 — Prisma ORM (міграції схеми)

## Завдання

Використати **Prisma ORM** для роботи з БД VideoHub. Описати схему в `schema.prisma`, створити міграції, перевірити через Prisma Studio.

### Кроки

1. **Ініціалізувати Prisma** у Node.js-проєкті
2. **Створити `schema.prisma`** — описати всі моделі VideoHub (User, Video, Comment, Like, Subscription)
3. **Міграція 1: init** — початкова схема з усіма таблицями
4. **Міграція 2: add-video-duration** — додати поле `duration` до Video
5. **Міграція 3: add-video-category** — додати таблицю Category + зв'язок Video→Category
6. **Перевірка** — Prisma Studio, дані в таблицях
