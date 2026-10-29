create table world_entity(
    id int generated always as identity primary key
);

create type monster_state as enum('wander','attack');

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
    stats_id int not null, --make reference when it exists
    type_id int not null references monster_type(id),
    target_id int --same
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