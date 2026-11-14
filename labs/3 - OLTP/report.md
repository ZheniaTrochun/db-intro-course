Усі операції `SELECT`, `INSERT`, `UPDATE`, `DELETE` виконано на схемі з лаб. 2.

## SELECT
Запити вибирають окремі стовпці (без `SELECT *`), фільтрують через `WHERE` (`is_translated`, `name`, `is null`) і з'єднують таблиці по ланцюжку джоінами. Є `GROUP BY`/`HAVING` для підрахунків.
## INSERT
Заповнено всі 7 таблиць, по 5 рядків кожна
## UPDATE
5 запитів з `SET` і `WHERE`. Рядок вибирається за `link` або `name`, FK - підзапитами. Для `Song2` `translator` і `is_translated` змінюються разом.
## DELETE
4 запити з `WHERE`
