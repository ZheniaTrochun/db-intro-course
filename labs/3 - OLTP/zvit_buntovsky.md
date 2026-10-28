# Доказ заповненості таблиць

У [init.sql](../../init-scripts/init.sql) :

```sql
insert into zone (level_requirement, zone_name) values
    (1, 'Firelink Shrine'),
    (5, 'Undead Burg'),
    (10, 'Depths'),
    (20, 'Blighttown'),
    (40, 'Anor Londo'),
    (80, 'The Abyss'),
    (100, 'Kiln of the First Flame');

insert into monster_type (name, description) values
    ('Hollow', 'A shell of one''s former self'),
    ('Skeleton', 'Excels in regeneration'),
    ('Pinwheel', 'Just spam attack'),
    ('Soldier of God, Rick', 'The undefeated champion.');

insert into world_entity (zone_id, position_x, position_y, position_z, max_hp, level) values
    (1, 138.3, 2903.556, 248.4872, 50, 3),  
    (1, 389.4, 18937.7831, 738.3781, 100,5), 
    (2, 310.10, 381.39, 39.531, 200, 8),  
    (3, 3920.42, 492.42, 8942.8924, 500, 20), 
    (3, 39318.42, 32.47, 89.24, 1000, 30),
    (4, 389.8329, 3829.3892, 38.92, 250, 16), 
    (5, 290.42,19.38, 3.392, 1, 1),
    (6, 8941.41, 49.47, 4.4920, 1000, 40),
    (7, 3967.67, 381.8913, 8931.781, 2000, 50);

insert into monster_entity (entity_id,state,stats_id, type_id,target_id) values 
    (4, default, 1, 1, default),
    (6, default, 3, 3, default),
    (9, default, 4, 4, default);

insert into npc (entity_id, name) values
    (1, 'Patches'),
    (2, 'Snuggly'),
    (3, 'Undead Merchant');

insert into monster_drop (monster_id,item_id) values
    (1, 3), (2, 3), (3, 2), (4, 1);
```

# Запит SELECT

## Мета

Отримати з таблиці monster_drop ідентифікатори типів предметів, які може викинути при смерті монстр з ідентифікатором 1

## Очікуваний результат

Згідно з попередньо записаними даними, запит повинен повернути один рядок з числом 3.

## Чи вдався запит

[Так.](screenshots/1.png)

# Запит INSERT

## Мета

Провести процедуру створення нового npc, що включає в себе створення загального world_entity, який містить інформацію про розташування сутності у світі, а тоді створення запису в таблиці npc з відповідним entity_id. Наприкінці використати SELECT, щоб переконатись, що npc з використаним іменем було створено.

## Очікуваний результат

Таблиця з єдиним записом - ідентифікатором world_entity для запису, де ім'я дорівнює тому, що було створено - "Seam". Згідно з даними таблиці - 10.

## Чи вдався запит

[Так.](screenshots/2.png)

# Запит UPDATE

## Мета

Змінити необхідний рівень для доступу до зони "Undead Burg" з 5 до 10. Використати SELECT, щоб переконатись в успіху.

## Очікуваний результат

Новий необхідний рівень для доступу до "Undead Burg" - 10.

## Чи вдався запит

[Так.](screenshots/3.png)

# Запит DELETE

## Мета

Видалити попередньо створеного npc з name = 'Seam' та підчистити його world_entity. перевірити через select

## Очікуваний результат

Пуста відповідь, адже npc було видалено

## Чи вдався запит

[Так.](screenshots/4.png)