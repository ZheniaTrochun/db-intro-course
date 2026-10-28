-- Отримати ідентифікатори типів предметів, які може викинути при смерті монстр, ідентифікатор типу якого дорівнює 1 (тут Hollow)
select item_id from monster_drop where monster_id = 1;

--СТВОРЕННЯ НОВОГО NPC

--створюємо новий world_entity, на який потім буде посилатись запис у таблиці npc
insert into world_entity (zone_id, position_x, position_y, position_z, max_hp, level) values
    (1, 138.3, 2903.556, 248.4872, 50, 3) returning id; --10
--створюємо нового npc, використовуючи отриманий entity_id
insert into npc (entity_id, name) values 
    (10, 'Seam');

--перевірка insert-у
select entity_id from npc where name = 'Seam';

-- Зміна необхідного рівня для доступу до зони "Undead Burg" на 10
update zone
set level_requirement = 10
where zone_name = 'Undead Burg';

--перевірка update-у
select level_requirement from zone where zone_name = 'Undead Burg';

--видалення попередньо доданого npc
delete from npc where name = 'Seam';
delete from world_entity where id = 10;

--перевірка
select * from npc where name = 'Seam';

