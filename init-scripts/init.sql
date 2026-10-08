create table world_entity(
    id int generated always as identity primary key
);

create type monster_state as enum('wander','attack');

create table zone(
    id int generated always as identity primary key,
    level_requirement int,
    zone_name varchar(100)
);

----REGION ENTITIES ----

create table monster_type(
    id int generated always as identity primary key,
    name varchar(128) not null,
    description varchar(500)
);

create table monster_entity(
    id int generated always as identity primary key,
    entity_id int not null references world_entity(id),
    state monster_state not null default 'wander',
    stats_id int not null, --make reference when it exists
    type_id int not null references monster_type(id),
    target_id int --same
);

create table npc(
    id int generated always as identity primary key,
    entity_id int not null references world_entity(id),
    name varchar(128) not null
);

----ENDREGION ENTITIES ----

----REGION ITEMS/TOOLS ----

create type item_type as enum('weapon', 'food', 'armor', 'tool');

create table item_template(
    id int generated always as identity primary key,
    name varchar(128) not null,
    description varchar(128) not null,
    max_stack smallint not null default 1,
    rarity smallint not null default 0,
    type item_type not null
);

create table item(
    id int generated always as identity primary key,
    item_tmpl_id int not null references item_template(id),
    -- inv_id int not null references inventory(id),
    inventory_slot smallint not null,
    quantity smallint not null default 1,
    price smallint not null default 0,
    attributes jsonb,
    enchantments jsonb
);

create table npc_item_relation(
    npc_id int not null references npc(id),
    item_id int not null references item(id),
    trades boolean not null,
    sell_price int,
    buy_price int,
    primary key (npc_id,item_id)
);

create table monster_drop(
    monster_id int not null references monster_type(id),
    item_id int not null references item_template(id),
    primary key (monster_id,item_id)
);

----ENDREGION ITEMS/TOOLS ----