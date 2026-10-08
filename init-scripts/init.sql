create table world_entity(
    id int generated always as identity primary key
);

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
)

create table zone(
    id int generated always as identity primary key,
    level_requirement int,
    zone_name varchar(100)
);

create table monster_type(
    id int generated always as identity primary key,
    name varchar(128) not null,
    description varchar(500)
);

create table monster_entity(
    id int generated always as identity primary key,
    entity_id int not null references world_entity(id),
    state monster_state not null default 'wander',
    stats_id int not null references stats(id),
    type_id int not null references monster_type(id),
    target_id int not null references character(id)
);

create table npc(
    id int generated always as identity primary key,
    entity_id int not null references world_entity(id),
    name varchar(128) not null
);

create table npc_item_relation(
    npc_id int not null references npc(id),
    item_id int not null, --make reference item type
    trades boolean not null,
    sell_price int,
    buy_price int,
    primary key (npc_id,item_id)
);

create table monster_drop(
    monster_id int not null references monster_type(id),
    item_id int not null, --make reference item type
    primary key (monster_id,item_id)
);

create table user(
	id int generated always as identity primary key,
	username varchar(100) not null,
	email varchar(255) not null unique,
	password_hash varbinary(128) not null,
	ban_until timestamp with time zone null default null,
	ban_reason varchar(420) null default null
)

create table character(
	id int generated always as identity primary key,
	worldentity_id int not null references world_entity(id),
	user_id int not null references user(id),
	stats_id int not null references stats(id),

	name varchar(100) not null,

	experience int not null default 0,		
	current_hp int not null,
	current_mana int not null,
	max_mana int not null,

	skin_color_hex char[7] not null,
	sex sex not null,
	race race not null,
	class class not null,
);

create table spell(
		id int generated always as identity primary key,
		name varchar(128) not null,
		description varchar(512) not null,
		mana_cost int not null default 0
);

create table character_spell(
		character_id int not null references character(id),
		spell_id int not null, --make reference item type
		quantity int not null default 1,
		primary key (character_id,spell_id)
);

create table inventory(
	id int generated always as identity primary key,
	character_id int not null references character(id),
	gold int not null default 0,
	capacity int not null default 20
);