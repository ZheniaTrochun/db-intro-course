create type monster_state as enum('wander','attack');

create type race as enum('human','orc','elf','dwarf','khajiit');
create type sex as enum('male','female','croissant','non-binary');
create type class as enum('cleric','fighter','rogue','wizard');

create table stats(
  id int generated always as identity primary key,
	strength int not null,
	dexterity int not null,
	intelligence int not null,
	defense int not null,
	agility int not null
);

insert into stats (strength, dexterity, intelligence, defense, agility)
values
    (45, 62, 18, 50, 55), -- Balanced warrior-type (taken)
    (85, 30, 12, 90, 25), -- Heavy tank
    (15, 22, 95, 10, 35), -- Pure mage (taken)
    (50, 50, 50, 50, 50), -- Jack-of-all-trades (taken)
    (72, 88, 60, 65, 82), -- High-level agile fighter
    (30, 45, 75, 40, 50), -- Battle mage / spellsword
    (95, 40, 20, 85, 30), -- Berserker
    (20, 90, 45, 30, 95); -- Rogue / assassin

create table zone(
    id int generated always as identity primary key,
    level_requirement int,
    zone_name varchar(100)
);

insert into zone (level_requirement, zone_name) values
    (1, 'Firelink Shrine'),
    (5, 'Undead Burg'),
    (10, 'Depths'),
    (20, 'Blighttown'),
    (40, 'Anor Londo'),
    (80, 'The Abyss'),
    (100, 'Kiln of the First Flame');

----REGION ENTITIES ----

create table monster_type(
    id int generated always as identity primary key,
    name varchar(128) not null,
    description varchar(500)
);

insert into monster_type (name, description) values
    ('Hollow', 'A shell of one''s former self'),
    ('Skeleton', 'Excels in regeneration'),
    ('Pinwheel', 'Just spam attack'),
    ('Soldier of God, Rick', 'The undefeated champion.');

create table world_entity(
    id int generated always as identity primary key,
    zone_id int not null references zone,

    position_x decimal not null,
    position_y decimal not null,
    position_z decimal not null,

    max_hp int not null CHECK (max_hp > 0),
    level int not null CHECK (level >= 0)
);

insert into world_entity (zone_id, position_x, position_y, position_z, max_hp, level) values
    (1, 138.3, 2903.556, 248.4872, 50, 3),  --taken
    (1, 389.4, 18937.7831, 738.3781, 100,5), --taken
    (2, 310.10, 381.39, 39.531, 200, 8),  --taken
    (3, 3920.42, 492.42, 8942.8924, 500, 20), --taken
    (3, 39318.42, 32.47, 89.24, 1000, 30),
    (4, 389.8329, 3829.3892, 38.92, 250, 16), --taken
    (5, 290.42,19.38, 3.392, 1, 1),
    (6, 8941.41, 49.47, 4.4920, 1000, 40),
    (7, 3967.67, 381.8913, 8931.781, 2000, 50); --taken


create table users(
	id int generated always as identity primary key,

	username varchar(100) not null,
	email varchar(255) not null unique CHECK (email LIKE '_%@_%._%'),
	password_hash varchar(128) not null CHECK (trim(password_hash) <> ''),

	ban_until timestamp with time zone null default null,
	ban_reason varchar(420) null default null
);

insert into users (username, email, password_hash) values
		('RodrickTheGreatest', 'verynormalemail@gmil.com', 'hashedpassword1'),
		('xXx_DragonSlayer_xXx', 'dragonslayer@example.com', 'hashedpassword2'),
		('overlord123', 'overlord123@example.com', 'hashedpassword3'),
		('ShadowAssassin', 'shadowassassin@example.com', 'hashedpassword4'),
		('PropagandaIsUseless', 'sombraforever@gmail.com', 'hashedpassword5');

create table character(
	id int generated always as identity primary key,
	worldentity_id int not null references world_entity(id),
	user_id int not null references users(id),
	stats_id int not null references stats(id),

	name varchar(100) not null CHECK (trim(name) <> ''),

	experience int not null default 0 CHECK (experience >= 0),		
	current_hp int not null CHECK (current_hp > max_hp),
	current_mana int not null CHECK (current_mana > max_mana),
	max_mana int not null CHECK (max_mana >= 0),

	skin_color_hex char(7) not null CHECK (skin_color_hex LIKE '#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]'),
	sex sex not null,
	race race not null,
	class class not null
);

insert into character (worldentity_id, user_id, stats_id, name, experience, current_hp, current_mana, max_mana, skin_color_hex, sex, race, class) values
		(3, 1, 1, 'Arthas', 0, 50, 30, 30, '#F5CBA7', 'male', 'human', 'fighter'),
		(5, 2, 5, 'Sylvanas', 0, 100, 50, 50, '#A569BD', 'female', 'elf', 'rogue'),
		(6, 3, 6, 'Thrall', 0, 200, 100, 100, '#229954', 'male', 'orc', 'cleric'),

create table monster_entity(
    id int generated always as identity primary key,
    entity_id int not null references world_entity(id),
    state monster_state not null default 'wander',
    stats_id int not null references stats(id),
    type_id int not null references monster_type(id),
    target_id int references character(id)
);

insert into monster_entity (entity_id,state,stats_id, type_id,target_id) values 
    (4, default, 1, 1, default),
    (6, default, 3, 3, default),
    (9, default, 4, 4, default);

create table npc(
    id int generated always as identity primary key,
    entity_id int not null references world_entity(id),
    name varchar(128) not null
);

insert into npc (entity_id, name) values
    (1, 'Patches'),
    (2, 'Snuggly'),
    (3, 'Undead Merchant');

----ENDREGION ENTITIES ----

----REGION ITEMS/TOOLS ----

create table inventory(
	id int generated always as identity primary key,
	character_id int not null references character(id),
	gold int not null default 0,
	capacity int not null default 20
);

insert into inventory (character_id, gold, capacity) values
	(1, 49, 20),
	(2, 47, 23),
	(3, 34, 545);

create type item_type as enum('weapon', 'food', 'armor', 'tool');

create table item_template(
    id int generated always as identity primary key,
    name varchar(128) not null,
    description varchar(128) not null,
    max_stack smallint not null default 1,
    rarity smallint not null default 0,
    type item_type not null
);

insert into item_template (name, description, max_stack, rarity, type)
values
    ('Wolf Fang', 'A sharp, yellowed tooth taken from a forest predator. Used in crafting basic weapons.', 99, 0, 'tool'),
    ('Minor Healing Salve', 'A bitter-smelling herbal mixture that restores a small amount of health upon use.', 20, 1, 'food'),
    ('Rusted Iron Helm', 'A heavy iron helmet showing signs of age and battle. Offers basic head protection.', 1, 2, 'armor');

create table item(
    id int generated always as identity primary key,
    item_tmpl_id int not null references item_template(id),
    inv_id int not null references inventory(id),
    inventory_slot smallint not null,
    quantity smallint not null default 1,
    attributes jsonb,
    enchantments jsonb
);

insert into item (item_tmpl_id, inv_id, inventory_slot, quantity) values
	(1, 1, 1, 1),
	(2, 2, 2, 2),
	(3, 3, 3, 34);

create table npc_item_relation(
    npc_id int not null references npc(id),
    item_id int not null references item(id),
    trades boolean not null,
    sell_price int,
    buy_price int,
    primary key (npc_id,item_id)
);

insert into npc_item_relation (npc_id, item_id, trades, sell_price, buy_price) values
    (1,1, true, 500, 70),
    (1,2, true, 1000, 100),
    (1,3, false, default, default),
    (2,1, true, 10000, 1000),
    (2,2, false, default, default),
    (2,3, true, 5000, 800),
    (3,1, true, 1000, 100),
    (3,2, false, default, default),
    (3,3, true, 17000, 1200);

create table monster_drop(
    monster_id int not null references monster_type(id),
    item_id int not null references item_template(id),
    primary key (monster_id,item_id)
);

insert into monster_drop (monster_id,item_id) values
    (1, 3), (2, 3), (3, 2), (4, 1);

create table spell(
		id int generated always as identity primary key,
		name varchar(128) not null UNIQUE CHECK (trim(name) <> ''),
		description varchar(512) not null CHECK (trim(description) <> ''),
		mana_cost int not null default 0 CHECK (mana_cost >= 0)
);

insert into spell (name, description, mana_cost) values
	('Fireball', 'A ball of fire that explodes upon impact, dealing damage to all enemies in the area.', 20),
	('Ice Spike', 'A sharp spike of ice that pierces through enemies, slowing them down.', 15),
	('Healing Word', 'A warm light that heals allies over time.', 25);

create table character_spell(
		character_id int not null references character(id),
		spell_id int not null references spell(id),
		quantity int not null default 0 CHECK (quantity >= 0),
		primary key (character_id,spell_id)
);

insert into character_spell (character_id, spell_id, quantity) values
	(1, 1, 3),
	(1, 2, 2),
	(2, 3, 5),
	(3, 1, 1),
	(3, 2, 4);

----ENDREGION ITEMS/TOOLS ----