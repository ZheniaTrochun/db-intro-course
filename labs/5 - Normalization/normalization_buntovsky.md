# Обрана таблиця для перевірки

Таблиця npc_item_relation має ознаки надлишковості:

```sql
create table npc_item_relation(
    npc_id int not null references npc(id),
    item_id int not null references item_template(id),
    trades boolean not null,
    sell_price int,
    buy_price int,
    primary key (npc_id,item_id)
);
```

(npc_id, item_id) -> trades
(npc_id, item_id) -> sell_price    [якщо trades = true; інакше NULL]
(npc_id, item_id) -> buy_price     [якщо trades = true; інакше NULL]

## Перевірка

1НФ - так, адже немає неатомарних полів
2НФ - так, всі неключові залежать як пари npc_id та item_id
3НФ - так, немає транзитивних залежностей

Тут є маленька надмірність у вигляді поля trades - його можна видалити, адже NULL у полях sell_price та buy_price також індикують, що нпс не торгує даним типом предмета. Оновлений варіант:

```sql
create table npc_item_relation(
    npc_id int not null references npc(id),
    item_id int not null references item_template(id),
    sell_price int,
    buy_price int,
    primary key (npc_id,item_id)
);

insert into npc_item_relation (npc_id, item_id, sell_price, buy_price) values
    (1,1, 500, 70),
    (1,2, 1000, 100),
    (1,3, default, default),
    (2,1, 10000, 1000),
    (2,2, default, default),
    (2,3, 5000, 800),
    (3,1, 1000, 100),
    (3,2, default, default),
    (3,3, 17000, 1200);
```

# Інші таблиці
```sql
create table zone(
    id int generated always as identity primary key,
    level_requirement int,
    zone_name varchar(100)
);
```

id -> level_requirement
id -> zone_name

3НФ

```sql
create table monster_type(
    id int generated always as identity primary key,
    name varchar(128) not null,
    description varchar(500)
);
```

id -> name
id -> description

3НФ

```sql
create table world_entity(
    id int generated always as identity primary key,
    zone_id int not null references zone,

    position_x decimal not null,
    position_y decimal not null,
    position_z decimal not null,

    max_hp int not null CHECK (max_hp > 0),
    level int not null CHECK (level >= 0)
);
```

id -> zone_id
id -> position_x
id -> position_y
id -> position_z
id -> max_hp
id -> level

3NF

```sql
create table monster_entity(
    id int generated always as identity primary key,
    entity_id int not null references world_entity(id),
    state monster_state not null default 'wander',
    stats_id int not null references stats(id),
    type_id int not null references monster_type(id),
    target_id int references character(id)
);
```

id -> entity_id
id -> state
id -> stats_id
id -> type_id
id -> target_id

3NF

```sql
create table npc(
    id int generated always as identity primary key,
    entity_id int not null references world_entity(id),
    name varchar(128) not null
);
```

id -> entity_id
id -> name

3NF

```sql
create table monster_drop(
    monster_id int not null references monster_type(id),
    item_id int not null references item_template(id),
    primary key (monster_id,item_id)
);
```
Таблиця реалізує чистий many-to-many, немає нетривіальних залежностей від неключових атрибутів, 3NF