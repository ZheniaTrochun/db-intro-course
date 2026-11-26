Перша міграція: `add_achievement`

Додано таблицю `achievement` для зберігання досягнень із полями `id`, `name`, `description` та `points`. Поле `id` є первинним ключем і заповнюється автоматично, назва досягнення є унікальною, а кількість балів за замовчуванням дорівнює 0.

Друга міграція: `add_character_achievement`

Додано таблицю `character_achievement` для зберігання отриманих персонажами досягнень. Вона містить поля `character_id`, `achievement_id` та `unlocked_at` і реалізує зв’язок багато до багатьох між `character` та `achievement`. Складений первинний ключ із `character_id` та `achievement_id` забороняє повторне отримання одного досягнення тим самим персонажем. Додано два зовнішні ключі з каскадним видаленням та індекс на `achievement_id`. Час отримання заповнюється автоматично.

Третя міграція: `rename_item_template_id`

Змінено назву поля `item_tmpl_id` на `item_template_id` у таблиці `item`, щоб зробити її зрозумілішою. Також перейменовано зовнішній ключ `item_item_tmpl_id_fkey` на `item_item_template_id_fkey`. Використано `RENAME COLUMN` та `RENAME CONSTRAINT`, що зберігають наявні дані та зв’язок із таблицею `item_template`.

![Результат роботи у Prisma Studio](<imgs/Screenshot 2026-11-26 115111.png>)
